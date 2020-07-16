//
//  ViewController.swift
//  CoDraw
//
//  Created by Metin Öztürk on 13.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import UIKit
import Network

class HomeVC: UIViewController {

    private let resultLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Searching..."
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    
    private lazy var canvas : Canvas = {
        let canvas = Canvas(frame: .zero)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.delegate = self
        return canvas
    }()
    
    private var rEndPoint : NWEndpoint?
    private var lineBeingDrawn = [CGPoint]() {
        didSet {
            hClient?.send(positions: lineBeingDrawn)
        }
    }
    
    private var hClient : TCPClient?
    private var hServer : TCPServer?
    private var timer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setViews()
        
        let browser = Browser()
        browser.delegate = self
        self.setAsServer()
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .default)
    }
    
    private func setAsServer() {
        hServer = TCPServer()
        hServer?.delegate = self
        hServer?.startServer()
    }
    
    private func setAsClient() {
        if let rEndPoint = self.rEndPoint {
            hClient = TCPClient(clientName: "Metin", endPoint: rEndPoint)
            hClient?.startClient()
        }
    }
    
    @objc private func timerFired(_ sender: Timer) {
        if self.rEndPoint != nil {
            self.setAsClient()
            timer?.invalidate()
        }
    }
    
    
    private func setViews() {
        view.addSubview(resultLabel)
        view.addSubview(canvas)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: resultLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resultLabel, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: resultLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: resultLabel, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
             NSLayoutConstraint(item: canvas, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: canvas, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 16),
             NSLayoutConstraint(item: canvas, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300),
             NSLayoutConstraint(item: canvas, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
         ])
        
    }
    

}


extension HomeVC : TCPServerDelegate {
    func positionsReceived(positions: [CGPoint]) {
        DispatchQueue.main.async {
            self.canvas.drawByPoints(points: positions)
        }
    }
}

extension HomeVC : CanvasDelegate {
    func lastLineBeingDrawn(lastLine: [CGPoint]) {
//        lineBeingDrawn = lastLine
    }
    
    func drawingCompleted(lastLine: [CGPoint]) {
        lineBeingDrawn = lastLine
    }
    
    func drawingStarted() {
        if hClient?.connection.state == .cancelled {
            setAsClient()
        }
    }
}

extension HomeVC : BrowserDelegate {
    func foundEndpoint(endPoint: NWEndpoint) {
        rEndPoint = endPoint
    }
}
