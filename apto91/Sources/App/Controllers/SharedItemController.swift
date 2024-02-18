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
        
        
        
        return PIC001Result(cd_erro: 0, ds_erro: "", nr_item: 0)
    }
    
    func putSharedItem(req: Request) async throws -> PIC001Result {
        
        return PIC001Result(cd_erro: 0, ds_erro: "", nr_item: 0)
    }
    
    func deleteSharedItem(req: Request) async throws -> PIC001Result {
        
        return PIC001Result(cd_erro: 0, ds_erro: "", nr_item: 0)
    }
}
