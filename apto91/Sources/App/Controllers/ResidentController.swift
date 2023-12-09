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
    
    func fetchResident(req: Request) async -> String {
        do {
            let obj = try await DatabaseManager.shared.query(query: "teste")
            return "Olá Morador!"
        } catch {
            print("\(error.localizedDescription)")
            return "Falha na conexão. Tente novamente mais tarde!"
        }

    }
    
    func updateResident(req: Request) async throws -> String {
        return "Morador atualizado"
    }
    
    func deleteResident(req: Request) async throws -> String {
        return "Morador excluído"
    }
}
