//
//  BLEManager+CBPDelegate.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 06/03/24.
//

import Foundation
import CoreBluetooth

//MARK: - CBPeripheralDelegate
extension BLEManager : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error?.localizedDescription)")
            cleanup()
            return
        }

        if let services = peripheral.services {
            //discover characteristics of services
            for service in services {
                peripheral.discoverCharacteristics([charUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error?.localizedDescription)")
            cleanup()
            return
        }

        if let characteristic = service.characteristics?.first(where: {$0.uuid == charUUID}) {
            cbSideCharacteristic = characteristic
            discoveredPeripheral?.setNotifyValue(true, for: characteristic)
            discoveredPeripheral?.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            return
        }
        if characteristic.uuid == charUUID,
           let charValue = characteristic.value {
            cbData = Data()
            cbData?.append(charValue)

            let text = String.init(data: charValue, encoding: .utf8)
            print("CBPeripheral side write Value: ", text)
            receivedValue = text ?? "No Value"
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == charUUID {
            if characteristic.isNotifying {
                print("Notification began on \(characteristic)")
            } else {
                print("Notification stopped on \(characteristic) disconnecting")
                //cbCentralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("WRITE VALUE : \(characteristic)")
    }

    func sendDataThroughBLEForIncomingCall(displayName: String) {
//        guard let characteristic = cbSideCharacteristic else {
//            return
//        }
//        let dictionary: [String: Any] = ["name": displayName, "isVideoCall": true]
//        if let theJSONData = try?  JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
//           let theJSONText = String(data: theJSONData, encoding: .utf8),
//           let data = theJSONText.data(using: .utf8) {
//            print("JSON string = \n\(theJSONText)")
//            self.discoveredPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
//        }
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
