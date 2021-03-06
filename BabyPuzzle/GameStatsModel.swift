//
//  GameStatsModel.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 19/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation


class GameStatsModel: BaseModel {
    static let sharedInstance = GameStatsModel()
    //private init() {} //This prevents others from using the default '()' initializer for this class.
    
    private let gameLevelKey = "GameLevelKey"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var gameOffset = 0
    var gameLevel : Int
    
    override private init() {
        gameLevel = max(0, defaults.integerForKey(gameLevelKey)-1)
        #if DEBUG
            gameOffset = (Int(arc4random_uniform(UInt32(1000))) % 10)
            gameLevel = 8
        #endif
    }
    
    func nexLevel() {
        gameLevel += 1
        defaults.setObject(gameLevel, forKey: gameLevelKey)
        defaults.synchronize()
    }
}