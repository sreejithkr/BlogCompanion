//
//  PeripheralManager.swift
//  BLEDemoSwitch
//
//  Created by skr on 06/11/22.
//

import CoreBluetooth
import Foundation
protocol PeripheralDataDelegate: AnyObject {
    func dataRecieved(switch toggle: Bool)
}

class SwitchPeripheralManager  {
    let peripheralManagerDelegate: PeripheralManagerDelegate
    private let peripheralManager: CBPeripheralManager
    
    private var transferCharacteristic: CBMutableCharacteristic?
    var connectedCentral: CBCentral?
    weak var delegate: PeripheralDataDelegate!
  
    
    init() {
        peripheralManagerDelegate = PeripheralManagerDelegate()
        peripheralManager = CBPeripheralManager(
            delegate: peripheralManagerDelegate,
            queue: nil,
            options: [CBPeripheralManagerOptionShowPowerAlertKey: true]
        )
        peripheralManagerDelegate.parent = self
        
    }
    var isPeripheralReady: Bool {
        return peripheralManagerDelegate.periperalReadyStatus
    }
    
    func startAdvertising() {
        
        print(isPeripheralReady)
        
       // setupPeripheral()
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [PeripheralConfigs.serviceUUID]])
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
   
    
    
    func setupPeripheral() {
        
        // Build our service.
        
        // Start with the CBMutableCharacteristic.
        let transferCharacteristic = CBMutableCharacteristic(type: PeripheralConfigs.characteristicUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: PeripheralConfigs.serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [transferCharacteristic]
        
        // And add it to the peripheral manager.
        peripheralManager.add(transferService)
        
        // Save the characteristic for later.
        self.transferCharacteristic = transferCharacteristic

    }
    
    func sendData() {
        guard let transferCharacteristic = transferCharacteristic else {
            return
        }
        
        let data = Data("1".utf8)
        peripheralManager.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil)
    }
    
}


class PeripheralManagerDelegate: NSObject, CBPeripheralManagerDelegate {
    var periperalReadyStatus: Bool = false
    weak var parent: SwitchPeripheralManager!
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch (peripheral.state) {
        case .poweredOn:
            periperalReadyStatus = true
            parent.startAdvertising()
            parent.setupPeripheral()
            print("power on")

         //   parent.setupPeripheral()
        default:
            print("default \(peripheral.state)")
        }
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
      
        // save central
        parent.connectedCentral = central
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
       
        print(requests.first?.value ?? "")
        if let data = requests.first?.value, data.count > 0 {
            let str = String(decoding: data, as: UTF8.self) 
            print(str)
            parent.delegate?.dataRecieved(switch: str == "ON")
        }

        
        
        
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print(request)

    }
    
    
    
    
    
     
    
    
}

