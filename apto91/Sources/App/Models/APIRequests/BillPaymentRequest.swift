//
//  BillPaymentRequest.swift
//
//
//  Created by Henrique Alves Batochi on 13/02/24.
//

import Vapor

struct BillPaymentRequest: Content {
    
    let nrHouse: Int
    let nrResident: Int
    let nrMonthlyBill: Int
    let nrResidentBill: Int
    let dtPayment: Decimal
    
}
