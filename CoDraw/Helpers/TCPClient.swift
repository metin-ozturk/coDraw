//
//  TCPClient.swift
//  CoDraw
//
//  Created by Metin Öztürk on 13.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import Foundation
import Network
import UIKit


class TCPClient {
    var connection : NWConnection
    var queue : DispatchQueue
        
    init(endPoint: NWEndpoint) {
        queue = DispatchQueue(label: "TCP Client Queue")
        
        let tcpOptions = NWParameters.tcp
//        tcpOptions.multipathServiceType = .interactive
        tcpOptions.includePeerToPeer = true
        connection = NWConnection(to: endPoint, using: tcpOptions)
        
        connection.stateUpdateHandler = { (newState) in
            switch newState {
            case .ready:
                print("Ready To Send")
            case .failed(let err):
                print("Client failed with error: \(err)")
            case .preparing:
                print("Client is preparing")
            case .waiting(let err):
                print("Client failed with error: \(err)")
            default:
                break
            }
        }
        
    }
    
    func startClient() {
        connection.start(queue: queue)
    }
    
    
    
    func send(positions: [CGPoint]) {
        // Send drawing coordinates in String format
        let positionsAsStrings = positions.compactMap { NSCoder.string(for: $0).data(using: .utf8) }
        sendData(data: positionsAsStrings, idx: 0)

    }
    
    func send(canvasEditInfo: CanvasEdit){
        // Send information whenever an edit action happens (clear, undo, changecolor)
        
        let cEInfo = String(canvasEditInfo.rawValue)
        let cEInfoAsData = cEInfo.data(using: .utf8)

        connection.send(content: cEInfoAsData, completion: NWConnection.SendCompletion.contentProcessed({ (error) in
            if let error = error {
                print("Error while sending position data: ", error)
            }
            
            self.connection.cancel()
        }))

    }
    
    
    private func sendData(data: [Data], idx: Int) {
        // send data to found endpoint
        
        guard idx < data.count else {
            // cancel connection when whole data is sent
            connection.cancel()
            return
        }

        
        connection.send(content: data[idx], completion: NWConnection.SendCompletion.contentProcessed({ (error) in
            if let error = error {
                print("Error while sending position data: ", error)
            }
                        
            self.sendData(data: data, idx: idx + 1)
        }))

    }
    
    
}

