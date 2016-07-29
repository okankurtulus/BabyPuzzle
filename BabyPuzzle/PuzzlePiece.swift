//
//  PuzzlePiece.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 08/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation
import UIKit


protocol PuzzlePieceDelegate {
    func fitInCorrectPlace(puzzlePiece : PuzzlePiece)
}

class PuzzlePiece: UIImageView {
    
    var frameCorrectPosition : CGRect = CGRectZero
    var frameShelfPosition : CGRect = CGRectZero
    var delegate : PuzzlePieceDelegate?
    var placeHolderView : UIView?    
    
    //MARK: - Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        assert(false, "Please init in code")
    }
    
    init(frame: CGRect, correctPositionFrame: CGRect, delegate : PuzzlePieceDelegate) {
        super.init(frame: correctPositionFrame)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.userInteractionEnabled = true
        frameShelfPosition = frame
        frameCorrectPosition = correctPositionFrame
        self.delegate = delegate
    }
    
    //MARK: - Shrink & Expand
    
    func expand() {
        var frame = self.frame
        frame.size = frameCorrectPosition.size
        moveToFrame(frame)
    }
    
    func shrink() {
        //assert(self.frame.size != frameShelfPosition.size, "It is already shrinked")
        moveToFrame(frameShelfPosition)
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
        var point = touches.first!.locationInView(self.superview)
        point.x -= frameCorrectPosition.width / 2
        point.y -= frameCorrectPosition.height / 2
        
        point.x -= 75
        point.y -= 75
        
        if(!isPointAcceptiable(point)) {
            self.expand()
            self.superview?.bringSubviewToFront(self)
            AudioModel.sharedInstance.expandAudio?.play()
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
            point.y -= frameCorrectPosition.height / 2
            
            point.x -= 75
            point.y -= 75
            
            if(!isPointAcceptiable(point)) {
                self.frame.origin = point
            } else if (self.frame != self.frameCorrectPosition) {
                AudioModel.sharedInstance.puzzlePieceFitAudio?.play()
                moveToFrame(frameCorrectPosition, animationDuration: 0.1)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first!.locationInView(self.superview)
        if(self.frame == frameCorrectPosition) {
            self.remove()
            AudioModel.sharedInstance.successAudio?.play()
            self.delegate?.fitInCorrectPlace(self)
        } else if(isPointAcceptiable(point)) {
            moveToFrame(frameCorrectPosition)
        } else {
            AudioModel.sharedInstance.shrinkAudio?.play()
            shrink()
        }
    }
    
    func remove() {
        self.placeHolderView?.removeFromSuperview()
        self.removeFromSuperview()
    }
}


extension PuzzlePiece {
    //var path = UIBezierPath()
    //var shapeLayer = CAShapeLayer()
    //var croppedImage = UIImage()
    
}