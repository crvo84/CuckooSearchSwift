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
    
    // Function vars
    static var productCount: Int {
        return productMaxValues.count
    }
    
    /* ---------------------------------------------------------------- */
    /* -------------------------- CONFIGURABLE ------------------------ */
    /* ---------------------------------------------------------------- */
    // More Cuckoos allows you to search in new places, to avoid local maximums
    /* 
      10-10 best result
      10-100 fast to find best, but far from optimum
     */
    
/*
    var nestCount = 10
    var cuckooCount = 10
    var generationCount = 900
    var nestsToAbandonFraction = 0.5
    
    static let productPrices: [Double] = [20, 20] // c/ product se multiplica por un precio
    static var maxTotal: Double = Double(UInt32.max)
    
    fileprivate static func utility(egg: Egg) -> Double {
        guard egg.values.count == productCount else {
            fatalError("Given Egg has no valid product count")
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
*/
    
    
    var nestCount = 10
    var cuckooCount = 10
    var generationCount = 5000
    var nestsToAbandonFraction = 0.5
    
    static let productPrices: [Double] = [1, 1, 1] // c/ product se multiplica por un precio
    static var totalBudget: Double = 120 // total (sum of productCount * price)
    
    fileprivate static func utility(egg: Egg) -> Double {
        guard egg.values.count == productCount else {
            fatalError("Given Egg has no valid product count")
        }
        
        /*
         U(x,y,z) = 2xy +2xz +2yz
         optimal(max): x = 40, y = 40, z = 40, U = 9,600
         */

        let x = egg.values[0]
        let y = egg.values[1]
        let z = egg.values[2]
        let utility = 2*x*y + 2*x*z + 2*y*z
        
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
        for _ in 0..<generationCount {
            // get random cuckoo
            let randomCuckooIndex = Int(arc4random_uniform(UInt32(cuckoos.count)))
            var randomCuckoo = cuckoos[randomCuckooIndex]
            // replace egg with levy flights
            randomCuckoo.egg = CuckooSearchBrain.generateStepSizeEgg(egg: randomCuckoo.egg)
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
            nests = CuckooSearchBrain.nestsAfterAbandoningFraction(fraction: nestsToAbandonFraction, nests: nests)
            
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
        for _ in 0..<nestCount {
            let newNest = Nest(egg: CuckooSearchBrain.generateRandomEgg())
            nests.append(newNest)
        }
        
        return nests
    }
    
    private func generateInitialCuckoos() -> [Cuckoo] {
        var cuckoos = [Cuckoo]()
        for _ in 0..<cuckooCount {
            let newCuckoo = Cuckoo(egg: CuckooSearchBrain.generateRandomEgg())
            cuckoos.append(newCuckoo)
        }
        
        return cuckoos
    }
    
    private static func nestsAfterAbandoningFraction(fraction: Double, nests: [Nest]) -> [Nest] {
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
    
    private static func generateRandomEgg() -> Egg {
        var values = [Double]()
        var budgetLeft = totalBudget
        
        let indexes = ShuffleManager.arrayOfShuffledIndexes(count: CuckooSearchBrain.productCount)
        for index in 0..<indexes.count {
            let budgetForProductUpperBoundNotIncluded = UInt32(budgetLeft + 1) // zero included
            let budgetForProduct = Double(arc4random_uniform(budgetForProductUpperBoundNotIncluded))
            let productPrice = productPrices[index]
            let value = budgetForProduct/productPrice
            budgetLeft -= value * productPrice
            values.insert(value, at: index)
        }

        return Egg(values: values)
    }
    
    private static func generateStepSizeEgg(egg: Egg) -> Egg {
        var valuesPlusStep = [Double]()
        
        for i in 0..<CuckooSearchBrain.productCount {
            let step = getRandomStep()
            
            let oldValue = egg.values[i]
            let oldValuePlusStep = productMaxValues[i] + step
            let newValue = max(min(oldValuePlusStep, oldValue), 0.0)
            
            valuesPlusStep.append(newValue)
        }

        return Egg(values: valuesPlusStep)
    }
    
    private static func getRandomStep() -> Double {
        switch arc4random_uniform(3) {
        case 0: return -1.0
        case 1: return +1.0
        default: return +0.0
        }
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
