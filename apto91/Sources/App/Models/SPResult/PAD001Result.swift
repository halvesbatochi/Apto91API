//
//  File.swift
//  
//
//  Created by Henrique Alves Batochi on 10/02/24.
//

import Vapor

struct PAD001Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_morador: Int?
    
}
