//
//  TCPServer.swift
//  CoDraw
//
//  Created by Metin Öztürk on 13.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import Foundation
import Network
import UIKit

protocol TCPServerDelegate : class {
    func positionsReceived(positions: [CGPoint])
    func undoCommandReceived()
    func clearCommandReceived()
    func changeColorCommandReceived()
}

class TCPServer {
    var listener : NWListener
    var queue : DispatchQueue
    var connected : Bool = false
    
    weak var delegate : TCPServerDelegate?
    
    init() {
        queue = DispatchQueue(label: "TCP Server Queue")
        // Set tcp service
        let tcpOptions = NWParameters.tcp
//        tcpOptions.multipathServiceType = .interactive
        tcpOptions.includePeerToPeer = true
        listener = try! NWListener(using: tcpOptions)
        
        listener.service = NWListener.Service(type: "_test._tcp")
        
        listener.serviceRegistrationUpdateHandler = { (serviceChange) in
            switch serviceChange {
            case .add(let endPoint):
                switch endPoint {
                case let .service(name: name, type: _, domain: _, interface: _):
                    print("Listening as: \(name)")
                default:
                    break
                }
            default:
                break
            }
        }
        
        listener.newConnectionHandler = { [weak self] newConnection in
            if let sSelf = self {
                newConnection.start(queue: sSelf.queue)
                sSelf.receive(on: newConnection)
            }
        }
        
        listener.stateUpdateHandler = { [weak self] (newState) in
            switch newState {
            case .ready:
                print("Listening on port: \(String(describing: self?.listener.port))")
            case .failed(let err):
                print("Listener failed with error: ", err)
            default:
                break
            }
        }
        
    }
    
    func startServer() {
        listener.start(queue: queue)
        
    }
    
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { (content, context, isComplete, error) in
            if let content = content {
                let rContent = String(decoding: content, as: UTF8.self)
                
                if let rContentAsInt = Int(rContent) {
                    // Received content is Integer, that means an add edit action (clear, undo etc.) request has been made. Notify controller to make changes on canvas
                    switch rContentAsInt {
                    case 1:
                        self.delegate?.undoCommandReceived()
                    case 2:
                        self.delegate?.clearCommandReceived()
                    case 3:
                        self.delegate?.changeColorCommandReceived()
                    default:
                        break
                    }
                } else {
                    // received content is String which represent drawing coordinates. Parsing String to convert it to CGPoint format and notify controller
                    let rPositionsAsArray = rContent.split(separator: "{").map { String($0).replacingOccurrences(of: "}", with: "").removingWhitespaces()} // Positions in format: "11,23.5"
                    
                    let rPositionsAsCGPointArray : [CGPoint] = rPositionsAsArray.map {
                        let xCoordinateAsString = Double(String($0.split(separator: ",")[0])) ?? 0
                        let yCoordinateAsString = Double(String($0.split(separator: ",")[1])) ?? 0
                        
                        return CGPoint(x: xCoordinateAsString, y: yCoordinateAsString)
                    }
                                    
                    self.delegate?.positionsReceived(positions: rPositionsAsCGPointArray)
                }

                
                                
                if error == nil {
                    self.receive(on: connection)
                }
            }
        }
    }

}
