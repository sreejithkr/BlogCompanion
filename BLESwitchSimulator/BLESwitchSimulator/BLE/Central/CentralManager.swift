import CoreBluetooth

class CentralManager {
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    var bleDelegate: BLEDelegateImpl = BLEDelegateImpl()
    
    init() {
        centralManager = CBCentralManager(delegate: bleDelegate, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        bleDelegate.parent = self

    }
    
    func wirte(data value: String) {
        guard let discoveredPeripheral = discoveredPeripheral,
                let transferCharacteristic = transferCharacteristic
            else { return }
        if discoveredPeripheral.canSendWriteWithoutResponse {
            let data = Data(value.utf8)
            discoveredPeripheral.writeValue(data, for: transferCharacteristic, type: .withoutResponse)
        }
    }
    
    func scanPeripherals() {
        centralManager?.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func setupPeripherals(peripheral: CBPeripheral) {
        if discoveredPeripheral == nil {
            discoveredPeripheral = peripheral
            discoveredPeripheral?.delegate = bleDelegate
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    
}

class BLEDelegateImpl: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    weak var parent: CentralManager?
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("central.state \(central.state.rawValue)")    
        default:
            print("central.state \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("centralManager peripheral discovered")
        parent?.setupPeripherals(peripheral: peripheral)

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect peripheral")
        parent?.discoveredPeripheral?.discoverServices([CentralConfigs.serviceUUID])


    }
    
    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let _ = error {
            return
        }
        
        print("didDiscoverServices")

        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([CentralConfigs.characteristicUUID], for: service)
        }
    }
    
 
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let _ = error {
            
            return
        }
        print("didDiscoverCharacteristicsFor")

        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == CentralConfigs.characteristicUUID {
            parent?.transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
    }
    
}
