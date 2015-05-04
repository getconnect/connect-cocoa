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
    
//    func testTheCompletionHandlerForAnEventBatch() {
//        let expectation = expectationWithDescription("validEventBatch")
//        
//        // Given
//        let eventBatch: [String : NSObject] = [
//            "purchases": [
//                [
//                    "id": "123",
//                    "timestamp": "2015-02-05T14:55:56.587Z",
//                    "customer": [
//                        "firstName": "Tom",
//                        "lastName": "Smith"
//                    ],
//                    "product": "12 red roses",
//                    "purchasePrice": 34.95
//                ],
//                [
//                    "id": "123",
//                    "timestamp": "2015-02-05T14:55:56.587Z",
//                    "customer": [
//                        "firstName": "Jane",
//                        "lastName": "Doe"
//                    ],
//                    "product": "1 daisy",
//                    "purchasePrice": 8.95
//                ]
//            ],
//            "refunds": [
//                [
//                    "id": "123",
//                    "timestamp": "2015-02-05T14:55:56.587Z",
//                    "customer": [
//                        "firstName": "Tom",
//                        "lastName": "Smith"
//                    ],
//                    "product": "12 red roses",
//                    "purchasePrice": -34.95
//                ]
//            ]
//        ]
//        let batchResponse: [String : NSObject] = [
//            "purchases": [
//                [
//                    "success": true
//                ],
//                [
//                    "success": false,
//                    "duplicate": true,
//                    "message": "An event with the same id has already been inserted."
//                ]
//            ],
//            "refunds": [
//                [
//                    "success": true,
//                ]
//            ]
//        ]
//        let processedBatch = TPEvent.processBatch(eventBatch, error: nil)!
//        UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(batchUrl, requestJSON: eventBatch, responseStatusCode: 200, responseJSON: batchResponse)
//        
//        println(eventBatch)
//        
//        //When
//        connectApi?.pushEventBatch(processedBatch) {
//            (results, error) in
//            
//            XCTAssertNotNil(results)
//            
//            expectation.fulfill()
//        }
//        
//        waitForExpectationsWithTimeout(4, handler: nil)
//    }

}
