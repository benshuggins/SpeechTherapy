//
//  GaugeView.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/1/19.
//  Copyright © 2019 User. All rights reserved.
//

// just add this

// now I add this 

import UIKit

@IBDesignable
class GaugeView: UIView {
    
    //var delegate: gaugeViewButtonDelegate?
    
    static let sharedGauge = GaugeView()
    
    //MARK: - gauge colors
    
    @IBInspectable var outerBezelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var outerBezelWidth: CGFloat = 10
    
    var innerBezelColor = UIColor.white
    var innerBezelWidth: CGFloat = 5
    
    var insideColor = UIColor.white
    
    //MARK: - Angle of gauge bezels
    var totalAngle: CGFloat = 270
    var rotation: CGFloat = -135
    
    //MARK: - draw needle variables
    var outerCenterDiscColor = UIColor(white: 0.9, alpha: 1)
    var outerCenterDiscWidth: CGFloat = 35
    var innerCenterDiscColor = UIColor(white: 0.7, alpha: 1)
    var innerCenterDiscWidth: CGFloat = 25
    
    // Segment thickness
    var segmentWidth: CGFloat = 30
    
    // there are currenty 16 segments array
    
    var segmentColors = [UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green"),
                         UIColor(named: "green")]
    
    // light up segment that corresponds to dB level
    func segmentTapped(segmentPosition: Float) {
        // print("😀😀😀😀😀\(segmentPosition)😀😀😀😀😀")
        
        if segmentPosition == 0.0 && segmentPosition <= 2 {
            segmentColors[0] = UIColor(named: "green")
            segmentColors[1] = UIColor(named: "green")
            segmentColors[2] = UIColor(named: "green")
            segmentColors[3] = UIColor(named: "green")
            segmentColors[4] = UIColor(named: "green")
            segmentColors[5] = UIColor(named: "green")
            segmentColors[6] = UIColor(named: "green")
            segmentColors[7] = UIColor(named: "green")
            segmentColors[8] = UIColor(named: "green")
            segmentColors[9] = UIColor(named: "green")
            segmentColors[10] = UIColor(named: "green")
            segmentColors[11] = UIColor(named: "green")
            segmentColors[12] = UIColor(named: "green")
            segmentColors[13] = UIColor(named: "green")
            segmentColors[14] = UIColor(named: "green")
            segmentColors[15] = UIColor(named: "green")
            setNeedsDisplay()
            
        }
        
        if segmentPosition > 2 && segmentPosition <= 10 {
            segmentColors[0] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[0] = UIColor(named: "green")
        }
        
        if segmentPosition > 10 && segmentPosition <= 20 {
            segmentColors[1] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[1] = UIColor(named: "green")
        }
        
        if segmentPosition > 20 && segmentPosition <= 30 {
            segmentColors[2] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[2] = UIColor(named: "green")
        }
     
        if segmentPosition > 30 && segmentPosition <= 40 {
            segmentColors[3] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[3] = UIColor(named: "green")
        }
        
        if segmentPosition > 40 && segmentPosition <= 50 {
            segmentColors[4] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[4] = UIColor(named: "green")
        }
        
        if segmentPosition > 50 && segmentPosition <= 60 {
            segmentColors[5] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[5] = UIColor(named: "green")
        }
        
        if segmentPosition > 60 && segmentPosition <= 70 {
            segmentColors[6] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[6] = UIColor(named: "green")
        }
        
        if segmentPosition > 70 && segmentPosition <= 80 {
            segmentColors[7] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[7] = UIColor(named: "green")
        }
        
        if segmentPosition > 80 && segmentPosition <= 90 {
            segmentColors[8] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[8] = UIColor(named: "green")
        }
        
        if segmentPosition > 90 && segmentPosition <= 100 {
            
            segmentColors[9] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[9] = UIColor(named: "green")
        }
        
        if segmentPosition > 100 && segmentPosition <= 110 {
            segmentColors[10] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[10] = UIColor(named: "green")
        }
        if segmentPosition > 110 && segmentPosition <= 120 {
            segmentColors[11] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[11] = UIColor(named: "green")
        }
        if segmentPosition > 120 && segmentPosition <= 130 {
            segmentColors[12] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[12] = UIColor(named: "green")
        }
        if segmentPosition > 130 && segmentPosition <= 140 {
            segmentColors[13] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[13] = UIColor(named: "green")
        }
        if segmentPosition > 140 && segmentPosition <= 150 {
            segmentColors[14] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[14] = UIColor(named: "green")
        }
        if segmentPosition > 150 && segmentPosition <= 160 {
            segmentColors[15] = UIColor(named: "red")
            setNeedsDisplay()
        } else {
            segmentColors[15] = UIColor(named: "green")
        }
    }
    
