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
    }

    private var nests = [(x: Double, y: Double)]()
    
    private func setupNests() {
        for _ in 0..<Config.nestCount {
            let x = 1.0
            let y = 1.0
            nests.append((x, y))
        }
    }
    
    
    private func utility(x: Double, y: Double) -> Double {
        /* u(x,y) = -2x^2 +60x -3y^2 +72y +100
         optimal(max): x = 15, y = 12
        */
        let a = -2 * pow(x, 2)
        let b = 60 * x
        let c = -3 * pow(y, 2)
        let d = 72 * y
        let e = 100.0
        
        let utility = a + b + c + d + e
        
        return utility
    }
    
    
}
