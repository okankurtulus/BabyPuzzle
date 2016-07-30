//
//  AudioModel.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 28/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation
import AVFoundation

class AudioModel: BaseModel {
    
    static let sharedInstance = AudioModel()
    var shrinkAudio : AVAudioPlayer?
    var expandAudio : AVAudioPlayer?
    var backgroundAudio : AVAudioPlayer?
    var puzzlePieceFitAudio : AVAudioPlayer?
    var successAudio : AVAudioPlayer?
    var applause : AVAudioPlayer?
    
    private override init() {
        super.init()
        backgroundAudio = initAudioPlayer("background", type: "mp3")
        backgroundAudio?.numberOfLoops = -1
        backgroundAudio?.volume = 0.1
        
        shrinkAudio = initAudioPlayer("shrink", type: "mp3")
        
        expandAudio = initAudioPlayer("expand", type: "mp3")
        
        puzzlePieceFitAudio = initAudioPlayer("fit", type: "mp3")
        
        successAudio = initAudioPlayer("success", type: "mp3")
        applause = initAudioPlayer("applause", type: "mp3")
    }
    
    private func initAudioPlayer(fileName : String, type : String) -> AVAudioPlayer? {
        var audioPlayer : AVAudioPlayer?
        do {
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: type)
            let url = NSURL.fileURLWithPath(path!)
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Audio player is not available")
        }
        return audioPlayer
    }
    
    
}