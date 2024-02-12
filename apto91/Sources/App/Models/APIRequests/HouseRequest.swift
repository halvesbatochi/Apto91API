//
//  HouseRequest.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

struct HouseRequest: Content {
    
    let nrHouse: Int?
    let nrResident: Int
    let houseName: String
    let dueDate: Decimal?
    
}

extension HouseRequest: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("houseName",
                        as: String.self,
                        is: .count(...15),
                        customFailureDescription: "Nome da casa excedeu o limite permitido.")
    }
}
