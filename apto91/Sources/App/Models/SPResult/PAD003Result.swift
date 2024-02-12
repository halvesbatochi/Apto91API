//
//  PAD003Result.swift
//
//
//  Created by Henrique Alves Batochi on 11/02/24.
//

import Vapor

struct PAD003Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let nr_house: Int?
    
}
