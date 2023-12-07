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
    
    let logger = Logger(label: "postgres-logger")
    let config = PostgresConnection.Configuration(host: "192.168.15.91",
                                                  port: 5433,
                                                  username: "postgres",
                                                  password: "rique16/06/1991",
                                                  database: "apto91",
                                                  tls: .disable)
    
    // MARK: - Init
    private init() { }

    
    // MARK: - Public methods
    public func query(query: String) async -> PostgresRowSequence? {
        let connection = try? await PostgresConnection.connect(configuration: config,
                                                               id: 1,
                                                               logger: logger)
        let rows = try? await connection?.query(PostgresQuery(stringLiteral: query), logger: logger)
        try? await connection?.close()
        return rows
    }
}