    //MARK: - tick variables
    @IBInspectable
    var majorTickColor = UIColor.black
    var majorTickWidth: CGFloat = 2
    var majorTickLength: CGFloat = 35
    
    var minorTickColor = UIColor.black.withAlphaComponent(0.5)
    var minorTickWidth: CGFloat = 1
    var minorTickLength: CGFloat = 20
    var minorTickCount = 3
    
    //MARK: - draw the needle variables
    var needleColor = UIColor(white: 0.7, alpha: 1)
    var needleWidth: CGFloat = 4
    let needle = UIView()
    
    
    
    //MARK: - value of gauge label setup
    let valueLabel = UILabel()
    var valueFont = UIFont.systemFont(ofSize: 50)
    var valueColor = UIColor.black
    
    
    //MARK: - configure the needle position 
    @IBInspectable
    var value: Double = 0 {
        didSet {
            // update the value label to show the exact number
            valueLabel.text = String(value)
            
            // figure out where the needle is, between 0 and 1
            let needlePosition = CGFloat(value) / 160
            
            // create a lerp from the start angle (rotation) through to the end angle (rotation + totalAngle)
            let lerpFrom = rotation
            let lerpTo = rotation + totalAngle
            
            // lerp from the start to the end position, based on the needle's position
            let needleRotation = lerpFrom + (lerpTo - lerpFrom) * needlePosition
            needle.transform = CGAffineTransform(rotationAngle: deg2rad(needleRotation))
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawBackground(in: rect, context: ctx)
        drawSegments(in: rect, context: ctx)
        drawTicks(in: rect, context: ctx)
        drawCenterDisc(in: rect, context: ctx)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    //convert degrees to radians
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    //MARK: - draw inner and outer bezzels
    
    func drawBackground(in rect: CGRect, context ctx: CGContext) {
        // draw the outer bezel as the largest circle
        outerBezelColor.set()
        ctx.fillEllipse(in: rect)
        
        // move in a little on each edge, then draw the inner bezel
        let innerBezelRect = rect.insetBy(dx: outerBezelWidth, dy: outerBezelWidth)
        innerBezelColor.set()
        ctx.fillEllipse(in: innerBezelRect)
        
        // finally, move in some more and draw the inside of our gauge
        let insideRect = innerBezelRect.insetBy(dx: innerBezelWidth, dy: innerBezelWidth)
        insideColor.set()
        ctx.fillEllipse(in: insideRect)
    }
    
    
    
    //MARK: - Draw Segments
    
    func drawSegments(in rect: CGRect, context ctx: CGContext) {
        // 1: Save the current drawing configuration
        ctx.saveGState()
        
        // 2: Move to the center of our drawing rectangle and rotate so that we're pointing at the start of the first segment
        ctx.translateBy(x: rect.midX, y: rect.midY)
        ctx.rotate(by: deg2rad(rotation) - (.pi / 2))
        
        // 3: Set up the user's line width
        ctx.setLineWidth(segmentWidth)
        
        // This is the number of segments add more !!!!!!!!!!!!!!!!!!!!!
        
        // 4: Calculate the size of each segment in the total gauge
        let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        
        // 5: Calculate how wide the segment arcs should be
        let segmentRadius = (((rect.width - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
        
        
        
        // 6: Draw each segment
        for (index, segment) in segmentColors.enumerated() {
            // figure out where the segment starts in our arc
            
            
            let start = CGFloat(index) * segmentAngle
            
            // activate its color
            segment?.set()
            
            // add a path for the segment
            ctx.addArc(center: .zero, radius: segmentRadius, startAngle: start, endAngle: start + segmentAngle, clockwise: false)
            
            // and stroke it using the activated color
            ctx.drawPath(using: .stroke)
            
        }
        
        // 7: Reset the graphics state
        ctx.restoreGState()
    }
    
    //MARK: - draw ticks
    
    func drawTicks(in rect: CGRect, context ctx: CGContext) {
        // save our clean graphics state
        ctx.saveGState()
        ctx.translateBy(x: rect.midX, y: rect.midY)
        ctx.rotate(by: deg2rad(rotation) - (.pi / 2))
        
        let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        
        let segmentRadius = (((rect.width - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        // save the graphics state where we've moved to the center and rotated towards the start of the first segment
        ctx.saveGState()
        
        // draw major ticks
        ctx.setLineWidth(majorTickWidth)
        majorTickColor.set()
        
        let majorEnd = segmentRadius + (segmentWidth / 2)
        let majorStart = majorEnd - majorTickLength
        
        
        //MARK: - loop over segments and add the major tick marks
        for _ in 0 ... segmentColors.count {
            ctx.move(to: CGPoint(x: majorStart, y: 0))
            ctx.addLine(to: CGPoint(x: majorEnd, y: 0))
            ctx.drawPath(using: .stroke)
            ctx.rotate(by: segmentAngle)
        }
        
        // go back to the state we had before we drew the major ticks
        ctx.restoreGState()
        
        // save it again, because we're about to draw the minor ticks
        ctx.saveGState()
        
        // draw minor ticks
        ctx.setLineWidth(minorTickWidth)
        minorTickColor.set()
        
        let minorEnd = segmentRadius + (segmentWidth / 2)
        let minorStart = minorEnd - minorTickLength
        
        let minorTickSize = segmentAngle / CGFloat(minorTickCount + 1)
        
        for _ in 0 ..< segmentColors.count {
            ctx.rotate(by: minorTickSize)
            
            for _ in 0 ..< minorTickCount {
                ctx.move(to: CGPoint(x: minorStart, y: 0))
                ctx.addLine(to: CGPoint(x: minorEnd, y: 0))
                ctx.drawPath(using: .stroke)
                ctx.rotate(by: minorTickSize)
            }
        }
        
        // go back to the graphics state where we've moved to the center and rotated towards the start of the first segment
        ctx.restoreGState()
        
        // go back to the original graphics state
        ctx.restoreGState()
    }
    
    //MARK: - draw center state for animating the needle
    func drawCenterDisc(in rect: CGRect, context ctx: CGContext) {
        ctx.saveGState()
        ctx.translateBy(x: rect.midX, y: rect.midY)
        
        let outerCenterRect = CGRect(x: -outerCenterDiscWidth / 2, y: -outerCenterDiscWidth / 2, width: outerCenterDiscWidth, height: outerCenterDiscWidth)
        outerCenterDiscColor.set()
        ctx.fillEllipse(in: outerCenterRect)
        
        let innerCenterRect = CGRect(x: -innerCenterDiscWidth / 2, y: -innerCenterDiscWidth / 2, width: innerCenterDiscWidth, height: innerCenterDiscWidth)
        innerCenterDiscColor.set()
        ctx.fillEllipse(in: innerCenterRect)
        ctx.restoreGState()
    }
    
    //MARK: - setUP the needle gauge
    func setUp() {
        
        valueLabel.font = valueFont
        valueLabel.text = "80"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
            ])
        
        
        needle.backgroundColor = needleColor
        needle.translatesAutoresizingMaskIntoConstraints = false
        
        // make the needle a third of our height
        needle.bounds = CGRect(x: 0, y: 0, width: needleWidth, height: bounds.height / 3)
        
        // align it so that it is positioned and rotated from the bottom center
        needle.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        // now center the needle over our center point
        needle.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(needle)
    }
    
    
    
}
