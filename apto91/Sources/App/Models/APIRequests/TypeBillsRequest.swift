//
//  TypeBillsRequest.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

struct TypeBillsRequest: Content {
    
    let nrTypeBill: Int?
    let nrResident: Int
    let nrHouse: Int
    let descBill: String
    let recurringBill: Decimal
    
}

extension TypeBillsRequest: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("descBill",
                        as: String.self,
                        is: .count(...15),
                        customFailureDescription: "Descrição da conta excedeu o limite permitido.")
    }
}
