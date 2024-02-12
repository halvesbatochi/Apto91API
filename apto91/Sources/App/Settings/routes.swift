import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: RootController())
    try app.register(collection: LoginController())
    try app.register(collection: SignUpController())
    try app.register(collection: HouseController())
    try app.register(collection: TypeBillsController())

}
