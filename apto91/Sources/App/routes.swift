import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("hello", ":name") { req -> String in
    
        guard let name = req.parameters.get("name") else {
            throw Abort(.internalServerError)
        }
        
        return "Hello, \(name)!"
    }
}
