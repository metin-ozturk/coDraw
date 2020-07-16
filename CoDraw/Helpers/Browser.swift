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
                print("Browser - failed with %{public}@, restarting", error.localizedDescription)
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
            for result in results {
                let localDeviceIdentifier = UIDevice.current.name + "._test._tcplocal."
                print("Browser - found matching endpoint with ", result.endpoint.debugDescription)
                
                if localDeviceIdentifier != result.endpoint.debugDescription {
                    self.delegate?.foundEndpoint(endPoint: result.endpoint)
                    break

                }
            }
        }
        
        browser.start(queue: browserQueue)
    }
    
    func cancelBrowsing() {
        browser.cancel()
    }
}
