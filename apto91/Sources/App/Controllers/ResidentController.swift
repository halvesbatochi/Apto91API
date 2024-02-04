//
//  MoradorController.swift
//
//
//  Created by Henrique Alves Batochi on 07/12/23.
//

import Vapor

/// Manage requests to Resident route
struct ResidentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let resident = routes.grouped("resident")
        resident.get(use: fetchResident)
        resident.put(use: updateResident)
        resident.delete(use: deleteResident)
    }
    
    func fetchResident(req: Request) async throws -> [ResidentResult] {
        do {
            
            let seqRows = try await DatabaseManager.shared.query(query: "SELECT ad001_vc_nome, ad001_vc_sobren FROM AD.AD001")
            
            var retorno: [ResidentResult] = []
            
            guard let rows = seqRows else {
                throw Abort(.internalServerError)
            }
            
            for try await (nome, sobren) in rows.decode((String, String).self) {
                
                let obj = ResidentResult(nome: nome, sobren: sobren)
                retorno.append(obj)
                
            }
            
            return retorno

        } catch {
            print("\(error.localizedDescription)")
            throw Abort(.internalServerError)
        }
    }
    
    func updateResident(req: Request) async throws -> String {
        return "Morador atualizado"
    }
    
    func deleteResident(req: Request) async throws -> String {
        return "Morador excluído"
    }
}
