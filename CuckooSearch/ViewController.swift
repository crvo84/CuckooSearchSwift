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

    @IBOutlet weak var graphView: BEMSimpleLineGraphView!
    
    fileprivate let cuckooSearchBrain = CuckooSearchBrain()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGraph()
        performCuckooSearch()
    }
    
    private func setupGraph() {
        graphView?.layer.cornerRadius = 8
        graphView?.layer.masksToBounds = true
        
//        graphView.enableTouchReport = true
        graphView.enableYAxisLabel = true
        graphView.enableXAxisLabel = true
        graphView.autoScaleYAxis = true
        graphView.alwaysDisplayDots = false
        graphView.enableReferenceXAxisLines = true
        graphView.enableReferenceYAxisLines = true
        graphView.enableReferenceAxisFrame = true
        graphView.enableBezierCurve = true
        
        let bgColor = UIColor(red: 0.0, green: 45.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        graphView?.colorTop = bgColor
        graphView?.colorBottom = bgColor
        graphView?.backgroundColor = bgColor
        graphView?.colorYaxisLabel = UIColor.white
        graphView?.colorXaxisLabel = UIColor.white
    }

    private func performCuckooSearch() {
        cuckooSearchBrain.performSearch { 
            graphView?.reloadGraph()
        }
    }

}

extension ViewController: BEMSimpleLineGraphDataSource {
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return cuckooSearchBrain.bestSolutionEggs?.count ?? 0
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        guard let eggs = cuckooSearchBrain.bestSolutionEggs else { return 0.0 }
        
        return CGFloat(eggs[index].utility)
    }
}

extension ViewController: BEMSimpleLineGraphDelegate {

    
}
