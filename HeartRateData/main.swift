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
let dataSemaphore = DispatchSemaphore(value: 1)
var bpmRecords: [Int] = []

bleController.bpmReceived = {
    bpm in
    print(bpm)
    if bpm > 40 {
        dataSemaphore.wait()
        bpmRecords.append(bpm)
        dataSemaphore.signal()
    }
}






while runProgram {
    print("Awaiting input")
    let input: String? = readLine()
    
    switch input {
    case "end":
        
        bleController.stop()
        
        dataSemaphore.wait()
        
        do {
            let data = try serialiser(array: bpmRecords)
            saveToFile(data: data)
        }
        catch let error {
            print(error)
        }
        
        dataSemaphore.signal()
        
        
    case "exit":
        runProgram = false
        
    default:
        continue
    }
}




