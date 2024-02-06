//
//  RootController.swift
//
//
//  Created by Henrique Alves Batochi on 05/02/24.
//

import Vapor

/// Manage request to Root route
struct RootController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let root = routes.grouped("")
        root.get(use: fetchRootMessage)
    }
    
    func fetchRootMessage(req: Request) async throws -> Response {
        return Response(status: .ok, 
                        body: .init(staticString: "API do Apto91"))
    }
}
