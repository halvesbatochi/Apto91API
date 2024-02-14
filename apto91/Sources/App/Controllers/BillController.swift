//
//  Bill.swift
//
//
//  Created by Henrique Alves Batochi on 13/02/24.
//

import Vapor

struct BillController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bill = routes.grouped("bill")
        bill.post(use: postBill)
        bill.put(use: putBill)
        bill.delete(use: deleteBill)
    }
    
    func postBill(req: Request) async throws -> PCC001Result {
        
        let bill = try req.content.decode(BillRequest.self)
        
        do {
            
            let dtDDDueDate = bill.dtDDDueDate == nil ? "NULL" : "\(bill.dtDDDueDate ?? 0)"
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC001(1,
                                                                                            '\("I")',
                                                                                            NULL,
                                                                                            \(bill.nrResident),
                                                                                            \(bill.nrHouse),
                                                                                            \(bill.nrTypeBill),
                                                                                            \(dtDDDueDate),
                                                                                            \(bill.dtAMDueDate),
                                                                                            \(bill.vlValue))
                                                                       """)
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC001Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_bill: nil)
            
            for try await (cd_erro, ds_erro, nr_bill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_bill: nr_bill)
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
    
    func putBill(req: Request) async throws -> PCC001Result {
        
        let bill = try req.content.decode(BillRequest.self)
        
        do {
            
            guard let nrBill = bill.nrBill,
                  let dtDDDueDate = bill.dtDDDueDate else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC001(1,
                                                                                            '\("U")',
                                                                                            \(nrBill),
                                                                                            \(bill.nrResident),
                                                                                            \(bill.nrHouse),
                                                                                            \(bill.nrTypeBill),
                                                                                            \(dtDDDueDate),
                                                                                            \(bill.dtAMDueDate),
                                                                                            \(bill.vlValue))
                                                                       """)
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC001Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_bill: nil)
            
            for try await (cd_erro, ds_erro, nr_bill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_bill: nr_bill)
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
    
    func deleteBill(req: Request) async throws -> PCC001Result {
        
        let bill = try req.content.decode(BillRequest.self)
        
        do {
            
            guard let nrBill = bill.nrBill,
                  let dtDDDueDate = bill.dtDDDueDate else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM CC.PCC001(1,
                                                                                            '\("D")',
                                                                                            \(nrBill),
                                                                                            \(bill.nrResident),
                                                                                            \(bill.nrHouse),
                                                                                            \(bill.nrTypeBill),
                                                                                            \(dtDDDueDate),
                                                                                            \(bill.dtAMDueDate),
                                                                                            \(bill.vlValue))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PCC001Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_bill: nil)
            
            for try await (cd_erro, ds_erro, nr_bill) in row.decode((Decimal, String, Int?).self) {
                
                response = PCC001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_bill: nr_bill)
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
