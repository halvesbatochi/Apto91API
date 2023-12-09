//
//  DatabaseManager.swift
//
//
//  Created by Henrique Alves Batochi on 06/12/23.
//

import Foundation
import PostgresNIO
import Logging

/// Singleton manages requests to the Postgres database
final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let logger = Logger(label: "postgres-logger")
    
    private let host: String
    private let port: Int
    private let username: String
    private let password: String
    private let bd: String
    private let config: PostgresConnection.Configuration
    
    // MARK: - Init
    private init() { 
        
        host = ProcessInfo.processInfo.environment["DATABASE_HOST"]!
        port = Int(ProcessInfo.processInfo.environment["DATABASE_PORT"]!)!
        username = ProcessInfo.processInfo.environment["DATABASE_USERNAME"]!
        password = ProcessInfo.processInfo.environment["DATABASE_PASSW"]!
        bd = ProcessInfo.processInfo.environment["DATABASE_BD"]!
        
        config = PostgresConnection.Configuration(host: host,
                                                  port: port,
                                                  username: username,
                                                  password: password,
                                                  database: bd,
                                                  tls: .disable)
    }

    
    // MARK: - Public methods
    public func query(query: String) async throws -> PostgresRowSequence? {

        let connection = try await PostgresConnection.connect(configuration: config,
                                                              id: 1,
                                                              logger: logger)
        
        let rows = try? await connection.query(PostgresQuery(stringLiteral: query), 
                                               logger: logger)
        
        try await connection.close()
        return rows
    }
}


