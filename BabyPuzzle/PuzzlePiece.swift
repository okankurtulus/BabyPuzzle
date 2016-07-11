//
//  PuzzlePiece.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 08/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation
import UIKit


class PuzzlePiece: UIButton {
    
    var frameCorrectPosition : CGRect = CGRectZero
    var frameShelfPosition : CGRect = CGRectZero
    
    
    //MARK: - Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        assert(false, "Please init in code")
    }
    
    init(frame: CGRect, correctPositionFrame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        frameShelfPosition = frame
        frameCorrectPosition = correctPositionFrame
    }
    
    //MARK: - Shrink & Expand
    
    func expand() {
        var frame = self.frame
        frame.size = frameCorrectPosition.size
        moveToFrame(frame)
    }
    
    func shrink() {
        assert(self.frame.size != frameShelfPosition.size, "It is already shrinked")
        moveToFrame(frameShelfPosition)
        print("Shrink - Play sound")
    }
    
    func moveToFrame(toFrame: CGRect, animationDuration : NSTimeInterval = 0.3) {
        UIView.animateWithDuration(animationDuration , animations: {
            [unowned self] in
            self.frame = toFrame
            })
    }
}


extension PuzzlePiece {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first!.locationInView(self.superview)
        if(!isPointAcceptiable(point)) {
            self.expand()
            self.superview?.bringSubviewToFront(self)
            print("Expand - Play sound")
        }
    }
    
    func isPointAcceptiable(point : CGPoint, sensitivity : CGFloat = 30) -> Bool {
        return  (abs(point.x - frameCorrectPosition.origin.x) < sensitivity)
        && (abs(point.y - frameCorrectPosition.origin.y) < sensitivity)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            var point = touch.locationInView(self.superview)
            point.x -= frameCorrectPosition.width / 2
            point.y -= frameCorrectPosition.height
            
            
            if(!isPointAcceptiable(point)) {
                self.frame.origin = point
            } else {
                moveToFrame(frameCorrectPosition, animationDuration: 0.1)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first!.locationInView(self.superview)
        if(self.frame == frameCorrectPosition) {
            print("Already in correct place!")
        } else if(isPointAcceptiable(point)) {
            print("Congratulations!!!")
            moveToFrame(frameCorrectPosition)
        } else {
            shrink()
        }
    }
}


extension PuzzlePiece {
    //var path = UIBezierPath()
    //var shapeLayer = CAShapeLayer()
    //var croppedImage = UIImage()
    
}