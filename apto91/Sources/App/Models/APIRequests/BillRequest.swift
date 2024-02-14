//
//  BillRequest.swift
//
//
//  Created by Henrique Alves Batochi on 13/02/24.
//

import Vapor

struct BillRequest: Content {
    
    let nrBill: Int?
    let nrResident: Int
    let nrHouse: Int
    let nrTypeBill: Int
    let dtDDDueDate: Decimal?
    let dtAMDueDate: Decimal
    let vlValue: Decimal
    
}
