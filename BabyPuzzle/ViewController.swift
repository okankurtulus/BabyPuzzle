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
    
    func randomGenerate(min : CGFloat, max : CGFloat) -> CGFloat {
        let diff = UInt32(max-min)
        let randomValue = (arc4random_uniform(diff) + UInt32(min))
        return CGFloat(randomValue)
    }
    
    func generateOriginalFrame(pieceCount : Int, contentFrame : CGRect) -> CGRect {
        let padding : CGFloat = 50
        let maxLimitForRandomFrame = min(contentFrame.size.width, contentFrame.size.height) / CGFloat(pieceCount)
        let randomX = randomGenerate(contentFrame.origin.x, max: contentFrame.size.width - 1.5*padding)
        let randomY = randomGenerate(contentFrame.origin.y, max: contentFrame.size.height - 1.5*padding)
        let randomHeight = randomGenerate(padding, max: min(contentFrame.height - randomY, maxLimitForRandomFrame))
        let randomWidth = randomGenerate(padding, max: min(contentFrame.width - randomX, maxLimitForRandomFrame))        
        let originalFrame = CGRectMake(randomX, randomY, randomWidth, randomHeight)
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
        puzzlePieces.removeAll()
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

            
            let convertedFrame = self.view.convertRect(originalFrame, toView: self.gameBackgroundImageView)
            let placeHolderView = UIView(frame: convertedFrame)
            placeHolderView.backgroundColor = UIColor.blackColor()
            self.gameBackgroundImageView.addSubview(placeHolderView)
            
            let puzzlePiece = PuzzlePiece(frame: shelfFrame, correctPositionFrame: originalFrame)
            puzzlePiece.backgroundColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            puzzlePieces.append(puzzlePiece)
            self.view.addSubview(puzzlePiece)
        }
        
        
    }
    
    //MARK: - ResetScene
    
    func reset() {
        for puzzlePiece in puzzlePieces {
            puzzlePiece.removeFromSuperview()
        }
        
        for view in self.gameBackgroundImageView.subviews {
            view.removeFromSuperview()
        }
    }
    
    @IBAction func resetGameScene() {
        reset()
        initGameScene(5)
    }
    
}

