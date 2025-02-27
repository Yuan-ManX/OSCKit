//
//  OSCMessage init.swift
//  OSCKit • https://github.com/orchetect/OSCKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
@_implementationOnly import SwiftASCII

// NOTE: Overloads that take variadic values were tested,
// however for code consistency and proper indentation, it is
// undesirable to have variadic parameters.

extension OSCMessage {
    /// Create an OSC message from a raw `String` address pattern and zero or more OSC values (arguments).
    /// The address string will be converted to an ASCII string, lossily converting or removing invalid non-ASCII characters if necessary.
    @inlinable @_disfavoredOverload
    public init(
        _ addressPattern: String,
        values: OSCValues = []
    ) {
        self.addressPattern = OSCAddressPattern(addressPattern)
        self.values = values
        _rawData = nil
    }
    
    /// Create an OSC message from an `OSCAddressPattern` and zero or more OSC values (arguments).
    @inlinable
    public init(
        _ addressPattern: OSCAddressPattern,
        values: OSCValues = []
    ) {
        self.addressPattern = addressPattern
        self.values = values
        _rawData = nil
    }
    
    /// Create an OSC message from OSC address pattern path components and zero or more OSC values (arguments).
    /// Empty path components is equivalent to the address of "/".
    @inlinable
    public init(
        addressPattern pathComponents: some BidirectionalCollection<some StringProtocol>,
        values: OSCValues = []
    ) {
        addressPattern = OSCAddressPattern(pathComponents: pathComponents)
        self.values = values
        _rawData = nil
    }
    
    // MARK: - SwiftASCII typed
    
    /// Create an OSC message from a raw `ASCIIString` address pattern and zero or more OSC values (arguments).
    init(
        asciiAddressPattern address: ASCIIString,
        values: OSCValues = []
    ) {
        addressPattern = OSCAddressPattern(ascii: address)
        self.values = values
        _rawData = nil
    }
    
    /// Create an OSC message from `ASCIIString` OSC address pattern path components and zero or more OSC values (arguments).
    /// Empty path components is equivalent to the address of "/".
    init(
        asciiAddressPattern pathComponents: some BidirectionalCollection<ASCIIString>,
        values: OSCValues = []
    ) {
        addressPattern = OSCAddressPattern(asciiPathComponents: pathComponents)
        self.values = values
        _rawData = nil
    }
}
