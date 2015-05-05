//
//  TPViewController.swift
//  ConnectClient
//
//  Created by Chad Edrupt on 4/05/2015.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBAction func pushEventTapped(sender: UIButton) {
        pushSampleEvent()
    }
    
    private func pushSampleEvent() {
        if let connectClient = TPConnectClient.sharedClient() {
            let eventProperties: [NSString: NSObject] = [
                "customer": [
                    "firstName": "Tom",
                    "lastName": "Smith"
                ],
                "product": "12 red roses",
                "purchasePrice": 34.95
            ]
            connectClient.addEvent(eventProperties, toCollection: "purchases", withError: nil)
        }
    }
}
