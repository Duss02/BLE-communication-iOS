//
//
//  Created by Michele Dussin on 20/12/21.
//

import Foundation
import CoreBluetooth


class BLEControl : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    let SERVIZIO : CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let CARATTERISTICA : CBUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    var centralManager : CBCentralManager!
    var delegate : BLEDelegate!
    var foundDevices : NSMutableDictionary!
    var dispositivoCorrente : CBPeripheral?
    var currentInvia : CBCharacteristic?
    var currentRicevi : CBCharacteristic?
    
    
    
    
    init(delegate : BLEDelegate){
        super.init()
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
        foundDevices = NSMutableDictionary()
    }
    
    
    func disconnectCurrentlyConnectedDevice(){
        if(dispositivoCorrente != nil){
            centralManager.cancelPeripheralConnection(dispositivoCorrente!)
        }
    }
    
    
    func bleScan(_ start: Bool){
        if(start){
            foundDevices.removeAllObjects()
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        } else {
            centralManager.stopScan()
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name;
        if(deviceName != nil){
            let localName : String? = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            if(localName != nil
                && foundDevices.object(forKey: peripheral.identifier) == nil){
                foundDevices.setObject(peripheral, forKey: peripheral.identifier as NSCopying)
                delegate.newDeviceScanned(deviceName!, localName : localName!, uuid: peripheral.identifier, rssi: RSSI.intValue, advertisementData: advertisementData)
            }
        }
    }
    
    
    func connectToDevice(_ uuid : UUID!) -> Bool{
        let device : CBPeripheral? = foundDevices.object(forKey: uuid!) as? CBPeripheral
        if(device == nil){
            return false
        }else{
            bleScan(false)
            centralManager.connect(device!, options: nil)
            
            return true
        }
    }

    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        dispositivoCorrente = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate.connectionState(peripheral.name!, state: true)
    }

    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate.connectionState(peripheral.name!, state: false)
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        dispositivoCorrente = nil
        currentInvia = nil
        currentRicevi = nil
        delegate.connectionState(peripheral.name!, state: false)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        
        switch (central.state){
        case .unsupported:
            print("BLE not supported")
        case .unauthorized:
            print("BLE non authorized")
        case .unknown:
            print("BLE error")
        case .resetting:
            print("BLE restarting")
        case .poweredOff:
            print("BLE power off")
        case .poweredOn:
            print("BLE power on")
            print("Start scanning")
            central.scanForPeripherals(withServices: nil , options: nil)
        default:
            break
          
        }
    }
    
    
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services
        for service in services! {
            let cbService = service
			peripheral.discoverCharacteristics(nil, for: cbService)
			break
            
        }
    }
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        let characteristics = service.characteristics
        for characteristic in characteristics! {
            let cbCharacteristic  = characteristic
            currentInvia = cbCharacteristic
            currentRicevi = cbCharacteristic
            peripheral.setNotifyValue(true, for: currentRicevi!)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		let charValue : Data = characteristic.value! as Data
		delegate.receivedStringValue(peripheral.name!, dataStr: charValue)
            
        
    }
    
    
    func inviaDatoSemplice(_ dato1: String){
        if (!dato1.isEmpty){
            writeString("\(dato1)")
        }}
    
    
    func writeString(_ string:String){
        let contData = string.count

        let data = Data(bytes: string, count: contData)
        if ((currentInvia) != nil){
            dispositivoCorrente?.writeValue(data, for: currentInvia!, type: CBCharacteristicWriteType.withResponse)
        }else{
            print("errore")
        }}
    
}


