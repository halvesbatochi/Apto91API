import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: LoginController())
    try app.register(collection: ResidentController())
    try app.register(collection: RootController())
    
    
    
    
    app.get("me") { req -> HTTPStatus in
        let payload = try req.jwt.verify(as: JwtPayload.self)
        req.logger.info(Logger.Message(stringLiteral: payload.subject.value))
        return .ok
    }
    
    app.post("me") { req -> [String: String] in
    
        // Create a new instance of our JWTPayload
        let payload = JwtPayload(subject: "vaporApto", 
                                 expiration: .init(value: .distantFuture),
                                 isAdmin: true)
        // Return the signed JWT
        return try [
            "token" : req.jwt.sign(payload)
        ]
    }
    
}
