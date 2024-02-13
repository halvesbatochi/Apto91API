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
    
    func postBill(req: Request) async throws -> String {
        
        return "ok"
    }
    
    func putBill(req: Request) async throws -> String {
        
        return "put"
    }
    
    func deleteBill(req: Request) async throws -> String {
        
        return "delete"
    }
}
