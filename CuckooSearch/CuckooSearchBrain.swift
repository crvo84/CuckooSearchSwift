//
//  CuckooSearchBrain.swift
//  CuckooSearch
//
//  Created by Carlos Rogelio Villanueva Ousset on 3/19/17.
//  Copyright © 2017 villou. All rights reserved.
//

import Foundation

protocol CuckooSearchBrainDelegate: class {
    func newGenerationSimulated(cuckooSearchBrain: CuckooSearchBrain, currentBest: Egg?, utility: Double?)
}

class CuckooSearchBrain {
    
    // TODO: when solving an economic function, set constraints
    
    /* 
     Assumptions:
        1) One egg per nest
        2) One egg per cuckoo
     */
    
    weak var delegate: CuckooSearchBrainDelegate?
    
    /* ---------------------------------------------------------------- */
    /* -------------------------- CONFIGURABLE ------------------------ */
    /* ---------------------------------------------------------------- */
    private struct Config {
        static let nestCount = 10
        static let cuckooCount = 10
        static let generationCount = 1000
        static let nestsToAbandonFraction = 0.5
        static let randomMin = 0
        static let randomMax = 1000
        static let variablesCount = 2
    }
    
    private func utility(egg: Egg) -> Double {
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
    
    func searchBest() {
        // generate initial population of host nests and cuckoos
        var nests = generateInitialNests()
        var cuckoos = generateInitialCuckoos()
        
        for _ in 0..<Config.generationCount {
            // get random cuckoo
            let randomCuckooIndex = Int(arc4random_uniform(UInt32(cuckoos.count)))
            var randomCuckoo = cuckoos[randomCuckooIndex]
            // replace egg with levy flights
            randomCuckoo.egg = generateStepSizeEgg(egg: randomCuckoo.egg)
            let randomCuckooEggUtility = utility(egg: randomCuckoo.egg)
            
            // get random nest
            let randomNestIndex = Int(arc4random_uniform(UInt32(nests.count)))
            let randomNest = nests[randomNestIndex]
            let randomNestEggUtility = utility(egg: randomNest.egg)
            
            if randomCuckooEggUtility > randomNestEggUtility {
                // replace nest egg with cuckoo egg
                nests[randomNestIndex].egg = randomCuckoo.egg
            }
            
            // Abandon worst nests (amount determined by Config fraction)
            nests = nestsAfterAbandoningFraction(fraction: Config.nestsToAbandonFraction, nests: nests)
            
            // report best solution egg via delegate
            let bestSolutionEgg = nests.first?.egg
            let bestSolutionUtility = bestSolutionEgg != nil ? utility(egg: bestSolutionEgg!) : nil
            delegate?.newGenerationSimulated(cuckooSearchBrain: self, currentBest: bestSolutionEgg, utility: bestSolutionUtility)
        }
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
            return utility(egg: lhs.egg) > utility(egg: rhs.egg)
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
            let step = arc4random_uniform(2) == 0 ? -1.0 : 1.0
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
}
