//
//  PurchasingSharedItemController.swift
//
//
//  Created by Henrique Alves Batochi on 17/02/24.
//

import Vapor

struct PurchasingSharedItemController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let purchasing = routes.grouped("purchasingshareditem")
        purchasing.post(use: postPurchasingSharedItem)
        purchasing.put(use: putPurchasingSharedItem)
        purchasing.delete(use: deletePurchasingSharedItem)
    }
    
    func postPurchasingSharedItem(req: Request) async throws -> PIC002Result {
        
        let purchasing = try req.content.decode(PurchasingSharedItemRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM IC.PIC002(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               '\("I")',
                                                                                               NULL,
                                                                                               \(purchasing.nrItem),
                                                                                               \(purchasing.nrResident),
                                                                                               \(purchasing.nrQuantity),
                                                                                               \(purchasing.vlValue))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PIC002Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_purchasing: nil)
            
            for try await (cd_erro, ds_erro, nr_purchasing) in row.decode((Decimal, String, Int?).self) {
                
                response = PIC002Result(cd_erro: cd_erro,
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
    
    func putPurchasingSharedItem(req: Request) async throws -> PIC002Result {
        
        let purchasing = try req.content.decode(PurchasingSharedItemRequest.self)
        
        do {
            
            guard let nrPurchasing = purchasing.nrPurchasing else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM IC.PIC002(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               '\("U")',
                                                                                               \(nrPurchasing),
                                                                                               \(purchasing.nrItem),
                                                                                               \(purchasing.nrResident),
                                                                                               \(purchasing.nrQuantity),
                                                                                               \(purchasing.vlValue))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PIC002Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_purchasing: nil)
            
            for try await (cd_erro, ds_erro, nr_purchasing) in row.decode((Decimal, String, Int?).self) {
                
                response = PIC002Result(cd_erro: cd_erro,
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
    
    func deletePurchasingSharedItem(req: Request) async throws -> PIC002Result {
        
        let purchasing = try req.content.decode(PurchasingSharedItemRequest.self)
        
        do {
            
            guard let nrPurchasing = purchasing.nrPurchasing else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM IC.PIC002(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               '\("D")',
                                                                                               \(nrPurchasing),
                                                                                               \(purchasing.nrItem),
                                                                                               \(purchasing.nrResident),
                                                                                               \(purchasing.nrQuantity),
                                                                                               \(purchasing.vlValue))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PIC002Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_purchasing: nil)
            
            for try await (cd_erro, ds_erro, nr_purchasing) in row.decode((Decimal, String, Int?).self) {
                
                response = PIC002Result(cd_erro: cd_erro,
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
