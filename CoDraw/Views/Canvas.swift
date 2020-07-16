//
//  Canvas.swift
//  CoDraw
//
//  Created by Metin Öztürk on 14.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import UIKit

protocol CanvasDelegate : class {
    func drawingCompleted(lastLine: [CGPoint])
    func drawingStarted()
}

enum CanvasEdit : Int {
    case undo = 1
    case clear = 2
    case changeColor = 3
}

class Canvas : UIView {
    
    weak var delegate : CanvasDelegate?
    var lines = [[CGPoint]]()
    
    private var rStrokeColor : UIColor = .red
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    private func commonInit() {
        layer.borderColor = UIColor.white.cgColor
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        
        layer.borderWidth = 1
        backgroundColor = .white
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { line in
            context.setStrokeColor(rStrokeColor.cgColor)
            for (idx, point) in line.enumerated() {
                if idx == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }

        
        context.strokePath()
    }
    
    func undo() {
        _ = lines.popLast()
        setNeedsDisplay()
    }
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func changeColor() {
        let randomColorIdx = Int.random(in: 0...5)
        let randomColors : [UIColor] = [.red, .green, .blue, .black, .orange, .brown, .purple]
        
        rStrokeColor = randomColors.filter { $0 != rStrokeColor }[randomColorIdx]
        

        setNeedsDisplay()
    }
    
    func drawByPoints(points: [CGPoint]) {
        // draw when an edit action request has been made from peer in the network
        lines.append([CGPoint]())
        
        points.forEach {
            if var lastLine = lines.popLast() {
                lastLine.append($0)
                lines.append(lastLine)
            }

            setNeedsDisplay()
        }
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
        delegate?.drawingStarted()
    }
        
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchedPoint = touches.first?.location(in: self) {
            
            if var lastLine = lines.popLast() {
                lastLine.append(touchedPoint)
                lines.append(lastLine)
            }

            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.drawingCompleted(lastLine: lines.last!)
    }
    
}
