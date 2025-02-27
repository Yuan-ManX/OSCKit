//
//  OSCValueDecodable.swift
//  OSCKit • https://github.com/orchetect/OSCKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

public protocol OSCValueDecodable {
    associatedtype OSCDecoded: OSCValueDecodable
    associatedtype OSCValueDecodingBlock: OSCValueDecoderBlock
        where OSCValueDecodingBlock.OSCDecoded == OSCDecoded
    static var oscDecoding: OSCValueDecodingBlock { get }
}

// MARK: - Default Implementation

extension OSCValueDecodable {
    public typealias OSCDecoded = Self
}
