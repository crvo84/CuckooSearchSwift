//
//  CuckooSearchBrain.swift
//  CuckooSearch
//
//  Created by Carlos Rogelio Villanueva Ousset on 3/19/17.
//  Copyright © 2017 villou. All rights reserved.
//

import Foundation

class CuckooSearchBrain {
    
    // TODO: when solving an economic function, set constraints
    
    private struct Config {
        static let nestCount = 10
        static let cuckooCount = 10
        static let generationCount = 1000
        static let abandonedNestsFraction = 0.5
        static let randomMin = 0
        static let randomMax = 100000
    }

//    func searchMax() -> ((x: Double, y: Double)) {
//        var nests = generateInitialNests()
//        var cuckoos
//        
//        for _ in 0..<Config.generationCount {
//            let random
//            
//        }
//        
//    }
    
    private func generateInitialNests() -> ([Egg])  {
        var nests = [Egg]()
        for _ in 0..<Config.nestCount {
            let newRandomEgg = generateRandomEgg()
            nests.append(newRandomEgg)
        }
        
        return nests
    }
    
    private func generateRandomEgg() -> Egg {
        let x = Double(arc4random_uniform(UInt32(Config.randomMax)) + 1)
        let y = Double(arc4random_uniform(UInt32(Config.randomMax)) + 1)
        
        return Egg(x: x, y: y)
    }
    
    private func generateStepSizeEgg(egg: Egg) -> Egg {
        let xStep = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let yStep = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let xPlusStep = egg.x + xStep
        let yPlusStep = egg.y + yStep
        
        return Egg(x: xPlusStep, y: yPlusStep)
    }
    
    private func utility(egg: Egg) -> Double {
        /* 
         U(x,y) = -2x^2 +60x -3y^2 +72y +100
         optimal(max): x = 15, y = 12
        */
        let a = -2 * pow(egg.x, 2)
        let b = 60 * egg.x
        let c = -3 * pow(egg.y, 2)
        let d = 72 * egg.y
        let e = 100.0
        
        let utility = a + b + c + d + e
        
        return utility
    }
}

class Cuckoo {
    var egg: Egg
    
    init(egg: Egg) {
        self.egg = egg
    }
}

struct Egg {
    let x: Double
    let y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = x
    }
}
