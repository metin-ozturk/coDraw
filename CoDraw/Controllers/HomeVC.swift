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

    private lazy var canvas : Canvas = {
        let canvas = Canvas(frame: .zero)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.delegate = self
        return canvas
    }()
    
    private var undoButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("UNDO", for: .normal)
        button.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var clearButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CLEAR", for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var changeColorButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CHANGE COLOR", for: .normal)
        button.addTarget(self, action: #selector(changeColorButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var rEndPoint : NWEndpoint?
    
    private var lineBeingDrawn = [CGPoint]() {
        didSet {
            // whenever drawing occurs, send data to client
            hClient?.send(positions: lineBeingDrawn)
        }
    }
    
    private var hClient : TCPClient?
    private var hServer : TCPServer?
    private var timer : Timer?
    
    private var browser : Browser?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 200/255, green: 209/255, blue: 222/255, alpha: 1)
        setViews()
        
        browser = Browser()
        browser?.delegate = self
        
        setAsServer()
        setTimer()

        RunLoop.main.add(timer!, forMode: .default)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    private func setAsServer() {
        hServer = TCPServer()
        hServer?.delegate = self
        hServer?.startServer()
    }
    
    private func setAsClient() {
        if let rEndPoint = self.rEndPoint {
            hClient = TCPClient(endPoint: rEndPoint)
            hClient?.startClient()
        }
    }
    
    private func setTimer() {
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
    }
    
    @objc private func timerFired(_ sender: Timer) {
        if hClient?.connection.endpoint != self.rEndPoint  {
            // if a new endpoint discovered, update client
            setAsClient()
        }
    }
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        if hClient?.connection.state == .cancelled {
            setAsClient()
        }
        
        hClient?.send(canvasEditInfo: .clear)
        DispatchQueue.main.async {
            self.canvas.undo()
        }

    }
    
    @objc private func clearButtonTapped(_ sender: UIButton) {
        if hClient?.connection.state == .cancelled {
            setAsClient()
        }
        
        hClient?.send(canvasEditInfo: .clear)
        DispatchQueue.main.async {
            self.canvas.clear()
        }
    }
    
    @objc private func changeColorButtonTapped(_ sender: UIButton) {
        if hClient?.connection.state == .cancelled {
            setAsClient()
        }
        
        hClient?.send(canvasEditInfo: .changeColor)
        DispatchQueue.main.async {
            self.canvas.changeColor()
        }
        
    }
    
    
    private func setViews() {
        view.addSubview(canvas)
        
        let buttonsStackView = UIStackView(arrangedSubviews: [changeColorButton, undoButton, clearButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.spacing = 16
        buttonsStackView.alignment = .leading
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.axis = .horizontal

        
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: buttonsStackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: buttonsStackView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: buttonsStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        ])
        
        let heightConstraint = NSLayoutConstraint(item: canvas, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500)
        heightConstraint.priority = UILayoutPriority.defaultLow
        
        NSLayoutConstraint.activate([
             NSLayoutConstraint(item: canvas, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: canvas, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 64),
             heightConstraint,
            NSLayoutConstraint(item: canvas, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500),
             NSLayoutConstraint(item: canvas, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 350)
         ])
        
    }
    

}


extension HomeVC : TCPServerDelegate {
    func changeColorCommandReceived() {
        DispatchQueue.main.async {
            self.canvas.changeColor()
        }
    }
    
    func undoCommandReceived() {
        DispatchQueue.main.async {
            self.canvas.undo()
        }
    }
    
    func clearCommandReceived() {
        DispatchQueue.main.async {
            self.canvas.clear()
        }
    }
    
    
    func positionsReceived(positions: [CGPoint]) {
        DispatchQueue.main.async {
            self.canvas.drawByPoints(points: positions)
        }
    }
    
    
}

extension HomeVC : CanvasDelegate {
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
        // notified when new Endpoint is found
        rEndPoint = endPoint
        setAsClient()
                
    }
    
}
