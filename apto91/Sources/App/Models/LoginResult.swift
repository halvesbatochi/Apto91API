//
//  LoginResult.swift
//
//
//  Created by Henrique Alves Batochi on 08/02/24.
//

import Foundation
import Vapor

struct LoginResult: Content {
    
    let cd_erro: Decimal
    let ds_erro: String
    let token: String
    
}
