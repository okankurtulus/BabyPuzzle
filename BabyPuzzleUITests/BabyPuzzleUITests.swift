//
//  BabyPuzzleUITests.swift
//  BabyPuzzleUITests
//
//  Created by Okan Kurtulus on 30/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import XCTest

class BabyPuzzleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        setupSnapshot(app)
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testTake5SS() {
        //snapshot("ScreenShot_0")
        takeAScreenShot(1)
    }
    
    /*
    func testTake5SS1() { takeAScreenShot(1) }
    func testTake5SS2() { takeAScreenShot(2) }
    func testTake5SS3() { takeAScreenShot(3) }
    func testTake5SS4() { takeAScreenShot(4) }
    func testTake5SS5() { takeAScreenShot(5) }
    */
    
    func takeAScreenShot(index : Int) {
    
        let woodbgElementsQuery = XCUIApplication().otherElements.containingType(.Image, identifier:"woodbg")
        let image = woodbgElementsQuery.childrenMatchingType(.Image).elementBoundByIndex(1)
        let targetImage = XCUIApplication().otherElements.containingType(.Image, identifier:"placeHolder0").elementBoundByIndex(0)
        image.pressForDuration(0.1, thenDragToElement: targetImage)
        
        snapshot("ScreenShot_\(index)")
    }
    
}
