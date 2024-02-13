//
//  TypeBillsController.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

struct TypeBillsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let typeBills = routes.grouped("typebill")
        typeBills.post(use: postTypeBills)
        typeBills.put(use: putTypeBills)
        typeBills.delete(use: deleteTypeBills)
    }
    
    func postTypeBills(req: Request) async throws -> PCC002Result {
        
        try TypeBillsRequest.validate(content: req)
        let bill = try req.content.decode(TypeBillsRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC002(1,
                                                                                               '\("I")',
                                                                                               NULL,
                                                                                               \(bill.nrResident),
                                                                                               \(bill.nrResident),
                                                                                               '\(bill.descBill)',
                                                                                               \(bill.recurringBill))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC002Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_typeBill: nil)
            
            for try await (cd_erro, ds_erro, nr_typeBill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC002Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_typeBill: nr_typeBill)
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
            throw Abort(.internalServerError)
        }
    }
    
    func putTypeBills(req: Request) async throws -> PCC002Result {
        
        try TypeBillsRequest.validate(content: req)
        let bill = try req.content.decode(TypeBillsRequest.self)
        
        do {
            
            guard let nrTypeBill = bill.nrTypeBill else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC002(1,
                                                                                               '\("U")',
                                                                                               \(nrTypeBill),
                                                                                               \(bill.nrResident),
                                                                                               \(bill.nrResident),
                                                                                               '\(bill.descBill)',
                                                                                               \(bill.recurringBill))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC002Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_typeBill: nil)
            
            for try await (cd_erro, ds_erro, nr_typeBill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC002Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_typeBill: nr_typeBill)
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
    
    func deleteTypeBills(req: Request) async throws -> PCC002Result {
        
        try TypeBillsRequest.validate(content: req)
        let bill = try req.content.decode(TypeBillsRequest.self)
        
        do {
            
            guard let nrTypeBill = bill.nrTypeBill else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC002(1,
                                                                                               '\("D")',
                                                                                               \(nrTypeBill),
                                                                                               \(bill.nrResident),
                                                                                               \(bill.nrResident),
                                                                                               '\(bill.descBill)',
                                                                                               \(bill.recurringBill))
                                                                       """)
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC002Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_typeBill: nil)
            
            for try await (cd_erro, ds_erro, nr_typeBill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC002Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_typeBill: nr_typeBill)
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
