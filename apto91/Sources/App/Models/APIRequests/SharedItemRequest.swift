//
//  SharedItem.swift
//
//
//  Created by Henrique Alves Batochi on 17/02/24.
//

import Vapor

struct SharedItemRequest: Content {
    
    let nrHouse: Int
    let nrResident: Int
    let nrItem: Int?
    let vcItem: String
    
}

extension SharedItemRequest: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("vcItem",
                        as: String.self,
                        is: .count(...40),
                        customFailureDescription: "Nome do item excedeu o limite permitido.")
    }
}
