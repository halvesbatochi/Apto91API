//
//  BillPaymentConfirmationController.swift
//
//
//  Created by Henrique Alves Batochi on 14/02/24.
//

import Vapor

struct BillPaymentConfirmationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let confirmation = routes.grouped("billpaymentconfirmation")
        confirmation.post(use: postConfirmation)
    }
    
    func postConfirmation(req: Request) async throws -> PCC004Result {
        
        let confirmation = try req.content.decode(BillConfirmationRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC004(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               \(confirmation.nrHouse),
                                                                                               \(confirmation.nrAdm),
                                                                                               \(confirmation.nrResident),
                                                                                               \(confirmation.nrMonthlyBill),
                                                                                               \(confirmation.nrResidentBill))
                                                                       """)
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC004Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_residentBill: nil)
            
            for try await (cd_erro, ds_erro, nr_residentBill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC004Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_residentBill: nr_residentBill)
            }
            
            if response.cd_erro == -1 {
                throw DatabaseManagerError.dbError(response.ds_erro)
            }
            
            return response
            
        } catch DatabaseManagerError.dbError(let errorMessage) {
            throw Abort(.custom(code: 400,
                                reasonPhrase: errorMessage))
        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw error
        }
    }
}
