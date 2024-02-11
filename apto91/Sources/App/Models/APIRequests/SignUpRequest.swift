//
//  SignUpRequest.swift
//  
//
//  Created by Henrique Alves Batochi on 10/02/24.
//

import Vapor

struct SignUpRequest: Content {
    
    let nrResident: Int?
    let name: String
    let lastName: String
    let cpf: String
    let email: String
    let login: String
    let passw: String
    let startDate: Decimal
    let tpResident: Int
    
}

extension SignUpRequest: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name",
                        as: String.self,
                        is: .count(...30),
                        customFailureDescription: "Nome excedeu o limite permitido.")
        
        validations.add("lastName",
                        as: String.self,
                        is: .count(...50),
                        customFailureDescription: "Sobrenome excedeu o limite permitido.")
        
        validations.add("cpf",
                        as: String.self,
                        is: .count(11...11),
                        customFailureDescription: "CPF precisa conter 11 dígitos.")
        
        validations.add("email",
                        as: String.self,
                        is: .count(...150),
                        customFailureDescription: "Email excedeu o limite permitido.")
        
        validations.add("email", 
                        as: String.self,
                        is: .email,
                        customFailureDescription: "Email precisa ser válido.")
        
        validations.add("login",
                        as: String.self,
                        is: .count(...30),
                        customFailureDescription: "Login excedeu o limite permitido.")
    }
    
    
}
