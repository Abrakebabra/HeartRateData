//
//  jsonSerialiser.swift
//  HeartRateData
//
//  Created by Keith Lee on 2020/05/08.
//  Copyright © 2020 Keith Lee. All rights reserved.
//

import Foundation

struct EncodableArray: Encodable {
    let arrayHeartRate: [Int]
}



func serialiser(array: [Int]) throws -> Data {
    
    let encodableArray = EncodableArray(arrayHeartRate: array)
    let encoder = JSONEncoder()
    
    return try encoder.encode(encodableArray)
}
