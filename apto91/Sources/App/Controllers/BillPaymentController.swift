//
//  BillPaymentController.swift
//
//
//  Created by Henrique Alves Batochi on 13/02/24.
//

import Vapor

struct BillPaymentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let payment = routes.grouped("billpayment")
        payment.post(use: postPayment)
    }
    
    func postPayment(req: Request) async throws -> String {
        
        return "ok"
    }
}
