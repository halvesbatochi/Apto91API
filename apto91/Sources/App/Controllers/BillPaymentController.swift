//
//  BillPaymentController.swift
//
//
//  Created by Henrique Alves Batochi on 13/02/24.
//

import Vapor

struct BillPaymentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let payment = routes.grouped("billpayment")
        payment.post(use: postPayment)
    }
    
    func postPayment(req: Request) async throws -> PCC005Result {
        
        let payment = try req.content.decode(BillPaymentRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC005(1,
                                                                                               \(payment.nrHouse),
                                                                                               \(payment.nrResident),
                                                                                               \(payment.nrMonthlyBill),
                                                                                               \(payment.nrResidentBill),
                                                                                               \(payment.dtPayment))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC005Result(cd_erro: 0,
                                        ds_erro: "")
            
            for try await (cd_erro, ds_erro) in row.decode((Decimal, String).self) {
                
                response = PCC005Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro)
                
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
