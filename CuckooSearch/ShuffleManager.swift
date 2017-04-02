//
//  ShuffleManager.swift
//  CuckooSearch
//
//  Created by Carlos Rogelio Villanueva Ousset on 3/21/17.
//  Copyright © 2017 villou. All rights reserved.
//

import Foundation

class ShuffleManager {
    static func arrayOfShuffledIndexes(count: Int) -> [Int] {
        var arr = [Int]()
        for i in 0..<count {
            arr.append(i)
        }
        
        let shuffledArr = arr.shuffled()
        
        return shuffledArr
    }
}


/* Fisher-Yates (fast an uniform) shuffle */
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
