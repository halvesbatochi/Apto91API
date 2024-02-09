//
//  PAD002Result.swift
//
//
//  Created by Henrique Alves Batochi on 09/02/24.
//

import Foundation
import Vapor

struct PAD002Result: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let AD001_NR_MORADOR: Int
    let AD001_VC_NOME: String
    let AD001_VC_SOBREN: String
    let AD001_DT_ENTRADA: Decimal
    
}
