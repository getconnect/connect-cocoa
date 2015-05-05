//
//  TPConnectAPITests.swift
//  ConnectClient
//
//  Created by Chad Edrupt on 4/05/2015.
//  Copyright (c) 2015 Chad Edrupt. All rights reserved.
//

import Foundation
import XCTest

class TPConnectAPITests: XCTestCase {

    let purchaseCollection = "purchases"
    
    let batchUrl = NSURL(string: "https://api.getconnect.io/events")
    let purchaseUrl = NSURL(string: "https://api.getconnect.io/events/purchases")
    
    var connectApi: TPConnectAPI?
    
    override func setUp() {
        super.setUp()
    
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.protocolClasses = [ UMKMockURLProtocol.self ]
        connectApi = TPConnectAPI(apiKey: "", sessionConfiguration: sessionConfig)
        
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.reset()
    }
    
    override func tearDown() {
        
        connectApi = nil
        
        UMKMockURLProtocol.disable()
        
        super.tearDown()
    }

    
    func testTheCompletionHandlerForAValidEvent() {
        let expectation = expectationWithDescription("validSingleEvent")
        
        // Given
        let eventProperties: [String : NSObject] = [
            "customer": [
                "firstName": "Tom",
                "lastName": "Smith"
            ],
            "product": "12 red roses",
            "purchasePrice": 34.95
        ]
        let event = TPEvent(properties: eventProperties, forCollection: purchaseCollection)
        event.process(nil)
        UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(purchaseUrl, requestJSON: event.properties, responseStatusCode: 200, responseJSON: [:])
        
        // When
        connectApi?.pushEvent(event) {
            (success, error) in
            
            // Then
            XCTAssertTrue(success)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

}
