//
//  PIC001Result.swift
//
//
//  Created by Henrique Alves Batochi on 17/02/24.
//

import Vapor

struct PIC001Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_item: Int?
    
}
