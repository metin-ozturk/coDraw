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
        
    init(clientName: String, endPoint: NWEndpoint) {
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
        RunLoop.main.run()
    }
    
    func cancelConnection() {
        connection.cancel()
    }
    
//    private func sendData() {
//        let helloMessage = "hello".data(using: .utf8)
//
//        connection.send(content: helloMessage, completion: .contentProcessed({ (error) in
//            if let error = error {
//                print("Error while sending data: ", error)
//                return
//            }
//
//        }))
//
//
////        connection.receiveMessage { (content, context, isComplete, error) in
////            if content != nil {
////                print("Get Gonnected")
////                self.delegate?.clientGetConnected()
////            }
////        }
//    }
    
    func send(positions: [CGPoint]) {
        let positionsAsStrings = positions.compactMap { NSCoder.string(for: $0).data(using: .utf8) }
        sendData(data: positionsAsStrings, idx: 0)

    }
    
    
    private func sendData(data: [Data], idx: Int) {
        
        guard idx < data.count else {
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

