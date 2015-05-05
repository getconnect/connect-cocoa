//
//  TPEventTests.swift
//  ConnectClient
//
//  Created by Chad Edrupt on 4/05/2015.
//

import XCTest

class TPEventTests: XCTestCase {

    func testThatAnEmptyEventThrowsAnError() {
        // Given
        let event = TPEvent(properties: [:], forCollection: "test")
        var error: NSError?
        
        // When
        event.process(&error)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertNotNil(error?.localizedDescription)
    }
    
    func testThatAReservedPropertyNameThrowsAnError() {
        // Given
        let event = TPEvent(properties: ["tp_lp": ""], forCollection: "Test")
        var error: NSError?
        
        // When
        event.process(&error)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertNotNil(error?.localizedDescription)
    }
    
    // MARK: Defaults
    
    func testThatAnIdIsAddedIfNotProvided() {
        // Given
        let event = TPEvent(properties: ["speed": 200], forCollection: "Test")
        
        // When
        event.process(nil)
        
        // Then
        XCTAssertNotNil(event.properties["id"])
    }
    
    func testThatAnIdIsNotOverriddenIfProvided() {
        // Given
        let id = "ABCDEFG"
        let event = TPEvent(properties: ["id": id], forCollection: "Test")
        
        // When
        event.process(nil)
        
        // Then
        XCTAssertEqual(id, event.properties["id"] as! String)
    }
    
    func testThatATimestampIsAddedIfNotProvided() {
        // Given
        let event = TPEvent(properties: ["speed": 200], forCollection: "Test")
        
        // When
        event.process(nil)
        
        // Then
        XCTAssertNotNil(event.properties["timestamp"])
    }
    
    func testThatATimestampIsNotOverriddenIfProvided() {
        // Given
        let now = NSDate()
        let nowString = now.tp_iso8601String()
        let event = TPEvent(properties: ["timestamp": now], forCollection: "Test")
        
        // When
        event.process(nil)
        
        // Then
        XCTAssertEqual(nowString, event.properties["timestamp"] as! String)
    }
    
    // MARK: Deep date conversion
    
    func testThatADeeplyNestedDateIsProperlyConverted() {
        // Given
        let now = NSDate()
        let nowString = now.tp_iso8601String()
        let event = TPEvent(properties: ["values": [["date": now]]], forCollection: "Test")
        
        // When
        event.process(nil)
        
        // Then
        let values = event.properties["values"] as! NSArray
        let value = values.firstObject as! NSDictionary
        let convertedValue = value["date"] as! String
        XCTAssertEqual(nowString, convertedValue)
    }
}
