//
//  LoginController.swift
//
//
//  Created by Henrique Alves Batochi on 08/02/24.
//

import Vapor

enum LoginError: Error {
    case bdError(String)
}

/// Manage requests to Login route
struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let login = routes.grouped("login")
        login.post(use: loginResident)
    }

    func loginResident(req: Request) async throws -> LoginResult {
        
        try LoginRequest.validate(content: req)
        let resident = try req.content.decode(LoginRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query:"""
                                                                      SELECT * FROM AD.PAD002(1,
                                                                                              '\(resident.user)',
                                                                                              '\(resident.passw)')
                                                                      """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PAD002Result(cd_erro: 0,
                                        ds_erro: "",
                                        AD001_NR_MORADOR: 0,
                                        AD001_VC_NOME: "",
                                        AD001_VC_SOBREN: "",
                                        AD001_DT_ENTRADA: 0)
            
            for try await (cd_erro, ds_erro, nr_resident, name, lastName, startDate)
                    in row.decode((Decimal, String, Int?, String?, String?, Decimal?).self) {
                
                response = PAD002Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        AD001_NR_MORADOR: nr_resident ?? 0,
                                        AD001_VC_NOME: name ?? "",
                                        AD001_VC_SOBREN: lastName ?? "",
                                        AD001_DT_ENTRADA: startDate ?? 0)
            }
            
            if response.cd_erro == -1 {
                throw LoginError.bdError(response.ds_erro)
            }
                
            let payload = JwtPayload(subject: "apto91",
                                     expiration: .init(value: .distantFuture),
                                     nrResident: response.AD001_NR_MORADOR,
                                     name: response.AD001_VC_NOME,
                                     lastName: response.AD001_VC_SOBREN,
                                     startDate: response.AD001_DT_ENTRADA,
                                     isAdmin: true)
                
            let responseJWT = LoginResult(cd_erro: response.cd_erro,
                                          ds_erro: response.ds_erro,
                                          token: response.cd_erro != 0 ? "" : try req.jwt.sign(payload))
            return responseJWT
                
                
        } catch LoginError.bdError(let errorMessage) {
            throw Abort(.custom(code: 400, reasonPhrase: errorMessage))
        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw Abort(.internalServerError)
        }
    }
}
