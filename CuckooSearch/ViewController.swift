//
//  ViewController.swift
//  CuckooSearch
//
//  Created by Carlos Rogelio Villanueva Ousset on 3/19/17.
//  Copyright © 2017 villou. All rights reserved.
//

import UIKit
import BEMSimpleLineGraph

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCuckooSearch()
    }
    
    private func setupCuckooSearch() {
        let cuckooSearchBrain = CuckooSearchBrain()
        cuckooSearchBrain.delegate = self
        cuckooSearchBrain.searchBest()
    }
}

extension ViewController: CuckooSearchBrainDelegate {
    
    func newGenerationSimulated(cuckooSearchBrain: CuckooSearchBrain, currentBest: Egg?, utility: Double?) {
        guard let bestValues = currentBest?.values else { return }
        guard let utility = utility else { return }
        
        print("best solution values: \(bestValues)")
        print("best solution utility: \(utility)")
    }
}
