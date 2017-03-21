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
    
    let cuckooSearchBrain = CuckooSearchBrain()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performCuckooSearch()
    }
    
    private func performCuckooSearch() {
        cuckooSearchBrain.performSearch { 
            
        }
    }

}
