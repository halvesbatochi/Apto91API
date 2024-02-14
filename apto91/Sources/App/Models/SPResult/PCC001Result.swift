//
//  File.swift
//  
//
//  Created by Henrique Alves Batochi on 13/02/24.
//

import Vapor

struct PCC001Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_bill: Int?
    
}
