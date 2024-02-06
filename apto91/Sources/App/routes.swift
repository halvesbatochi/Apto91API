import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: ResidentController())
    try app.register(collection: RootController())
    
}
