//
//  PurchasingSharedItemRequest.swift
//
//
//  Created by Henrique Alves Batochi on 17/02/24.
//

import Vapor

struct PurchasingSharedItemRequest: Content {
    
    let nrPurchasing: Int?
    let nrItem: Int
    let nrResident: Int
    let nrQuantity: Int
    let vlValue: Decimal
    
}
