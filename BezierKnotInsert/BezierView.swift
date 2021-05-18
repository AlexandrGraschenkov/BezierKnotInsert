//
//  BezierView.swift
//  BezierKnotInsert
//
//  Created by Alexander Graschenkov on 18.05.2021.
//

import UIKit

struct BezierPoint {
    var p: CGPoint
    var control: CGPoint // relatively to P
    
    var controlGlobal1: CGPoint {
        get { p + control }
        set { control = newValue - p }
    }
    var controlGlobal2: CGPoint {
        get { p - control }
        set { control = p - newValue }
    }
    
    subscript(index:Int) -> CGPoint {
        get {
            switch index {
            case 0: return p
            case 1: return controlGlobal1
            case 2: return controlGlobal2
            default: return .zero
            }
        }
        set(newValue) {
            switch index {
            case 0: p = newValue
            case 1: controlGlobal1 = newValue
            case 2: controlGlobal2 = newValue
            default: break
            }
        }
    }
}

struct BezierSegment {
    let p1: BezierPoint
    let p2: BezierPoint
    
    // https://stackoverflow.com/a/5634528/820795
    func getPoint(t: CGFloat) -> CGPoint {
        let t_1 = 1 - t
        var p: CGPoint = (t_1 * t_1 * t_1) * p1.p
        p += 3*(t_1 * t_1 * t) * p1.controlGlobal1
        p += 3*(t_1 * t * t) * p2.controlGlobal2
        p += (t * t * t) * p2.p
        return p
    }
    
    func split(t: CGFloat) -> [BezierPoint] {
        let P0 = p1.p, P1 = p1.controlGlobal1, P2 = p2.controlGlobal2, P3 = p2.p
        let P0_1 = (1-t)*P0 + t*P1
        let P1_2 = (1-t)*P1 + t*P2
        let P2_3 = (1-t)*P2 + t*P3

        let P01_12 = (1-t)*P0_1 + t*P1_2
        let P12_23 = (1-t)*P1_2 + t*P2_3

        let P0112_1223 = (1-t)*P01_12 + t*P12_23
        
        var res0 = BezierPoint(p: P0, control: .zero)
        var res1 = BezierPoint(p: P0112_1223, control: .zero)
        var res2 = BezierPoint(p: P3, control: .zero)
        
        res0.controlGlobal1 = P0_1
        res1.controlGlobal1 = P12_23
        res2.controlGlobal2 = P2_3
        return [res0, res1, res2]
    }
}

extension CGPoint {
    func expandToRect(_ size: CGFloat) -> CGRect {
        let r = CGRect(x: x-size/2,
                       y: y-size/2,
                       width: size,
                       height: size)
        return r
    }
}

class BezierView: UIView {
    var points: [BezierPoint] = [] {
        didSet {
            updateSplitPoint()
            self.setNeedsDisplay()
        }
    }
    
    var splitPointPos: CGFloat? {
        didSet { updateSplitPoint() }
    }
    fileprivate(set) var splitPoint: CGPoint?
    
    func split() {
        guard var prog = splitPointPos, points.count > 1 else {
            splitPoint = nil
            return
        }
        
        var segmentIdx = Int(CGFloat(points.count-1) * prog)
        segmentIdx = min(segmentIdx, points.count-2)
        prog = prog - CGFloat(segmentIdx) / CGFloat(points.count-1)
        prog *= CGFloat(points.count-1)
        
        let seg = BezierSegment(p1: points[segmentIdx], p2: points[segmentIdx+1])
        let newPoints = seg.split(t: prog)
        points.replaceSubrange(segmentIdx..<(segmentIdx+2), with: newPoints)
    }
    
    func removeCloseToSplit() {
        guard var prog = splitPointPos, points.count > 1 else {
            splitPoint = nil
            return
        }
        
        var segmentIdx = Int(CGFloat(points.count-1) * prog)
        segmentIdx = min(segmentIdx, points.count-2)
        prog = prog - CGFloat(segmentIdx) / CGFloat(points.count-1)
        prog *= CGFloat(points.count-1)
        if prog > 0.5 {
            segmentIdx += 1
        }
        
        points.remove(at: segmentIdx)
    }
    
    func updateSplitPoint() {
        guard var prog = splitPointPos, points.count > 1 else {
            splitPoint = nil
            return
        }
        
        var segmentIdx = Int(CGFloat(points.count-1) * prog)
        segmentIdx = min(segmentIdx, points.count-2)
        prog = prog - CGFloat(segmentIdx) / CGFloat(points.count-1)
        prog *= CGFloat(points.count-1)
        
        
        // calculate point
        let seg = BezierSegment(p1: points[segmentIdx], p2: points[segmentIdx+1])
        splitPoint = seg.getPoint(t: prog)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext(), points.count > 0 else {
            return
        }
        
        // Control lines
        for p in points {
            ctx.move(to: p.controlGlobal1)
            ctx.addLine(to: p.controlGlobal2)
        }
        ctx.setLineDash(phase: 3, lengths: [3, 3])
        UIColor.gray.setStroke()
        ctx.setLineWidth(1)
        ctx.strokePath()
        
        // Control points
        let pointDrawSize: CGFloat = 10.0
        UIColor.green.setFill()
        for p in points {
            ctx.fillEllipse(in: p.controlGlobal1.expandToRect(10))
            ctx.fillEllipse(in: p.controlGlobal2.expandToRect(10))
        }
        
        // Points
        UIColor.red.setFill()
        for p in points {
            ctx.fillEllipse(in: p.p.expandToRect(5))
        }
        
        // Bezier
        ctx.setLineDash(phase: 0, lengths: [])
        ctx.move(to: points[0].p)
        for i in 1..<points.count {
            ctx.addCurve(to: points[i].p, control1: points[i-1].controlGlobal1, control2: points[i].controlGlobal2)
        }
        
        UIColor.red.setStroke()
        ctx.setLineWidth(2)
        ctx.strokePath()
        
        if let split = splitPoint {
            UIColor.blue.setFill()
            ctx.fillEllipse(in: split.expandToRect(10))
        }
    }
}
