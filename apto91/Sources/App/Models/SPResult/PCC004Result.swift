//
//  PCC004Result.swift
//
//
//  Created by Henrique Alves Batochi on 14/02/24.
//

import Vapor

struct PCC004Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_residentBill: Int?
    
}
