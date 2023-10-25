//
//
//  Created by Michele Dussin on 20/12/21.
//

import Foundation
import CoreBluetooth


protocol BLEDelegate {
    
    //Step 1: Recezione del pacchetto BLE device
    func newDeviceScanned(_ deviceName : String, localName : String, uuid: UUID, rssi : Int, advertisementData : [AnyHashable: Any]!)
    
    
    //Step 2: Stato della connessione
    func connectionState(_ deviceName : String, state : Bool)
    
    
    //Step 3: Ricezione dati
    func receivedStringValue(_ deviceName: String, dataStr : Data )
    
}
