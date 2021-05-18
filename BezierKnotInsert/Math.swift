//
//  Math.swift
//  SwingPose
//
//  Created by Alexander Graschenkov on 28.04.2021.
//

import UIKit

struct Line {
    var p1: CGPoint
    var p2: CGPoint
    
    func projectPercent(p: CGPoint, segment: Bool = false) -> CGFloat {
        let l2 = pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2);
        if l2 == 0.0 { return 0 }
        
        var t = (p - p1).dot(p2 - p1) / l2
        if segment {
            t = max(0, min(1, t))
        }
        return t
    }
    
    func project(p: CGPoint, segment: Bool = false) -> CGPoint {
        let t = projectPercent(p: p, segment: segment)
        return lerp(start: p1, end: p2, t: t)
    }
}

extension CGPoint {
    
    func dot(_ p: CGPoint) -> CGFloat {
        return x * p.x + y * p.y
    }
    
    /**
     * Returns the length (magnitude) of the vector described by the CGPoint.
     */
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    /**
     * Returns the squared length of the vector described by the CGPoint.
     */
    public func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    
    /**
     * Normalizes the vector described by the CGPoint to length 1.0 and returns
     * the result as a new CGPoint.
     */
    func normalized() -> CGPoint {
        let len = length()
        return len > 0 ? (self / len) : CGPoint.zero
    }
    
    /**
     * Normalizes the vector described by the CGPoint to length 1.0.
     */
    public mutating func normalize() -> CGPoint {
        self = normalized()
        return self
    }
    
    /**
     * Calculates the distance between two CGPoints. Pythagoras!
     */
    public func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
}

/**
 * Adds two CGPoint values and returns the result as a new CGPoint.
 */
public func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

/**
 * Adds two CGPoint values and returns the result as a new CGPoint.
 */
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

/**
 * Increments a CGPoint with the value of another.
 */
public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

/**
 * Subtracts two CGPoint values and returns the result as a new CGPoint.
 */
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

/**
 * Decrements a CGPoint with the value of another.
 */
public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}
/**
 * Multiplies two CGPoint values and returns the result as a new CGPoint.
 */
public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

/**
 * Multiplies a CGPoint with another.
 */
public func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}
/**
 * Multiplies the x and y fields of a CGPoint with the same scalar value and
 * returns the result as a new CGPoint.
 */
public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
public func * (scalar: CGFloat, point: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

/**
 * Multiplies the x and y fields of a CGPoint with the same scalar value.
 */
public func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

/**
 * Performs a linear interpolation between two CGPoint values.
 */
public func lerp(start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
    return start + (end - start) * t
}
