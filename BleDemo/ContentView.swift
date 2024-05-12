//
//  ContentView.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 06/03/24.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {

    @EnvironmentObject var bleManager: BLEManager
    @State var isStartOn = false
    @State var isRandomString = false
    @State private var selection: CBPeripheral?

    let charArray = ("a"..."z").charactersValue

    private let flexibleColumn = [
        GridItem(.flexible(minimum: 50, maximum: 200)),
        GridItem(.flexible(minimum: 50, maximum: 200)),
        GridItem(.flexible(minimum: 50, maximum: 200))
    ]

    let filterOption: [String] = [
        "+", "-",
    ]

    @State var charCount = 1

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .blue

        UISegmentedControl.appearance().backgroundColor = .yellow

        let attribute: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.red
        ]

        UISegmentedControl.appearance().setTitleTextAttributes(attribute, for: .selected)
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            VStack {
                if bleManager.deviceType == .none {
                    deviceTypeView
                } else {
                    Text("Bluetooth is: \(bleManager.isOnBle ? "ON" : "OFF")")
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundStyle(bleManager.isOnBle ? .green : .red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .shadow(radius: 5)
                        .padding(.bottom, 10)

                    if bleManager.deviceType == .central {
                        if bleManager.isConnectedPeripheral {
                            connectedView
                        } else {
                            List(bleManager.scannedPeripherals, id: \.self, selection: $selection) { peripheral in
                                Button(action: {
                                    bleManager.connectWithPeripheral(peripheral: peripheral)
                                }, label: {
                                    Text("\(peripheral.name ?? "No Name")")
                                        .foregroundStyle(Color.mint)
                                })
                            }
                        }
                    } else {
                        if bleManager.isConnectedCentral {
                            connectedView
                        } else {
                            Toggle(isOn: $isStartOn) {
                                Text("Start Advertising")
                                    .foregroundStyle(Color.mint)
                            }
                            .onChange(of: isStartOn) { value in
                                bleManager.advertisePheripheral(isOn: isStartOn)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.red))
                            .padding()
                        }
                    }
                }
            }
        }
    }

    var connectedView: some View {
        VStack {
            Text("Received Value: \(bleManager.receivedValue)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.black)

            Text("Received bytes: \(bleManager.receivedValue.utf8.count) Bytes")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.black)

            Toggle(isOn: $isRandomString) {
                Text("Random String")
                    .foregroundStyle(Color.red)
            }
            .onChange(of: isRandomString) { value in

            }
            .toggleStyle(SwitchToggleStyle(tint: Color.red))
            .padding()

            if isRandomString {
                HStack {
                    HStack {
                        Button {
                            charCount -= 10
                            if charCount < 1 {
                                charCount = 1
                            }
                        } label: {
                            Circle()
                                .strokeBorder(.red, lineWidth: 1)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("-")
                                        .foregroundStyle(Color.red)
                                )
                        }

                        Spacer()

                        Text(charCount.description)
                            .foregroundStyle(Color.red)
                            .background(Color.white)
                            .cornerRadius(10)

                        Spacer()

                        Button {
                            charCount += 10
                            if charCount > 1000 {
                                charCount = 1000
                            }
                        } label: {
                            Circle()
                                .strokeBorder(.red, lineWidth: 1)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("+")
                                        .foregroundStyle(Color.red)
                                )
                        }
                    }
                    .font(.system(size: 40, weight: .bold))
                    .padding(.leading, 15)

                    Spacer()
                }

            }

            if isRandomString {
                Button(action: {
                    if bleManager.isConnectedPeripheral {
                        bleManager.sendFromCentralName(charValue: "", count: charCount, isRandom: isRandomString)
                    } else if bleManager.isConnectedCentral {
                        bleManager.sendFromPeripheral(charValue: "", count: charCount, isRandom: isRandomString)
                    }
                }, label: {
                    Text("Send")
                        .frame(width: 100, height: 100, alignment: .center)
                        .background(.red)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .font(.title)
                })
            } else {
                ScrollView {
                    LazyVGrid(columns: flexibleColumn, spacing: 10) {
                        ForEach(Array(charArray.enumerated()), id: \.element) { index, element in
                            Button(action: {
                                if bleManager.isConnectedPeripheral {
                                    bleManager.sendFromCentralName(charValue: String(element), count: charCount, isRandom: isRandomString)
                                } else if bleManager.isConnectedCentral {
                                    bleManager.sendFromPeripheral(charValue: String(element), count: charCount, isRandom: isRandomString)
                                }
                            }, label: {
                                Text(String(element))
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 40)/3,
                                           minHeight: (UIScreen.main.bounds.width - 40)/3,
                                           maxHeight: (UIScreen.main.bounds.width - 40)/3, alignment: .center)
                                    .background(index % 2 == 0 ? .red : .green)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .font(.title)
                            })
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
    var deviceTypeView: some View {
        VStack {
            Text ("Select your device as a")
                .font(.title)
                .padding(.bottom, 10)
                .foregroundStyle(Color.red)

            Button {
                bleManager.selectDeviceType(deviceType: .central)
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 150, height: 150)
                    .shadow(radius: 10)
                    .overlay(
                        Text("Central")
                            .fontWeight(.bold)
                            .font(.title)
                            .foregroundStyle(.red)
                    )
            }

            Button {
                bleManager.selectDeviceType(deviceType: .peripheral)
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 150, height: 150)
                    .shadow(radius: 10)
                    .overlay(
                        Text("Peripheral")
                            .fontWeight(.bold)
                            .font(.title)
                            .foregroundStyle(.red)
                    )
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BLEManager.shared)
}
