//
//  LoginController.swift
//
//
//  Created by Henrique Alves Batochi on 08/02/24.
//

import Vapor

/// Manage requests to Login route
struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let login = routes.grouped("login")
        login.get(.parameter("user"), .parameter("passw"), use: loginResident)
    }
    

    func loginResident(req: Request) async throws -> LoginResult {
        
        guard let user = req.parameters.get("user", as: String.self),
              let passw = req.parameters.get("passw", as: String.self) else {
            throw Abort(.badRequest)
        }
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: 
                         "SELECT * FROM AD.PAD002(1, '\(user)', '\(passw)')"
            )
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response: LoginResult = LoginResult(cd_erro: 0,
                                                   ds_erro: "",
                                                   nr_resident: 0)
            
            for try await (cd_erro, ds_erro, nr_resident) in row.decode((Decimal, String, Int?).self) {
                
                response = LoginResult(cd_erro: cd_erro,
                                      ds_erro: ds_erro,
                                      nr_resident: nr_resident ?? 0)
            }
            
            return response
            
        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw Abort(.internalServerError)
        }
    }
}
