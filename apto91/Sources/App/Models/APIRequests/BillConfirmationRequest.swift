//
//  BillConfirmationRequest.swift
//
//
//  Created by Henrique Alves Batochi on 14/02/24.
//

import Vapor

struct BillConfirmationRequest: Content {
    
    let nrHouse: Int
    let nrAdm: Int
    let nrResident: Int
    let nrMonthlyBill: Int
    let nrResidentBill: Int
    
}
