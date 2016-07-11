//
//  ViewController.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 04/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var puzzlePieceContainerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var gameBackgroundImageView: UIImageView!
    
    var puzzlePieces : Array = [PuzzlePiece]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGameScene(5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning");
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - GameScene
    
    func randomGenerate(min : UInt32, max : UInt32) -> UInt32 {
        let randomValue = (arc4random_uniform(max - min) + min)
        return randomValue
    }
    
    func generateOriginalFrame(pieceCount : Int, contentFrame : CGRect) -> CGRect {
        let maxLimitForRandomFrame = min(contentFrame.size.width, contentFrame.size.height) / CGFloat(pieceCount)
        let randomX = randomGenerate(UInt32(contentFrame.origin.x), max: UInt32(contentFrame.size.width))
        let randomY = randomGenerate(UInt32(contentFrame.origin.y), max: UInt32(contentFrame.size.height))
        let randomHeight = randomGenerate(50, max: UInt32(maxLimitForRandomFrame))
        let randomWidth = randomGenerate(50, max: UInt32(maxLimitForRandomFrame))
        let originalFrame = CGRectMake(CGFloat(randomX), CGFloat(randomY), CGFloat(randomWidth), CGFloat(randomHeight))
        return originalFrame
    }
    
    func generateNonIntersectingFrame(pieceCount : Int, contentFrame : CGRect, previousPuzzlePieces : [PuzzlePiece]) -> CGRect {
        let originalFrame = generateOriginalFrame(pieceCount, contentFrame: contentFrame)
        var intersectionOccurs = false
        for puzzlePiece in previousPuzzlePieces {
            if(CGRectIntersectsRect(originalFrame, puzzlePiece.frameCorrectPosition)) {
                intersectionOccurs = true
                break
            }
        }
        if(intersectionOccurs) {
            print("Trying to generate again. Even low possibility, this approach can cause infinite loop")
            return generateNonIntersectingFrame(pieceCount, contentFrame: contentFrame, previousPuzzlePieces: previousPuzzlePieces)
        } else {
            return originalFrame
        }
    }
    
    func initGameScene(pieceCount : Int = 3) -> Void {
        let colors = [UIColor.redColor(), UIColor.blueColor(),
                      UIColor.yellowColor(), UIColor.greenColor(),
                      UIColor.cyanColor(), UIColor.orangeColor()]
        
        let isPieceCountValid = (CGFloat(pieceCount) * self.puzzlePieceContainerView.frame.size.width) > self.puzzlePieceContainerView.frame.size.height
        assert(!isPieceCountValid, "Please set piece count to some lower value")
        
        let referenceFrame = self.puzzlePieceContainerView.frame
        let contentFrame = self.gameBackgroundImageView.frame
        let pieceWidth = referenceFrame.size.width
        let pieceHeight = pieceWidth
        let heightStep = referenceFrame.size.height / CGFloat(pieceCount + 1)
        
        for i in 0..<pieceCount {
            let shelfFrame = CGRectMake(referenceFrame.origin.x, heightStep * CGFloat(i+1) - (pieceHeight / 2), pieceWidth, pieceHeight)
            let originalFrame = generateNonIntersectingFrame(pieceCount, contentFrame: contentFrame, previousPuzzlePieces: puzzlePieces)

            let placeHolderView = UIView(frame: originalFrame)
            placeHolderView.backgroundColor = UIColor.blackColor()
            self.view.addSubview(placeHolderView)
            
            let puzzlePiece = PuzzlePiece(frame: shelfFrame, correctPositionFrame: originalFrame)
            puzzlePiece.backgroundColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            puzzlePieces.append(puzzlePiece)
            self.view.addSubview(puzzlePiece)
        }
        
        
    }
    
}

