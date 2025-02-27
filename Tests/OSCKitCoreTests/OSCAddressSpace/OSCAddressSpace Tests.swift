//
//  OSCAddressSpace Tests.swift
//  OSCKit • https://github.com/orchetect/OSCKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

import XCTest
import OSCKitCore

final class OSCAddressSpace_Tests: XCTestCase {
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    // MARK: - Address Registration
    
    func testRegisterAddress_PathComponents() throws {
        let addressSpace = OSCAddressSpace()
        
        let t1ID = addressSpace.register(localAddress: ["test1"])
        let t2ID = addressSpace.register(localAddress: ["test1", "test2"])
        let t3ID = addressSpace.register(localAddress: ["test3", "test4"])
        
        // basic verbatim match to check if register worked
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1")),
            [t1ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2")),
            [t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test3/test4")),
            [t3ID]
        )
    }
    
    func testUnregisterAddress() throws {
        let addressSpace = OSCAddressSpace()
        
        let t1ID = addressSpace.register(localAddress: "/test1/test3/methodA"); _ = t1ID
        let t2ID = addressSpace.register(localAddress: "/test2/test4/methodB")
        
        XCTAssertTrue(
            addressSpace.unregister(localAddress: "/test1/test3/methodA")
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test3/methodA")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test2/test4/methodB")),
            [t2ID]
        )
        
        // containers still exist
        
        XCTAssert(
            addressSpace.methods(matching: .init("/test1")).count == 1
        )
        
