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
    /* 
        Constraints can be set by modifying randomMax with the value that corresponds assigning
        all the budget to that product/variable
     */
    
    /* 
     Assumptions:
        1) One egg per nest
        2) One egg per cuckoo
     */

    private(set) var bestSolutionEggs: [Egg]?
    
    /* ---------------------------------------------------------------- */
    /* -------------------------- CONFIGURABLE ------------------------ */
    /* ---------------------------------------------------------------- */
    // More Cuckoos allows you to search in new places, to avoid local maximums
    /* 
      10-10 best result
      10-100 fast to find best, but far from optimum
     */
    private struct Config {
        static let nestCount = 10
        static let cuckooCount = 10
        static let generationCount = 10000
        static let nestsToAbandonFraction = 0.5
        static let randomMin = 0
        static let randomMax = 1000
        static let variablesCount = 2
    }
    
    fileprivate static func utility(egg: Egg) -> Double {
        guard egg.values.count == Config.variablesCount else {
            fatalError("Given Egg has no valid variables count")
        }
        
        /*
         U(x,y) = -2x^2 +60x -3y^2 +72y +100
         optimal(max): x = 15, y = 12
         */
        let a = -2 * pow(egg.values[0], 2)
        let b = 60 * egg.values[0]
        let c = -3 * pow(egg.values[1], 2)
        let d = 72 * egg.values[1]
        let e = 100.0
        
        let utility = a + b + c + d + e
        
        return utility
    }
    /* ---------------------------------------------------------------- */
    /* ---------------------------------------------------------------- */
    /* ---------------------------------------------------------------- */
    
    func reset() {
        self.bestSolutionEggs = nil
    }
    
    func performSearch(completion: () -> ()) {
        // reset best solution eggs
        reset()
        
        // generate initial population of host nests and cuckoos
        var nests = generateInitialNests()
        var cuckoos = generateInitialCuckoos()
        
        var bestSolutionEggs = [Egg]()
        for _ in 0..<Config.generationCount {
            // get random cuckoo
            let randomCuckooIndex = Int(arc4random_uniform(UInt32(cuckoos.count)))
            var randomCuckoo = cuckoos[randomCuckooIndex]
            // replace egg with levy flights
            randomCuckoo.egg = generateStepSizeEgg(egg: randomCuckoo.egg)
            let randomCuckooEggUtility = CuckooSearchBrain.utility(egg: randomCuckoo.egg)
            
            // get random nest
            let randomNestIndex = Int(arc4random_uniform(UInt32(nests.count)))
            let randomNest = nests[randomNestIndex]
            let randomNestEggUtility = CuckooSearchBrain.utility(egg: randomNest.egg)
            
            if randomCuckooEggUtility > randomNestEggUtility {
                // replace nest egg with cuckoo egg
                nests[randomNestIndex].egg = randomCuckoo.egg
            }
            
            // Abandon worst nests (amount determined by Config fraction)
            nests = nestsAfterAbandoningFraction(fraction: Config.nestsToAbandonFraction, nests: nests)
            
            // report best solution egg via delegate
            guard let bestSolutionEgg = nests.first?.egg else {
                print("Could not find best solution")
                completion()
                return
            }
            
            bestSolutionEggs.append(bestSolutionEgg)
        }
        
        self.bestSolutionEggs = bestSolutionEggs
        completion()
    }
    
    private func generateInitialNests() -> [Nest]  {
        var nests = [Nest]()
        for _ in 0..<Config.nestCount {
            let newNest = Nest(egg: generateRandomEgg())
            nests.append(newNest)
        }
        
        return nests
    }
    
    private func generateInitialCuckoos() -> [Cuckoo] {
        var cuckoos = [Cuckoo]()
        for _ in 0..<Config.cuckooCount {
            let newCuckoo = Cuckoo(egg: generateRandomEgg())
            cuckoos.append(newCuckoo)
        }
        
        return cuckoos
    }
    
    private func nestsAfterAbandoningFraction(fraction: Double, nests: [Nest]) -> [Nest] {
        let validFraction = max(min(fraction, 1.0), 0.0)
        let originalNests = nests
        
        let abandonCount = Int(ceil(Double(originalNests.count) * validFraction))
        
        var sortedNests = originalNests.sorted { (lhs, rhs) -> Bool in
            return CuckooSearchBrain.utility(egg: lhs.egg) > CuckooSearchBrain.utility(egg: rhs.egg)
        }
        
        let firstIndexToAbandon = sortedNests.count - abandonCount
        for i in firstIndexToAbandon..<sortedNests.count {
            sortedNests[i].egg = generateRandomEgg()
        }
        
        return sortedNests
    }
    
    private func generateRandomEgg() -> Egg {
        var values = [Double]()
        for _ in 0..<Config.variablesCount {
            let upperBoundNotIncluded = UInt32(Config.randomMax + 1) // zero included
            let value = Double(arc4random_uniform(upperBoundNotIncluded))
            values.append(value)
        }
        
        return Egg(values: values)
    }
    
    private func generateStepSizeEgg(egg: Egg) -> Egg {
        var valuesPlusStep = [Double]()
        
        for i in 0..<Config.variablesCount {
            var step: Double
            
            switch arc4random_uniform(3) {
            case 0: step = -1.0
            case 1: step = +1.0
            default: step = +0.0
            }
            
            valuesPlusStep.append(egg.values[i] + step)
        }

        return Egg(values: valuesPlusStep)
    }
}

struct Nest {
    var egg: Egg
    
    init(egg: Egg) {
        self.egg = egg
    }
}

struct Cuckoo {
    var egg: Egg
    
    init(egg: Egg) {
        self.egg = egg
    }
}

struct Egg {
    let values: [Double]
    
    init(values: [Double]) {
        self.values = values
    }
    
    var utility: Double {
        return CuckooSearchBrain.utility(egg: self)
    }
}
