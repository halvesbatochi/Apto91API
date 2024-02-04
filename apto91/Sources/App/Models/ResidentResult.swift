//
//  File.swift
//  
//
//  Created by Henrique Alves Batochi on 26/01/24.
//

import Foundation
import Vapor

struct ResidentResult: Content {
    
    var nome: String
    var sobren: String
    
    init(nome: String, sobren: String) {
        self.nome = nome
        self.sobren = sobren
    }
    
}
