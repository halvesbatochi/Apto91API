//
//  SharedItemController.swift
//  
//
//  Created by Henrique Alves Batochi on 17/02/24.
//

import Vapor

/// Manage requests to Shared Item route
struct SharedItemController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sharedItem = routes.grouped("shareditem")
        sharedItem.post(use: postSharedItem)
        sharedItem.put(use: putSharedItem)
        sharedItem.delete(use: deleteSharedItem)
    }
    
    func postSharedItem(req: Request) async throws -> PIC001Result {
        
        try SharedItemRequest.validate(content: req)
        let sharedItem = try req.content.decode(SharedItemRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM IC.PIC001(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               '\("I")',
                                                                                               \(sharedItem.nrHouse),
                                                                                               \(sharedItem.nrResident),
                                                                                               NULL,
                                                                                               '\(sharedItem.vcItem)')
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PIC001Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_item: nil)
            
            for try await (cd_erro, ds_erro, nr_item) in row.decode((Decimal, String, Int?).self) {
                
                response = PIC001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_item: nr_item)
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
    
    func putSharedItem(req: Request) async throws -> PIC001Result {
        
        return PIC001Result(cd_erro: 0, ds_erro: "", nr_item: 0)
    }
    
    func deleteSharedItem(req: Request) async throws -> PIC001Result {
        
        return PIC001Result(cd_erro: 0, ds_erro: "", nr_item: 0)
    }
}
