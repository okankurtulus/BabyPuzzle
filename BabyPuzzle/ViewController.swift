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

//MARK - ByPass Print for Prod
func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
    #endif
}

class ViewController: UIViewController, PuzzlePieceDelegate {
    
    @IBOutlet var resetButton : UIButton!
    @IBOutlet var puzzlePieceContainerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var gameBackgroundImageView: UIImageView!
    @IBOutlet var leveLabel : UILabel!
    
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var bannerBottomConstraint : NSLayoutConstraint!
    var isBannerBottomInited : Bool = false
    var interstitial: GADInterstitial!
    var resetButtonPressedTime = 0
    
    var puzzlePieces : Array = [PuzzlePiece]()
    
    let gameStatsModel = GameStatsModel.sharedInstance
    var isFirstOpen = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.puzzlePieceContainerView.backgroundColor = UIColor.clearColor()
        isBannerBottomInited = false
        initLevelLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(isFirstOpen) {
            resetGameScene()
            isFirstOpen = false
        }
    }
    
    func initLevelLabel() {
        if #available(iOS 8.2, *) {
            self.leveLabel.font = UIFont.systemFontOfSize(18, weight: 2)
        } else {
            // Fallback on earlier versions
            self.leveLabel.font = UIFont.systemFontOfSize(18)
        }
        self.leveLabel.textColor = UIColor.blueColor()
        self.leveLabel.shadowOffset = CGSizeMake(1, 1)
        self.leveLabel.shadowColor = UIColor.grayColor()
        self.leveLabel.text = ""
    }
    
    //MARK: - Google Ads
    
    func initBanner()  {
        #if DEBUG
            let bannerId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_BANNER_TEST)
        #else
            let bannerId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_BANNER)
        #endif
        
        bannerView.adUnitID = bannerId
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.loadRequest(GADRequest())        
    }
    
    func initInterstitial() {
        #if DEBUG
            let interstitialId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_INTERSTITIAL_TEST)
        #else
            let interstitialId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_INTERSTITIAL)
        #endif
        interstitial = GADInterstitial(adUnitID: interstitialId)
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.loadRequest(request)
    }
    
    //MARK: - GameScene
    
    func randomGenerate(min : CGFloat, max : CGFloat) -> CGFloat {
        if(max <= min) {
            return min
        }
        
        let diff = UInt32(max-min)
        let randomValue = (arc4random_uniform(diff) + UInt32(min))
        return CGFloat(randomValue)
    }
    
    func generateOriginalFrame(pieceCount : Int, contentFrame : CGRect) -> CGRect {
        let padding : CGFloat = 50
        let maxLimitForRandomFrame = min(contentFrame.size.width, contentFrame.size.height) / 2
        let randomX = randomGenerate(contentFrame.origin.x, max: contentFrame.size.width - 2.5*padding)
        let randomY = randomGenerate(contentFrame.origin.y, max: contentFrame.size.height - 2.5*padding)
        
        let minWidth = self.puzzlePieceContainerView.frame.size.width
        let randomHeight = randomGenerate(minWidth, max: min(contentFrame.height - randomY, maxLimitForRandomFrame))
        let randomWidth = randomHeight // randomGenerate(minWidth, max: min(contentFrame.width - randomX, maxLimitForRandomFrame))
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
        
        let newImageName = BackgroundImageModel.names[(level-1) % BackgroundImageModel.names.count]
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
        
        let convertedFrame = self.view.convertRect(originalFrame, toView: self.gameBackgroundImageView)
        
        let placeHolderView = UIImageView(frame: originalFrame)
        let puzzlePiece = PuzzlePiece(frame: shelfFrame, correctPositionFrame: originalFrame,delegate: self)
        
        
        let maskIndex = ((level / 3) + (withIndex-1)) % MaskImageModel.names.count
        let maskImageName = MaskImageModel.names[maskIndex]
        let mask = UIImage(named: maskImageName)!
        
        var pieceBGImage = ImageModel.cropToBounds(self.gameBackgroundImageView,
                                                   rect: convertedFrame)
        pieceBGImage = Toucan(image: pieceBGImage).maskWithImage(maskImage: mask).image
        var placeHolderBg = UIImage(named: "black")!
        placeHolderBg = Toucan(image: placeHolderBg).maskWithImage(maskImage: mask).image        
        
        placeHolderView.image = placeHolderBg
        placeHolderView.backgroundColor = UIColor.clearColor()
        placeHolderView.contentMode = UIViewContentMode.ScaleToFill
        placeHolderView.clipsToBounds = true
        placeHolderView.accessibilityIdentifier = "placeHolder\(withIndex)"
        self.view.addSubview(placeHolderView)
        
        puzzlePiece.backgroundColor = UIColor.clearColor()
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
        gameStatsModel.nexLevel()
        
        let bannerLevel = 1
        if(gameStatsModel.gameLevel > bannerLevel
            && self.bannerBottomConstraint.constant < 0
            && !isBannerBottomInited) {
            self.initBanner()
        } else if (isBannerBottomInited) {
            self.bannerBottomConstraint.constant = 0
        }
        
        if(interstitial == nil || !interstitial.isReady) {
            self.initInterstitial()
        }
        
    }
    
    @IBAction func resetButtonPressed() {
        resetButtonPressedTime += 1
        if(resetButtonPressedTime % 2 == 0 && interstitial.isReady) {
            interstitial.presentFromRootViewController(self)
        } else {
            resetGameScene()
        }
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
        pieceCount = min(pieceCount - 1, gameStatsModel.gameLevel)
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

//MARK: - Banner Ad delegate
extension ViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        isBannerBottomInited = true
    }
}

//MARK: - Interstitial Ad delegate
extension ViewController : GADInterstitialDelegate {
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        AudioModel.sharedInstance.backgroundAudio?.stop()
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        AudioModel.sharedInstance.backgroundAudio?.play()
        initInterstitial()
    }
    
    func interstitialDidFailToPresentScreen(ad: GADInterstitial!) {
        AudioModel.sharedInstance.backgroundAudio?.play()
    }
    
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image.CGImage else { return nil }
        self.init(CGImage: cgImage)
    }
}
