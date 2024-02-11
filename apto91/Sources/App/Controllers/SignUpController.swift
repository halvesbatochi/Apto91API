//
//  SignUpController.swift
//
//
//  Created by Henrique Alves Batochi on 10/02/24.
//

import Vapor

enum SignUpError: Error {
    case bdError(String)
}

/// Manage requests to SignUp route
struct SignUpController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let signUp = routes.grouped("signup")
        signUp.post(use: signUpResident)
    }
    
    func signUpResident(req: Request) async throws -> PAD001Result {
        
        try SignUpRequest.validate(content: req)
        let residentSignUp = try req.content.decode(SignUpRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD001(1,
                                                                                               '\("I")',
                                                                                               NULL,
                                                                                               '\(residentSignUp.name)',
                                                                                               '\(residentSignUp.lastName)',
                                                                                               '\(residentSignUp.cpf)',
                                                                                               '\(residentSignUp.email)',
                                                                                               '\(residentSignUp.login)',
                                                                                               '\(residentSignUp.passw)',
                                                                                               \(residentSignUp.startDate),
                                                                                               \(residentSignUp.tpResident))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PAD001Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_morador: nil)
            
            for try await (cd_erro, ds_erro, nr_morador) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_morador: nr_morador)
            }
            
            if response.cd_erro == -1 {
                throw SignUpError.bdError(response.ds_erro)
            }
            
            return response
            
        } catch SignUpError.bdError(let errorMessage) {
            throw Abort(.custom(code: 400, reasonPhrase: errorMessage))

        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw Abort(.internalServerError)
        }
    }
}
