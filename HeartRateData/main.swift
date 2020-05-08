//
//  main.swift
//  HeartRateData
//
//  Created by Keith Lee on 2020/05/06.
//  Copyright © 2020 Keith Lee. All rights reserved.
//

import Foundation

let bleController = BLEController()
bleController.start()

var runProgram: Bool = true


var bpmRecords: [Int] = []

bleController.bpmReceived = {
    bpm in
    print(bpm)
    if bpm > 40 {
        bpmRecords.append(bpm)
    }
}










while runProgram {
    print("Awaiting input")
    let input: String? = readLine()
    
    switch input {
    case "end":
        let data = serialiser(array: bpmRecords)
        
    }
    
}




