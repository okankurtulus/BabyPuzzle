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
    
    var gameOffset = 0
    var gameLevel = 1
    
    override private init() {
        gameOffset = Int(arc4random_uniform(UInt32(1000)))
    }
    
}