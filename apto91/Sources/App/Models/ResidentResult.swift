//
//  File.swift
//  
//
//  Created by Henrique Alves Batochi on 26/01/24.
//

import Foundation
import Vapor

struct ResidentResult: Content {
    
    let nome: String
    let sobren: String
    let entrada: Decimal
    
    init(nome: String, sobren: String, entrada: Decimal) {
        self.nome = nome
        self.sobren = sobren
        self.entrada = entrada
    }
    
}
