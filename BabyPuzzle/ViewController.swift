//
//  ViewController.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 04/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Toucan

class ViewController: UIViewController, PuzzlePieceDelegate {
    
    @IBOutlet var resetButton : UIButton!
    @IBOutlet var puzzlePieceContainerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var gameBackgroundImageView: UIImageView!
    @IBOutlet var leveLabel : UILabel!
    
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var bannerBottomConstraint : NSLayoutConstraint!
    var interstitial: GADInterstitial!
    var resetButtonPressedTime = 0
    
    var puzzlePieces : Array = [PuzzlePiece]()
    let colors = [UIColor.redColor(), UIColor.blueColor(),
                  UIColor.yellowColor(), UIColor.greenColor(),
                  UIColor.cyanColor(), UIColor.orangeColor(), UIColor.purpleColor()]
    var backgroundImageNames = ["bg1","bg2","bg3","bg4","bg5","bg6","bg7","bg8","bg9","bg10","bg11","bg12"]
    let gameStatsModel = GameStatsModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.puzzlePieceContainerView.backgroundColor = UIColor.clearColor()
        initLevelLabel()
        initInterstitial()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        resetGameScene()
    }
    
    func initLevelLabel() {
        self.leveLabel.font = UIFont.systemFontOfSize(18, weight: 2)
        self.leveLabel.textColor = UIColor.blueColor()
        self.leveLabel.shadowOffset = CGSizeMake(1, 1)
        self.leveLabel.shadowColor = UIColor.grayColor()
        self.leveLabel.text = ""
    }
    
    //MARK: - Google Ads
    
    func initBanner()  {
        let bannerId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_BANNER)
        bannerView.adUnitID = bannerId
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.loadRequest(GADRequest())        
    }
    
    func initInterstitial() {
        let interstitialId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_INTERSTITIAL)
        interstitial = GADInterstitial(adUnitID: interstitialId)
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.loadRequest(request)
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
        let randomX = randomGenerate(contentFrame.origin.x, max: contentFrame.size.width - 2.5*padding)
        let randomY = randomGenerate(contentFrame.origin.y, max: contentFrame.size.height - 2.5*padding)
        let randomHeight = randomGenerate(padding, max: min(contentFrame.height - randomY, maxLimitForRandomFrame))
        let randomWidth = randomGenerate(padding, max: min(contentFrame.width - randomX, maxLimitForRandomFrame))        
        let originalFrame = CGRectMake(randomX, randomY, randomWidth, randomHeight)
        return originalFrame
    }
    
    func generateNonIntersectingFrame(pieceCount : Int, contentFrame : CGRect, previousPuzzlePieces : [PuzzlePiece]) -> CGRect {
        var rect : CGRect?
        while (true) {
            rect = tryToGenerateNonIntersectingFrame(pieceCount, contentFrame: contentFrame, previousPuzzlePieces: previousPuzzlePieces)
            if (rect != nil) {
                break
            } else {
                print("Trying to generate again. Even low possibility, this approach can cause infinite loop")
            }
        }
        return rect!
    }
    
    func tryToGenerateNonIntersectingFrame(pieceCount : Int, contentFrame : CGRect, previousPuzzlePieces : [PuzzlePiece]) -> CGRect? {
        let originalFrame = generateOriginalFrame(pieceCount, contentFrame: contentFrame)
        var intersectionOccurs = false
        for puzzlePiece in previousPuzzlePieces {
            if(CGRectIntersectsRect(originalFrame, puzzlePiece.frameCorrectPosition)) {
                intersectionOccurs = true
                break
            }
        }
        if(intersectionOccurs) {
            return nil
        } else {
            return originalFrame
        }
    }
    
    func initGameScene(pieceCount : Int = 7) -> Void {
        puzzlePieces.removeAll()
        self.resetButton.enabled = false
        self.gameBackgroundImageView.image = self.gameBackgroundImageView.image
        let level = gameStatsModel.gameOffset+gameStatsModel.gameLevel
        AudioModel.sharedInstance.backgroundAudio?.play()
        
        let newImageName = self.backgroundImageNames[level%self.backgroundImageNames.count]
        UIView .transitionWithView(self.gameBackgroundImageView,
                                   duration: 4,
                                   options: UIViewAnimationOptions.TransitionCurlDown,
        animations: {
            [unowned self] in
            self.gameBackgroundImageView.image = UIImage(named: newImageName)
        }, completion: {[unowned self] (finished : Bool) -> () in
            for i in 1...pieceCount {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(
                    Double(i * 200) * Double(NSEC_PER_MSEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    [unowned self] in
                    self.addPiece(i, pieceCount: pieceCount, level: level)
                    })
            }
            self.leveLabel.text = "LEVEL \(level)"
            self.view.bringSubviewToFront(self.leveLabel)
            
            let resetButtonActivateTime = dispatch_time(DISPATCH_TIME_NOW, Int64( 1 * Double(NSEC_PER_SEC)))
            dispatch_after(resetButtonActivateTime, dispatch_get_main_queue(), {
                [unowned self] in
                self.resetButton.enabled = true
                })
        })
    }
    
    
    func addPiece(withIndex : Int, pieceCount : Int, level : Int) {
        let referenceFrame = self.puzzlePieceContainerView.frame
        let contentFrame = self.gameBackgroundImageView.frame
        let pieceWidth = referenceFrame.size.width
        let pieceHeight = pieceWidth
        let heightStep = pieceWidth
        
        
        let padding : CGFloat = 5
        
        let shelfFrame = CGRectMake(referenceFrame.origin.x, padding * CGFloat(withIndex) + (heightStep * CGFloat(withIndex-1)), pieceWidth, pieceHeight)
        
        let originalFrame = self.generateNonIntersectingFrame(pieceCount, contentFrame: contentFrame, previousPuzzlePieces: self.puzzlePieces)
        
        let pieceColor = colors[(level + withIndex)%colors.count]
        let convertedFrame = self.view.convertRect(originalFrame, toView: self.gameBackgroundImageView)
        
        let placeHolderView = UIView(frame: originalFrame)
        let puzzlePiece = PuzzlePiece(frame: shelfFrame, correctPositionFrame: originalFrame,delegate: self)
        
        
        var pieceBGImage = ImageModel.cropToBounds(self.gameBackgroundImageView,
                                                   rect: convertedFrame)
        
        //let triangle = UIImage(named: "mask_triangle")!
        //pieceBGImage = Toucan(image: pieceBGImage).maskWithImage(maskImage: triangle).image
        
        placeHolderView.backgroundColor = UIColor.blackColor()
        placeHolderView.layer.cornerRadius = puzzlePiece.layer.cornerRadius + 2
        self.view.addSubview(placeHolderView)
        
        puzzlePiece.backgroundColor = pieceColor
        puzzlePiece.contentMode = UIViewContentMode.ScaleToFill
        puzzlePiece.image = pieceBGImage
        puzzlePiece.placeHolderView = placeHolderView
        
        self.puzzlePieces.append(puzzlePiece)
        self.view.addSubview(puzzlePiece)
        puzzlePiece.shrink()
        
        
    }
    
    
    //MARK: - ResetScene
    
    func reset() {
        self.gameBackgroundImageView.setNeedsDisplay()
        for puzzlePiece in puzzlePieces {
            puzzlePiece.remove()
        }        
        gameStatsModel.gameLevel += 1
        
        let bannerLevel = 3
        if(gameStatsModel.gameLevel > bannerLevel
            && self.bannerBottomConstraint.constant < 0) {
            self.initBanner()
        }
    }
    
    @IBAction func resetButtonPressed() {
        resetButtonPressedTime += 1
        if(resetButtonPressedTime % 2 == 0 && interstitial.isReady) {
            interstitial.presentFromRootViewController(self)
        }
        resetGameScene()
    }
    
    func resetGameScene() {
        for puzzlePiece in puzzlePieces {
            if(!puzzlePiece.isPointAcceptiable(puzzlePiece.frame.origin)
                && (puzzlePiece.frame != puzzlePiece.frameShelfPosition)) {
                print("Some pieces are still in move. Wait and try again.")
                return
            }
        }
        
        self.reset()
        
        var pieceCount : Int = Int(self.gameBackgroundImageView.frame.size.height / self.puzzlePieceContainerView.frame.size.height)
        pieceCount = min(pieceCount, gameStatsModel.gameLevel)
        self.initGameScene(pieceCount)
    }
    
    //Mark: - PuzzlePieceDelegate
    func fitInCorrectPlace(puzzlePiece : PuzzlePiece) {
        checkToResetGame()
    }
    
    func checkToResetGame() {
        for puzzlePiece in puzzlePieces {
            if(!puzzlePiece.isPointAcceptiable(puzzlePiece.frame.origin)) {
                print("Level is not completed yet")
                return
            }
        }
        AudioModel.sharedInstance.applause?.play()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            [unowned self] in
            self.resetGameScene()
            })
    }
}

extension ViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
       self.bannerBottomConstraint.constant = 0
        print("adViewDidReceiveAd")
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("error on loading ad..")
    }
}

extension ViewController : GADInterstitialDelegate {
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        initInterstitial()
    }
}
