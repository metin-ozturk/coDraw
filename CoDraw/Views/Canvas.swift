//
//  Canvas.swift
//  CoDraw
//
//  Created by Metin Öztürk on 14.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import UIKit

protocol CanvasDelegate : class {
    func lastLineBeingDrawn(lastLine: [CGPoint])
    func drawingCompleted(lastLine: [CGPoint])
    func drawingStarted()
}

class Canvas : UIView {
    
    weak var delegate : CanvasDelegate?
    var lines = [[CGPoint]]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        backgroundColor = .white
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { line in
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
    
    func drawByPoints(points: [CGPoint]) {
        lines.append([CGPoint]())

        points.forEach {
            if var lastLine = lines.popLast() {
                lastLine.append($0)
                delegate?.lastLineBeingDrawn(lastLine: lastLine)
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
                delegate?.lastLineBeingDrawn(lastLine: lastLine)
                lines.append(lastLine)
            }

            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.drawingCompleted(lastLine: lines.last!)
    }
    
}
