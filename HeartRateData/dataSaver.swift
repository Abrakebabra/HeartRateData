//
//  dataSaver.swift
//  HeartRateData
//
//  Created by Keith Lee on 2020/05/08.
//  Copyright © 2020 Keith Lee. All rights reserved.
//

import Foundation


func saveToFile(data: Data) {
    
    // get documents directory
    guard var directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        
        print("directory not found")
        return
    }
    
    directory.appendPathComponent("DataLife/HeartRate", isDirectory: true)
    
    var fileIteration: Int = 1
    var availableFileName: Bool = false
    // whole url to the .json document
    var fileURL: URL?
    
    
    while availableFileName == false {
        let stringedIteration = String(format: "%02d", fileIteration)
        let file = "HeartRateData \(stringedIteration).json"
        let checkingURL = directory.appendingPathComponent(file)
        
        //reading to see if file exists
        do {
            let _ = try String(contentsOf: checkingURL, encoding: .utf8)
            fileIteration += 1
            continue
        }
        catch {
            fileURL = checkingURL
            availableFileName = true
            break
        }
        
    } // while availableFileName
    
    
    if let fileURL = fileURL {
        do {
            try data.write(to: fileURL, options: .atomic)
        }
        catch let error {
            print(error)
        }
        
    }
    
}
