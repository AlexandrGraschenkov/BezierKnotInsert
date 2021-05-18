//
//  ViewController.swift
//  BezierKnotInsert
//
//  Created by Alexander Graschenkov on 18.05.2021.
//

import UIKit

fileprivate struct PointIdx {
    let idx: Int
    let pIdx: Int
}

fileprivate struct BezierState {
    let points: [BezierPoint]
    let splitPointPos: CGFloat?
}

class ViewController: UIViewController {
    
    @IBOutlet var bezierView: BezierView!
    @IBOutlet var backStateButt: UIButton!
    fileprivate var movingPoint: PointIdx? = nil
    var startPos: CGPoint = .zero
    fileprivate var states: [BezierState] = []
    
    func captureState() {
        states.append(BezierState(points: bezierView.points, splitPointPos: bezierView.splitPointPos))
        if states.count > 10 {
            states.remove(at: 0)
        }
        
        backStateButt.setTitle("\(states.count)", for: .normal)
    }
    
    func popLastState() {
        guard let last = states.popLast() else {
            return
        }
        
        bezierView.points = last.points
        bezierView.splitPointPos = last.splitPointPos
        backStateButt.setTitle("\(states.count)", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        bezierView.addGestureRecognizer(pan)
    }

    @IBAction func addPoint() {
        captureState()
        let count = bezierView.points.count
        let pos = CGPoint(x: CGFloat(1+count) * 80, y: CGFloat(1+count) * 80)
        bezierView.points.append(BezierPoint(p: pos, control: CGPoint(x: 40, y: 0)))
    }
    
    @IBAction func splitPressed() {
        captureState()
        bezierView.split()
        bezierView.splitPointPos = nil
    }
    @IBAction func removePressed() {
        popLastState()
    }
    @IBAction func splitChanged(_ slider: UISlider) {
        bezierView.splitPointPos = CGFloat(slider.value)
    }
    
    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        
        switch pan.state {
        case .began:
            let pos = pan.location(in: bezierView)
            movingPoint = getClosestPointIdx(pos: pos)
            if let movingPoint = movingPoint {
                captureState()
                startPos = bezierView.points[movingPoint.idx][movingPoint.pIdx]
            }
            
        case .changed:
            if let movingPoint = movingPoint {
                let offset = pan.translation(in: bezierView)
                bezierView.points[movingPoint.idx][movingPoint.pIdx] = offset + startPos
            }
            
        default:
            movingPoint = nil
        }
    }
    
    fileprivate func getClosestPointIdx(pos: CGPoint) -> PointIdx? {
        var minIdx: PointIdx? = nil
        var minDist: CGFloat = 35.0
        for (idx, p) in bezierView.points.enumerated() {
            for pIdx in 0..<3 {
                let dist = p[pIdx].distanceTo(pos)
                
                if dist < minDist {
                    minDist = dist
                    minIdx = PointIdx(idx: idx, pIdx: pIdx)
                }
            }
        }
        return minIdx
    }
}

