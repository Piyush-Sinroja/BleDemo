//
//  BLEManager+CBPMDelegate.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 06/03/24.
//

import CoreBluetooth

extension BLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
            case .poweredOff:
                print("Is Powered Off.")
                isOnBle = false
            case .poweredOn:
                print("Is Powered On.")
                isOnBle = true
                addService()
            case .unsupported:
                isOnBle = false
                print("Is Unsupported.")
            case .unauthorized:
                isOnBle = false
                print("Is Unauthorized.")
            case .unknown:
                isOnBle = false
                print("Unknown")
            case .resetting:
                isOnBle = false
                print("Resetting")
            @unknown default:
                isOnBle = false
                print("Error")
        }
    }

    func addService() {
        if transferCharacteristic == nil {
            transferCharacteristic = CBMutableCharacteristic(type: charUUID, properties: [.read, .write, .notify], value: nil, permissions: [.readable, .writeable])
            let service =  CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [transferCharacteristic!]
            self.peripheralManager?.add(service)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        print("service: \(service)")
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        print("Succeeded!")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid == charUUID {
            // Set the correspondent characteristic's value
            // to the request
            request.value = transferCharacteristic?.value

            // Respond to the request
            self.peripheralManager?.respond(to: request, withResult: .success)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == charUUID,
               let charValue = request.value {
                // Set the request's value
                // to the correspondent characteristic
                transferCharacteristic?.value = charValue

                let text = String.init(data: charValue, encoding: .utf8)
                print("CBPeripheralManager side write Value: ", text)

                if let jsonStr = text,
                   let dict = convertToDictionary(text: jsonStr) {
                    if let name = dict["name"] as? String  {
                        receivedValue = name
                    }
                    if let isVideoCall = dict["isVideoCall"] as? Bool  {
                        print("isVideoCall", isVideoCall)
                    }
                }

                self.peripheralManager?.respond(to: request, withResult: .success)
            }
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        isConnectedCentral = true
        discoveredCentral = central
        print("subscribed centrals: \(central)")
        //        dataToSend = Data()
        //        sendDataIndex = 0
        //        dataToSend = "good".data(using: .utf8)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        isConnectedCentral = false
        discoveredCentral = nil
        print("UnsubscribeFrom centrals: \(central)")
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {

    }
}
