//
//  LoginRequest.swift
//
//
//  Created by Henrique Alves Batochi on 10/02/24.
//

import Vapor

struct LoginRequest: Content {
    
    let user: String
    let passw: String
    
}

extension LoginResult: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("user", 
                        as: String.self,
                        is: .count(...30),
                        customFailureDescription: "Usuário excede o limite de caracteres.")
    }
}
