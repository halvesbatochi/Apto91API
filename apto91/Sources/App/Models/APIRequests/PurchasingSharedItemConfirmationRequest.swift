//
//  PurchasingSharedItemConfirmationRequest.swift
//
//
//  Created by Henrique Alves Batochi on 18/02/24.
//

import Vapor

struct PurchasingSharedItemConfirmationRequest: Content {
    
    let nrHouse: Int
    let nrResident: Int
    let nrItem: Int
    let nrPurchasing: Int
    
}
