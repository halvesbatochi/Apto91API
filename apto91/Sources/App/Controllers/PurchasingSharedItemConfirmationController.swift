//
//  PurchasingSharedItemConfirmationController.swift
//
//
//  Created by Henrique Alves Batochi on 18/02/24.
//

import Vapor

struct PurchasingSharedItemConfirmationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let confirmation = routes.grouped("purchasingshareditemconfirmation")
        confirmation.post(use: postPurchasingSharedItemConfirmation)
    }
    
    func postPurchasingSharedItemConfirmation(req: Request) async throws -> PIC003Result {
        
        let confirmation = try req.content.decode(PurchasingSharedItemConfirmationRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM IC.PIC003(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               \(confirmation.nrHouse),
                                                                                               \(confirmation.nrResident),
                                                                                               \(confirmation.nrItem),
                                                                                               \(confirmation.nrPurchasing))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PIC003Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_purchasing: nil)
            
            for try await (cd_erro, ds_erro, nr_purchasing) in row.decode((Decimal, String, Int?).self) {
                
                response = PIC003Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_purchasing: nr_purchasing)
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
