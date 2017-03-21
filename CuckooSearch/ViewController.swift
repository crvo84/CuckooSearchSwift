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

    @IBOutlet weak var searchButton: UIButton!

    @IBOutlet weak var resultLabel: UILabel!
    
    fileprivate let cuckooSearchBrain = CuckooSearchBrain()
    
    fileprivate var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGraph()
    }
    
    private func setupGraph() {
        graphView?.layer.cornerRadius = 8
        graphView?.layer.masksToBounds = true
        
        graphView.enableTouchReport = true
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
    
    @IBAction func performCuckooSearch(_ sender: Any) {
        guard !isSearching else { return }
        
        isSearching = true
        cuckooSearchBrain.performSearch { [weak self] in
            
            if
                let bestSolutionEggs = self?.cuckooSearchBrain.bestSolutionEggs,
                let lastEgg = bestSolutionEggs.last {
                    self?.updateResultLabel(egg: lastEgg, generation: bestSolutionEggs.count)
            }
            
            self?.graphView?.reloadGraph()
        }
    }
    
    fileprivate func updateResultLabel(egg: Egg, generation: Int) {
        let intValues = egg.values.map { Int($0) }
        resultLabel?.text = "\(intValues)   t = \(generation)"
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
    func lineGraphDidFinishDrawing(_ graph: BEMSimpleLineGraphView) {
        isSearching = false
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String! {
        return "\(index)"
    }
    
    func numberOfGapsBetweenLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        guard let eggs = cuckooSearchBrain.bestSolutionEggs else { return 0 }
        let numberOfLabels = 4
        let num = numberOfLabels + 2 // labels are not shown at edges
        
        return (eggs.count - num) / (num - 1)
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        if let egg = cuckooSearchBrain.bestSolutionEggs?[index] {
            updateResultLabel(egg: egg, generation: index + 1)
        }
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, didReleaseTouchFromGraphWithClosestIndex index: CGFloat) {
        if
            let bestSolutionEggs = cuckooSearchBrain.bestSolutionEggs,
            let lastEgg = bestSolutionEggs.last {
                updateResultLabel(egg: lastEgg, generation: bestSolutionEggs.count)
        }
    }
}
