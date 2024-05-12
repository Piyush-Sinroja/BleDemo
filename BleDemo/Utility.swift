//
//  Utility.swift
//  BleDemo
//
//  Created by Piyush Sinroja on 07/03/24.
//

extension ClosedRange where Bound == Unicode.Scalar {
    static let asciiPrintable: ClosedRange = " "..."~"
    var range: ClosedRange<UInt32>  { lowerBound.value...upperBound.value }
    var scalars: [Unicode.Scalar]   { range.compactMap(Unicode.Scalar.init) }
    var charactersValue: [Character]     { scalars.map(Character.init) }
    var stringValue: String              { String(scalars) }
}

extension String {
    init<S: Sequence>(_ sequence: S) where S.Element == Unicode.Scalar {
        self.init(UnicodeScalarView(sequence))
    }
}
