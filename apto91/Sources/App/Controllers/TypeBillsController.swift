//
//  TypeBillsController.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

enum TypeBillsError: Error {
    case dbError(String)
}

struct TypeBillsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let typeBills = routes.grouped("typebills")
        typeBills.post(use: postTypeBills)
        typeBills.put(use: putTypeBills)
        typeBills.delete(use: deleteTypeBills)
    }
    
    func postTypeBills(req: Request) async throws -> String {
        
        return "Type Bills"
    }
    
    func putTypeBills(req: Request) async throws -> String {
        
        return "PUT"
    }
    
    func deleteTypeBills(req: Request) async throws -> String {
        
        return "DELETE"
    }
}
