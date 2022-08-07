//
//  OSCBundle Integrity Tests.swift
//  OSCKit • https://github.com/orchetect/OSCKit
//

#if shouldTestCurrentPlatform

import XCTest
import OSCKitCore

final class OSCBundle_Integrity_Tests: XCTestCase {
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    // MARK: - Constructors
    
    func testConstructors() throws {
        // empty
        
        let emptyBundle = OSCBundle(elements: [])
        XCTAssertEqual(emptyBundle.timeTag.rawValue, 1)
        XCTAssertEqual(emptyBundle.elements.count, 0)
        
        // timetag only
        
        let timeTagOnly = OSCBundle(
            elements: [],
            timeTag: .init(20)
        )
        XCTAssertEqual(timeTagOnly.timeTag.rawValue, 20)
        XCTAssertEqual(timeTagOnly.elements.count, 0)
        
        // elements only
        
        let elementsOnly = OSCBundle(elements: [.message(address: "/")])
        XCTAssertEqual(elementsOnly.timeTag.rawValue, 1)
        XCTAssertEqual(elementsOnly.elements.count, 1)
        
        // timetag and elements
        
        let elementsAndTT = OSCBundle(
            elements: [.message(address: "/")],
            timeTag: .init(20)
        )
        XCTAssertEqual(elementsAndTT.timeTag.rawValue, 20)
        XCTAssertEqual(elementsAndTT.elements.count, 1)
        
        // raw data
        
        let rawData = try OSCBundle(from: OSCBundle.header + 20.int64.toData(.bigEndian))
        XCTAssertEqual(rawData.timeTag.rawValue, 20)
        XCTAssertEqual(rawData.elements.count, 0)
    }
    
    // MARK: - Complex messages
    
    func testComplex() {
        // this does not necessarily prove that encoding or decoding actually matches OSC spec, it simply ensures that rawData that OSCBundle generates can be decoded
        
        // build bundle
        
        let oscBundle = OSCBundle(
            elements:
            [
                // element 1
                .bundle(elements: [.message(address: "/bundle1/msg")]),
                
                // element 2
                .bundle(elements: [
                    .message(
                        address: "/bundle2/msg1",
                        values: [
                            .int32(500_000),
                            .string("some string here")
                        ]
                    ),
                    .message(
                        address: "/bundle2/msg2",
                        values: [
                            .float32(8795.4556),
                            .int32(75)
                        ]
                    )
                ]),
                
                // element 3
                .message(
                    address: "/msg1",
                    values: [.blob(Data([1, 2, 3]))]
                ),
                
                // element 4
                .bundle(elements: [])
            ]
        )
        
        // encode
        
        let encodedOSCbundle = oscBundle.rawData
        
        // decode
        
        let decodedOSCbundle = try! OSCBundle(from: encodedOSCbundle)
        
        // verify contents
        
        XCTAssertEqual(decodedOSCbundle.timeTag.rawValue, 1)
        XCTAssertEqual(decodedOSCbundle.elements.count, 4)
        
        // element 1
        guard case let .bundle(element1) = decodedOSCbundle.elements[safe: 0]
        else { XCTFail(); return }
        
        XCTAssertEqual(element1.timeTag.rawValue, 1)
        XCTAssertEqual(element1.elements.count, 1)
        
        guard case let .message(element1A) = element1.elements[safe: 0]
        else { XCTFail(); return }
        
        XCTAssertEqual(element1A.address, "/bundle1/msg")
        XCTAssertEqual(element1A.values.count, 0)
        
        // element 2
        guard case let .bundle(element2) = decodedOSCbundle.elements[safe: 1]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2.timeTag.rawValue, 1)
        XCTAssertEqual(element2.elements.count, 2)
        
        guard case let .message(element2A) = element2.elements[safe: 0]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2A.address, "/bundle2/msg1")
        XCTAssertEqual(element2A.values.count, 2)
        
        guard case let .int32(element2A1) = element2A.values[safe: 0]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2A1, 500_000)
        
        guard case let .string(element2A2) = element2A.values[safe: 1]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2A2, "some string here")
        
        guard case let .message(element2B) = element2.elements[safe: 1]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2B.address, "/bundle2/msg2")
        XCTAssertEqual(element2B.values.count, 2)
        
        guard case let .float32(element2B1) = element2B.values[safe: 0]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2B1, 8795.4556)
        
        guard case let .int32(element2B2) = element2B.values[safe: 1]
        else { XCTFail(); return }
        
        XCTAssertEqual(element2B2, 75)
        
        // element 3
        guard case let .message(element3) = decodedOSCbundle.elements[safe: 2]
        else { XCTFail(); return }
        XCTAssertEqual(element3.values.count, 1)
        XCTAssertEqual(element3.address, "/msg1")
        
        // element 4
        guard case let .bundle(element4) = decodedOSCbundle.elements[safe: 3]
        else { XCTFail(); return }
        XCTAssertEqual(element4.timeTag.rawValue, 1)
        XCTAssertEqual(element4.elements.count, 0)
    }
}

#endif
