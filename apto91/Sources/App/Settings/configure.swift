import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure custom port
    app.http.server.configuration.address = .hostname("0.0.0.0", port: 9180)
    app.jwt.signers.use(.hs256(key: ProcessInfo.processInfo.environment["SECRET_JWT"]!))

    // register routes
    try routes(app)
}
