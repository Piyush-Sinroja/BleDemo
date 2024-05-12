//
//  BLEManager+CBCMDelegate.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 06/03/24.
//
import Foundation
import CoreBluetooth

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                isOnBle = false
                print("Is Powered Off.")
            case .poweredOn:
                print("Is Powered On.")
                isOnBle = true
                scan()
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
       // print("RSSI.intValue \(RSSI.intValue)")

        guard peripheral.name != nil else {return}

        if discoveredPeripheral != peripheral,
           !scannedPeripherals.contains(peripheral) {
            print("peripheral ", peripheral.identifier)
            print("peripheral ", peripheral.name)
               scannedPeripherals.append(peripheral)
           }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected : \(peripheral.name ?? "No Name")")
        self.discoveredPeripheral = peripheral
        isConnectedPeripheral = true
        
        cbCentralManager?.stopScan()
        cbData = nil
        //it' discover all service
        //peripheral.discoverServices(nil)
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected : \(peripheral.name ?? "No Name")")
        discoveredPeripheral = nil
        isConnectedPeripheral = false
        cbSideCharacteristic = nil
        // We're disconnected, so start scanning again
       // BLEManager.shared.automaticConnectWithBle(peripheral: peripheral)
        scan()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral). \(error?.localizedDescription)")
        cleanup()
    }

    func cleanup() {
        guard let discoveredPeripheral,
              discoveredPeripheral.state == CBPeripheralState.connected else {
            return
        }

        if self.discoveredPeripheral?.services != nil {
            for service in self.discoveredPeripheral?.services ?? [] {
                if service.characteristics != nil {
                    for charac in service.characteristics ?? [] {
                        if charac.uuid == charUUID {
                            cbSideCharacteristic = nil
                            if charac.isNotifying {
                                discoveredPeripheral.setNotifyValue(false, for: charac)
                                return
                            }
                        }
                    }
                }
            }
        }

        cbCentralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
}
