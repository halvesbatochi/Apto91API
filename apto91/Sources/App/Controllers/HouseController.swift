//
//  HouseController.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

enum HouseError: Error {
    case bdError(String)
}

/// Manage requests to House route
struct HouseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let house = routes.grouped("house")
        house.post(use: postHouse)
        house.put(use: putHouse)
        house.delete(use: deleteHouse)
    }
    
    func postHouse(req: Request) async throws -> PAD003Result {
        
        try HouseRequest.validate(content: req)
        let house = try req.content.decode(HouseRequest.self)
        
        do {
            
            var dueDate = house.dueDate == nil ? "NULL" : "\(house.dueDate ?? 0)"
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD003(1,
                                                                                               '\("I")',
                                                                                               NULL,
                                                                                               \(house.nrResident),
                                                                                               '\(house.houseName)',
                                                                                               \(dueDate))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PAD003Result(cd_erro: 0, 
                                        ds_erro: "",
                                        nr_house: nil)
            
            for try await (cd_erro, ds_erro, nr_house) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD003Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_house: nr_house)
            }
            
            if response.cd_erro == -1 {
                throw HouseError.bdError(response.ds_erro)
            }
            
            return response
            
        } catch HouseError.bdError(let errorMessage) {
            throw Abort(.custom(code: 400,
                                reasonPhrase: errorMessage))
        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw Abort(.internalServerError)
        }
    }
    
    func putHouse(req: Request) async throws -> PAD003Result {
        
        try HouseRequest.validate(content: req)
        let house = try req.content.decode(HouseRequest.self)
        
        do {
            
            var dueDate = house.dueDate == nil ? "NULL" : "\(house.dueDate ?? 0)"
            var nrHouse = house.nrHouse == nil ? "NULL" : "\(house.nrHouse ?? 0)"
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD003(1,
                                                                                               '\("U")',
                                                                                               \(nrHouse),
                                                                                               \(house.nrResident),
                                                                                               '\(house.houseName)',
                                                                                               \(dueDate))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PAD003Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_house: nil)
            
            for try await (cd_erro, ds_erro, nr_house) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD003Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_house: nr_house)
            }
            
            if response.cd_erro == -1 {
                throw HouseError.bdError(response.ds_erro)
            }
            
            return response
            
        } catch HouseError.bdError(let errorMessage) {
            throw Abort(.custom(code: 400,
                                reasonPhrase: errorMessage))
        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw Abort(.internalServerError)
        }
    }
    
    func deleteHouse(req: Request) async throws -> PAD003Result {
        
        try HouseRequest.validate(content: req)
        let house = try req.content.decode(HouseRequest.self)
        
        do {
            
            var dueDate = house.dueDate == nil ? "NULL" : "\(house.dueDate ?? 0)"
            var nrHouse = house.nrHouse == nil ? "NULL" : "\(house.nrHouse ?? 0)"
            
            let seqRow = try await DatabaseManager.shared.query(query: """
                                                                       SELECT * FROM AD.PAD003(1,
                                                                                               '\("D")',
                                                                                               \(nrHouse),
                                                                                               \(house.nrResident),
                                                                                               '\(house.houseName)',
                                                                                               \(dueDate))
                                                                       """)
            
            guard let row = seqRow else {
                throw Abort(.internalServerError)
            }
            
            var response = PAD003Result(cd_erro: 0,
                                        ds_erro: "",
                                        nr_house: nil)
            
            for try await (cd_erro, ds_erro, nr_house) in row.decode((Decimal, String, Int?).self) {
                
                response = PAD003Result(cd_erro: cd_erro,
                                        ds_erro: ds_erro,
                                        nr_house: nr_house)
            }
            
            if response.cd_erro == -1 {
                throw HouseError.bdError(response.ds_erro)
            }
            
            return response
            
        } catch HouseError.bdError(let errorMessage) {
            throw Abort(.custom(code: 400,
                                reasonPhrase: errorMessage))
        } catch {
            req.logger.error(Logger.Message(stringLiteral: error.localizedDescription))
            throw Abort(.internalServerError)
        }
    }
}
