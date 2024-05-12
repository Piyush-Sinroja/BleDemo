//
//  BLEManager.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 06/03/24.
//

import Foundation
import CoreBluetooth

enum Constants: String {
    case SERVICE_UUID = "2DF91029-B356-463E-9F48-BAB077BF3EF5"
    case CHARACTERISTIC_UUID = "07598F7E-DB05-467E-8757-72F6FAEB13D4"
}

let charUUID = CBUUID(string: Constants.CHARACTERISTIC_UUID.rawValue)
let serviceUUID = CBUUID(string: Constants.SERVICE_UUID.rawValue)

class BLEManager: NSObject, ObservableObject {

    enum DeviceType {
        case central
        case peripheral
        case none
    }

    @Published var cbCentralManager : CBCentralManager!
    @Published var cbData: Data?
    @Published var discoveredPeripheral : CBPeripheral?
    @Published var discoveredCentral : CBCentral?
    @Published var cbSideCharacteristic: CBCharacteristic?
    @Published var transferCharacteristic: CBMutableCharacteristic?
    var name = "iPhone13"
    @Published var peripheralManager: CBPeripheralManager?
    @Published var isOnBle: Bool = false
    @Published var scannedPeripherals: [CBPeripheral] = []
    @Published var isConnectedPeripheral = false
    @Published var isConnectedCentral = false
    @Published var receivedValue = ""
    @Published var deviceTupe = ""
    static let shared = BLEManager()

    @Published var deviceType = DeviceType.none

    private override init() {
        super.init()
    }

    func selectDeviceType(deviceType: DeviceType) {
        if deviceType == .central {
            cbCentralManager = CBCentralManager(delegate: self, queue: nil)
        } else if deviceType == .peripheral {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
        self.deviceType = deviceType
    }

    func scan() {
        if cbCentralManager.isScanning {
            cbCentralManager.stopScan()
        }
        cbCentralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        print("Scanning...")
    }

    func advertisePheripheral(isOn: Bool) {
        if isOn {
            var advertisingData: [String : Any] = [CBAdvertisementDataLocalNameKey: name, CBAdvertisementDataServiceUUIDsKey: [serviceUUID]]
            self.peripheralManager?.startAdvertising(advertisingData)
        } else {
            self.peripheralManager?.stopAdvertising()
        }
    }

    func connectWithPeripheral(peripheral: CBPeripheral) {
        cbCentralManager.connect(peripheral, options: nil)
    }

    func sendFromCentralName(charValue: String, count: Int, isRandom: Bool) {
        guard let characteristic = cbSideCharacteristic else {
            return
        }

        var sendChar = charValue

        if isRandom {
            sendChar = randomString(length: count)
        }

        let dictionary = ["name": sendChar]
        if let theJSONData = try?  JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let theJSONText = String(data: theJSONData, encoding: .utf8),
           let data = theJSONText.data(using: .utf8) {
            print("JSON string = \n\(theJSONText)")
            self.discoveredPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    }

    func sendFromPeripheral(charValue: String, count: Int, isRandom: Bool) {

        var sendChar = charValue

        if isRandom {
            sendChar = randomString(length: count)
        }

        guard let transferCharacteristic,
              let data = sendChar.data(using: .utf8) else { return }
        transferCharacteristic.value = data
        self.peripheralManager?.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: discoveredCentral == nil ? nil : [discoveredCentral!])
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func automaticConnectWithBle(peripheral: CBPeripheral) {
        cbCentralManager.connect(peripheral)
    }

    deinit {
        cbCentralManager.stopScan()
    }
}
