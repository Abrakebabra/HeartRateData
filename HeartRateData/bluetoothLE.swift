//
//  bluetoothLE.swift
//  HeartRateData
//
//  Created by Keith Lee on 2020/05/06.
//  Copyright © 2020 Keith Lee. All rights reserved.
//




/*
 Keith's:
 Optional(<CBPeripheral: 0x7fd161404b10, identifier = 2A79F4A2-BC6A-4EF8-B6EF-3704E6FC023F, name = CATEYE_HRM, state = connected>)
 
 Kelsey's:
 Optional(<CBPeripheral: 0x7f9a0b807dd0, identifier = 1E02DD8F-CD49-4DA0-81A3-FE3AA31CF73C, name = CATEYE_HRM, state = connected>)
 */

import Foundation
import CoreBluetooth





class BLEController: CBCentralManager {
    
    var btQueue = DispatchQueue(label: "BT Queue")
    
    var bpmReceived: ((Int) -> Void)?
    
    var bpm: Int? {
        didSet {
            self.bpmReceived?(self.bpm!)
        }
    }
    
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let batteryLevelCharacteristicCBUUID = CBUUID(string: "2A19")
    
    
    
    func start() -> Void {
        print("bluetooth started")
        self.centralManager = CBCentralManager(delegate: self, queue: self.btQueue)
    }
    
    
    func stop() -> Void {
        centralManager.cancelPeripheralConnection(heartRatePeripheral)
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(heartRatePeripheral)
    }
    
    
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print("Connected to HRM!")
        heartRatePeripheral.discoverServices(nil)
    }
    
    
    func onHeartRateReceived(_ heartRate: Int) {
        self.bpm = heartRate
    }
}



extension BLEController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager)  {
        switch central.state {
        case .poweredOff:
            print("Bluetooth central manager is off")
        case .poweredOn:
            print("Bluetooth central manager is on")
            sleep(1)
            centralManager.scanForPeripherals(withServices: [self.heartRateServiceCBUUID])
        case .resetting:
            print("Bluetooth central manager is resetting")
        case .unauthorized:
            print("Bluetooth central manager is unauthorized")
        case .unsupported:
            print("Bluetooth central manager is unsupported")
        case .unknown:
            print("Bluetooth central manager is in unknown state")
        default:
            print("Bluetooth central manager state is other")
        }
    }
}



extension BLEController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case batteryLevelCharacteristicCBUUID:
            let percent = batteryLevel(from: characteristic)
            print("Battery level: \(percent)%")
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            return
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    
    private func batteryLevel(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        return Int(byteArray[0])
    }
    
}



