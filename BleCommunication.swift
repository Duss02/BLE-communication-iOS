//
//
//  Created by Michele Dussin on 20/12/21.
//

import UIKit
import Toast

class BleCommunication: UIViewController, BLEDelegate {
	
	@IBOutlet weak var animationview: UIView!
	
	var BLE : BLEControl!
	
	var i = 0
	

	
	
	//find new BLE device
	func newDeviceScanned(_ deviceName: String, localName: String, uuid: UUID, rssi: Int, advertisementData: [AnyHashable : Any]!) {
		if(localName.contains("YourESP32Name")){
			codiceUUID = uuid
		}

	}
	
   
	var statoconnessione = false
	
	
	//called when connection state changes
	func connectionState(_ deviceName: String, state: Bool) {
		statoconnessione = state
		if(!state){
			//not connected
		}else{
			//connected
		
			
		}
		
	}
	

	
	//data received
	func receivedStringValue(_ deviceName: String, dataStr: Data) {
		let datareceived = NSString(data: dataStr, encoding: String.Encoding.utf8.rawValue)
		
		var dato = ""
		guard(datareceived != nil)else{
			return
		}
		
		dato = String(describing: datareceived!)
		print(dato)
		
	}
	
	//call function to send a string 
	func sendData(_ datasend: String){
			BLE.inviaDatoSemplice(datasend)
	}
	
	

	//Disconnect from the device
	@IBAction func Disconnetti(_ sendsender: Any) {
		BLE.disconnectCurrentlyConnectedDevice()
		
	}
		
	//Use the UUID of your esp32 or find it using the newDeviceScanned function
	var codiceUUID : UUID = UUID(uuidString: "9278513B-63CD-BEA4-5DA0-7EBE77CEC9F9")!

   
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//inizializzazione variabili
		BLE = BLEControl(delegate: self)
		
		
		//Conncet to the device using UUID
		if(!statoconnessione){
			if(BLE.connectToDevice(codiceUUID)){
				_ = BLE.connectToDevice(codiceUUID)
				self.view.makeToast("Connecting...", duration: 2.0, position: .bottom)
			}else{
				self.view.makeToast("Can't find the Device", duration: 2.0, position: .bottom)
			}
		}
	}
		
		
		
	
}
