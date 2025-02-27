//
//  BinaryFloatingPoint.swift
//  OSCKit • https://github.com/orchetect/OSCKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

// MARK: - BinaryFloatingPoint Default Implementation

extension OSCInterpolatedValue
    where Self: BinaryFloatingPoint,
    CoreOSCValue: BinaryFloatingPoint,
    OSCValueEncodingBlock == OSCValueAtomicEncoder<Self>,
    OSCValueDecodingBlock == OSCValueAtomicDecoder<Self>,
    CoreOSCValue.OSCValueEncodingBlock == OSCValueAtomicEncoder<CoreOSCValue>,
    CoreOSCValue.OSCValueDecodingBlock == OSCValueAtomicDecoder<CoreOSCValue>
{
    public static var oscEncoding: OSCValueEncodingBlock { OSCValueEncodingBlock { value in
        try CoreOSCValue.oscEncoding.block(CoreOSCValue(value))
    } }
    
    public static var oscDecoding: OSCValueDecodingBlock { OSCValueDecodingBlock { decoder in
        Self(try CoreOSCValue.oscDecoding.block(&decoder))
    } }
}

// `Float` (aka `Float32`) is already a core type

#if !(arch(i386) || arch(x86_64)) // Float16 won't compile for Intel
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: OSCInterpolatedValue {
    public typealias CoreOSCValue = Float32
}
#endif

#if !(arch(arm64) || arch(arm) || os(watchOS)) // Float80 is now removed for ARM
extension Float80: OSCInterpolatedValue {
    public typealias CoreOSCValue = Double
}
#endif