        XCTAssert(
            addressSpace.methods(matching: .init("/test1/test3")).count == 1
        )
    }
    
    func testUnregisterAddress_PathComponents() throws {
        let addressSpace = OSCAddressSpace()
        
        let t1ID = addressSpace.register(localAddress: "/test1/test3/methodA"); _ = t1ID
        let t2ID = addressSpace.register(localAddress: "/test2/test4/methodB")
        
        XCTAssertTrue(
            addressSpace.unregister(localAddress: ["test1", "test3", "methodA"])
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test3/methodA")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test2/test4/methodB")),
            [t2ID]
        )
        
        // containers still exist
        
        XCTAssert(
            addressSpace.methods(matching: .init("/test1")).count == 1
        )
        
        XCTAssert(
            addressSpace.methods(matching: .init("/test1/test3")).count == 1
        )
    }
    
    func testUnregisterAllAddresses() throws {
        let addressSpace = OSCAddressSpace()
        
        let _ = addressSpace.register(localAddress: "/test1/test3/methodA")
        let _ = addressSpace.register(localAddress: "/test2/test4/methodB")
        
        addressSpace.unregisterAll()
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test3/methodA")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test2/test4/methodB")),
            []
        )
        
        // containers still exist
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test3")),
            []
        )
    }
    
    // MARK: - Matches
    
    func testMethodsMatching_Root() throws {
        let addressSpace = OSCAddressSpace()
        
        let t1ID = addressSpace.register(localAddress: "/test1")
        let t2ID = addressSpace.register(localAddress: "/test2")
        let _ = addressSpace.register(localAddress: "/test1/test1B") // not tested
        
        // non-matches
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test")),
            []
        )
        
        // verbatim matches
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1")),
            [t1ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test2")),
            [t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/")),
            [t1ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test2/")),
            [t2ID]
        )
        
        // wildcards
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test?")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test*")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test[12]")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test[!3]")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test{1,2}")),
            [t1ID, t2ID]
        )
        
        // edge cases
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/")),
            []
        )
    }
    
    func testMethodsMatching_NestedMethods() throws {
        let addressSpace = OSCAddressSpace()
        
        let t1ID = addressSpace.register(localAddress: "/test1/test2/methodA")
        let t2ID = addressSpace.register(localAddress: "/test1/test2/methodB")
                
        // non-matches
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/method")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/methodAA")),
            []
        )
        
        // verbatim matches
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/methodA")),
            [t1ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/methodB")),
            [t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/methodA/")),
            [t1ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/methodB/")),
            [t2ID]
        )
        
        // wildcards
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/method?")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/method*")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/method[AB]")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/method[!C]")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test1/test2/method{A,B}")),
            [t1ID, t2ID]
        )
        
        // edge cases
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("")),
            []
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/")),
            []
        )
    }
    
    func testMethodsMatching_MultipleContainerMatches() throws {
        let addressSpace = OSCAddressSpace()
        
        let t1ID = addressSpace.register(localAddress: "/test1/test3/methodA")
        let t2ID = addressSpace.register(localAddress: "/test2/test4/methodB")
        
        // wildcard matches
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test?/test?/method?")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/*/test?/method?")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/test?/*/method?")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/*/*/method?")),
            [t1ID, t2ID]
        )
        
        XCTAssertEqual(
            addressSpace.methods(matching: .init("/*/*/*")),
            [t1ID, t2ID]
        )
        
        // wildcard returning containers instead of methods
        
        do {
            let matches = addressSpace.methods(matching: .init("/*"))
            
            XCTAssertEqual(matches.count, 2)
            XCTAssertFalse(matches.contains(t1ID))
            XCTAssertFalse(matches.contains(t2ID))
        }
        
        do {
            let matches = addressSpace.methods(matching: .init("/*/*"))
            
            XCTAssertEqual(matches.count, 2)
            XCTAssertFalse(matches.contains(t1ID))
            XCTAssertFalse(matches.contains(t2ID))
        }
        do {
            let matches = addressSpace.methods(matching: .init("/test?/test?"))
            
            XCTAssertEqual(matches.count, 2)
            XCTAssertFalse(matches.contains(t1ID))
            XCTAssertFalse(matches.contains(t2ID))
        }
    }
    
    func testMethodsMatching_EdgeCases() {
        // ensure addresses are not sanitized in an unexpected way
        
        let addressSpace = OSCAddressSpace()
        
        do {
            let addr = "/test1/test3/vol-"
            let id = addressSpace.register(localAddress: addr)
            XCTAssertEqual(
                addressSpace.methods(matching: .init(addr)), [id]
            )
        }
        do {
            let addr = "/test2/test4/vol+"
            let id = addressSpace.register(localAddress: addr)
            XCTAssertEqual(
                addressSpace.methods(matching: .init(addr)), [id]
            )
        }
        do {
            let addr = #"/test2/test4/ajL_-du &@!)(}].,;:%$|\-"#
            let id = addressSpace.register(localAddress: addr)
            XCTAssertEqual(
                addressSpace.methods(matching: .init(addr)), [id]
            )
        }
    }
    
    func testDispatchMatching_CurrentQueue() {
        let addressSpace = OSCAddressSpace()
        
        let test1Exp = expectation(description: "test1 Closure Called")
        let test2Exp = expectation(description: "test2 Closure Called")
        let test3Exp = expectation(description: "test3 Closure Called")
        test3Exp.isInverted = true
        
        let id1 = addressSpace.register(localAddress: "/base/test1") { values in
            XCTAssert(values == ["A string", 123])
            test1Exp.fulfill()
        }
        
        let id2 = addressSpace.register(localAddress: "/base/test2") { values in
            XCTAssert(values == ["A string", 123])
            test2Exp.fulfill()
        }
        
        // this shouldn't be called
        let id3 = addressSpace.register(localAddress: "/base/blah3") { values in
            test3Exp.fulfill()
        }
        
        let methodIDs = addressSpace.dispatch(
            OSCMessage("/base/test?", values: ["A string", 123])
        )
        
        wait(for: [test1Exp, test2Exp, test3Exp], timeout: 1.0)
        
        XCTAssertEqual(methodIDs.count, 2)
        XCTAssertTrue(methodIDs.contains(id1))
        XCTAssertTrue(methodIDs.contains(id2))
        _ = id3
    }
    
    func testDispatchMatching_OnQueue() {
        let addressSpace = OSCAddressSpace()
        
        let test1Exp = expectation(description: "test1 Closure Called")
        let test2Exp = expectation(description: "test2 Closure Called")
        let test3Exp = expectation(description: "test3 Closure Called")
        test3Exp.isInverted = true
        
        let id1 = addressSpace.register(localAddress: "/base/test1") { values in
            XCTAssert(values == ["A string", 123])
            test1Exp.fulfill()
        }
        
        let id2 = addressSpace.register(localAddress: "/base/test2") { values in
            XCTAssert(values == ["A string", 123])
            test2Exp.fulfill()
        }
        
        // this shouldn't be called
        let id3 = addressSpace.register(localAddress: "/base/blah3") { values in
            test3Exp.fulfill()
        }
        
        let methodIDs = addressSpace.dispatch(
            OSCMessage("/base/test?", values: ["A string", 123]),
            on: .global()
        )
        
        wait(for: [test1Exp, test2Exp, test3Exp], timeout: 1.0)
        
        XCTAssertEqual(methodIDs.count, 2)
        XCTAssertTrue(methodIDs.contains(id1))
        XCTAssertTrue(methodIDs.contains(id2))
        _ = id3
    }
}

#endif
