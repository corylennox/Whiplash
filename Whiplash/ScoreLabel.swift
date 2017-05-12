//
//  ScoreLabel.swift
//  ProjectNoName
//
//  Created by Cory Lennox on 5/6/17.
//  Copyright © 2017 Palm Studios. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class ScoreLabel: SKLabelNode {
    
    var number = 0
    
    var scoreChanged = false
    
    init(num: Int)
    {
        super.init()
        
        fontColor = UIColor.black
        fontName = "Helvetica"
        fontSize = 35.0
        
        number = num
        text = "\(num)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func increment() {
        number += 1
        text = "\(number)"
    }
    
    func setTo(_ num: Int) {
        self.number = num
        text = "\(self.number)"
    }
    
}
