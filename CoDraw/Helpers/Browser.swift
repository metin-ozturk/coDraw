//
//  Browser.swift
//  CoDraw
//
//  Created by Metin Öztürk on 14.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import Network
import UIKit

protocol BrowserDelegate : class {
    func foundEndpoint(endPoint: NWEndpoint)
}

// Search for compatible devices in local network with bonjour services
class Browser {
    
    weak var delegate : BrowserDelegate?
    var browser : NWBrowser
    
    init() {
        let browserQueue = DispatchQueue(label: "BrowserQueue")
        let params = NWParameters()
        params.includePeerToPeer = true

        browser = NWBrowser(for: .bonjour(type: "_test._tcp",
                                              domain: "local"), using: params)
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                print("Browser - failed with", error.localizedDescription)
                self.browser.cancel()
            case .ready:
                print("Browser ready")
            case .setup:
                print("Browser is set")
            default:
                break
            }
        }
        
        // Used to browse for discovered endpoints.
        browser.browseResultsChangedHandler = { results, changes in
            let localDeviceIdentifier = UIDevice.current.name + "._test._tcplocal."
            for change in changes {
                if case .added(let added) = change, added.endpoint.debugDescription != localDeviceIdentifier {
                    // If found endpoint is not the device itself, notify controller
                    self.delegate?.foundEndpoint(endPoint: added.endpoint)
                }
            }
            
            
        }
        
        browser.start(queue: browserQueue)
    }

}
