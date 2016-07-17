//
//  ViewController.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 04/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import UIKit


class ViewController: UIViewController, PuzzlePieceDelegate {
    
    @IBOutlet var puzzlePieceContainerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var gameBackgroundImageView: UIImageView!
    
    var puzzlePieces : Array = [PuzzlePiece]()
    let colors = [UIColor.redColor(), UIColor.blueColor(),
                  UIColor.yellowColor(), UIColor.greenColor(),
                  UIColor.cyanColor(), UIColor.orangeColor(), UIColor.purpleColor()]
    var backgroundImageNames = ["bg1","bg2","bg3","bg4","bg5","bg6","bg7","bg8","bg9","bg10","bg11","bg12"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.puzzlePieceContainerView.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        resetGameScene()
    }
    
    //MARK: - GameScene
    
    func randomGenerate(min : CGFloat, max : CGFloat) -> CGFloat {
        let diff = UInt32(max-min)
        let randomValue = (arc4random_uniform(diff) + UInt32(min))
        return CGFloat(randomValue)
    }
    
    func generateOriginalFrame(pieceCount : Int, contentFrame : CGRect) -> CGRect {
        let padding : CGFloat = 50
        let maxLimitForRandomFrame = min(contentFrame.size.width, contentFrame.size.height) / 2
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
    
    func initGameScene(pieceCount : Int = 7) -> Void {
        puzzlePieces.removeAll()
        
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        self.gameBackgroundImageView.image = UIImage(named: backgroundImageNames[randomIndex%backgroundImageNames.count])
        
        for i in 1...pieceCount {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(i * 250) * Double(NSEC_PER_MSEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                [unowned self] in
                self.addPiece(i, pieceCount: pieceCount, level: randomIndex)
            })
        }
    }
    
    
    
    func addPiece(withIndex : Int, pieceCount : Int, level : Int) {
        let referenceFrame = self.puzzlePieceContainerView.frame
        let contentFrame = self.gameBackgroundImageView.frame
        let pieceWidth = referenceFrame.size.width
        let pieceHeight = pieceWidth
        let heightStep = pieceWidth
        
        
        let padding : CGFloat = 5
        
        let shelfFrame = CGRectMake(referenceFrame.origin.x, padding  + (heightStep * CGFloat(withIndex-1)), pieceWidth, pieceHeight)
        
        let originalFrame = self.generateNonIntersectingFrame(pieceCount, contentFrame: contentFrame, previousPuzzlePieces: self.puzzlePieces)
        
        let pieceColor = colors[(level + withIndex)%colors.count]
        
        let convertedFrame = self.view.convertRect(originalFrame, toView: self.gameBackgroundImageView)
        
        let placeHolderView = UIView(frame: convertedFrame)
        let puzzlePiece = PuzzlePiece(frame: shelfFrame, correctPositionFrame: originalFrame,delegate: self)
        
        placeHolderView.backgroundColor = UIColor.blackColor()
        placeHolderView.layer.cornerRadius = puzzlePiece.layer.cornerRadius
        self.gameBackgroundImageView.addSubview(placeHolderView)
        
        puzzlePiece.backgroundColor = pieceColor
        self.puzzlePieces.append(puzzlePiece)
        self.view.addSubview(puzzlePiece)
        puzzlePiece.shrink()
        
        
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
        let pieceCount = self.gameBackgroundImageView.frame.size.height / self.puzzlePieceContainerView.frame.size.height
        
        self.initGameScene(Int(pieceCount))
    }
    
    //Mark: - PuzzlePieceDelegate
    func fitInCorrectPlace(puzzlePiece : PuzzlePiece) {
        let convertedFrame = self.view.convertRect(puzzlePiece.frameCorrectPosition, toView: self.gameBackgroundImageView)
        for view in self.gameBackgroundImageView.subviews {
            if(view.frame == convertedFrame) {
                view.removeFromSuperview()
            }
        }
        checkToResetGame()
    }
    
    func checkToResetGame() {
        for puzzlePiece in puzzlePieces {
            if(!puzzlePiece.isPointAcceptiable(puzzlePiece.frame.origin)) {
                print("Some pieces are not in correct state yet")
                return
            }
        }
        resetGameScene()
    }
    
}

