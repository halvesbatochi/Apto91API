//
//  PCC002Result.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

struct PCC002Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_typeBill: Int?
    
}
