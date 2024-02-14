//
//  SignUpController.swift
//
//
//  Created by Henrique Alves Batochi on 10/02/24.
//

import Vapor

/// Manage requests to SignUp route
struct SignUpController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let signUp = routes.grouped("signup")
        signUp.post(use: signUpResident)
        signUp.put(use: updateResident)
        signUp.delete(use: deleteResident)
    }
    
    func signUpResident(req: Request) async throws -> PAD001Result {
        
        try SignUpRequest.validate(content: req)
        let residentSignUp = try req.content.decode(SignUpRequest.self)
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD001(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
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
                                        nr_resident: nil)
            
            for try await (cd_erro, ds_erro, nr_resident) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_resident: nr_resident)
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
    
    func updateResident(req: Request) async throws -> PAD001Result {
        
        try SignUpRequest.validate(content: req)
        let residentSignUp = try req.content.decode(SignUpRequest.self)
        
        guard let nrResident = residentSignUp.nrResident else {
            throw Abort(.badRequest)
        }
        
        do {
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD001(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               '\("U")',
                                                                                               \(nrResident),
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
                                        nr_resident: nil)
            
            for try await (cd_erro, ds_erro, nr_morador) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_resident: nr_morador)
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
    
    func deleteResident(req: Request) async throws -> PAD001Result {
        
        try SignUpRequest.validate(content: req)
        let residentSignUp = try req.content.decode(SignUpRequest.self)
        
        do {
            
            guard let nrResident = residentSignUp.nrResident else {
                throw Abort(.badRequest)
            }
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD001(\(ProcessInfo.processInfo.environment["ENT_NR_VRS"]!),
                                                                                               '\("D")',
                                                                                               \(nrResident),
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
                                        nr_resident: nil)
            
            for try await (cd_erro, ds_erro, nr_morador) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD001Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_resident: nr_morador)
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
}
