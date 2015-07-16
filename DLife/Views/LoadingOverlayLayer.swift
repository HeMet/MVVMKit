//
//  LoadingOverlayLayer.swift
//  DLife
//
//  Created by Евгений Губин on 09.07.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

class LoadingOverlayLayer: CAShapeLayer {

    let kCircleRadius = CGFloat(35.0)
    let kCircleWidth = CGFloat(5)
    
    var percentage: CGFloat = 33 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var angle: CGFloat {
        return 2 * CGFloat(M_PI) * percentage / 100
    }
    
    private var circleRadius: CGFloat {
        let minSize = min(bounds.width, bounds.height)
        let bigRadius = kCircleRadius + kCircleWidth
        return minSize > 2 * bigRadius ? kCircleRadius : (minSize * 0.8 - 2 * kCircleWidth) / 2
    }
    
    override init() {
        super.init()
        setup()
    }
    
    override init(layer: AnyObject!) {
        super.init(layer: layer)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        fillRule = kCAFillRuleEvenOdd
        fillColor = UIColor.blackColor().CGColor
        opacity = 0.6
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let offset = CGFloat(M_PI) / 2
        
        var bigRadius = circleRadius + kCircleWidth
        var bigCircle = UIBezierPath(roundedRect: CGRect(x: center.x - bigRadius, y: center.y - bigRadius, width: bigRadius * 2, height: bigRadius * 2), cornerRadius: bigRadius)
        
        var circlePath = UIBezierPath()
        if (percentage < 0.01) {
            circlePath.addArcWithCenter(center, radius: circleRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        } else {
            circlePath.moveToPoint(center)
            circlePath.addArcWithCenter(center, radius: circleRadius, startAngle: -offset, endAngle: angle - offset, clockwise: false)
            circlePath.moveToPoint(center)
        }
        
        var bgRect = UIBezierPath(rect: bounds)
        bgRect.appendPath(bigCircle)
        bgRect.appendPath(circlePath)
        bgRect.usesEvenOddFillRule = true
        
        path = bgRect.CGPath
    }
}
