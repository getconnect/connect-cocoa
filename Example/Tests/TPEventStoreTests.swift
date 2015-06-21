//
//  TPEventStoreTests.swift
//  ConnectClient
//
//  Created by Chad Edrupt on 4/05/2015.
//

import XCTest

class TPEventStoreTests: XCTestCase {
    
    let eventStore = TPEventStore(projectId: "testing")
    
    override func setUp() {
        super.setUp()
        
        eventStore.deleteAllPendingEvents { }
    }
    
    override func tearDown() {
        eventStore.deleteAllPendingEvents { }
        
        super.tearDown()
    }
    
    func testThatAnEventIsPersisted() {
        let expectation = expectationWithDescription("persist-single-event")
        
        // Given
        let eventProperties: [String : NSObject] = [
            "customer": [
                "firstName": "Tom",
                "lastName": "Smith"
            ],
            "product": "12 red roses",
            "purchasePrice": 34.95
        ]
        let event = TPEvent(properties: eventProperties, forCollection: "purchases")
        event.process(nil)
        
        eventStore.fetchPendingEventsWithCompletionHandler() {
            (results) in
            XCTAssertTrue(results.allValues.count == 0);
        }
        
        // When
        eventStore.addEvent(event)
        
        // Then
        eventStore.fetchPendingEventsWithCompletionHandler(){
            (results) in
            XCTAssertTrue(results.allValues.count == 1);
            XCTAssertEqual(results.allKeys.first as! String, "purchases")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

}
