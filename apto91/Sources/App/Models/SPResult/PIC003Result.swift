//
//  PIC003Result.swift
//
//
//  Created by Henrique Alves Batochi on 18/02/24.
//

import Vapor

struct PIC003Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_purchasing: Int?
    
}
