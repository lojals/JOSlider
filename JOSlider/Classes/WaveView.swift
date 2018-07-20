//
//  WaveView.swift
//  JOSlider
//
//  Created by Jorge R Ovalle Z on 5/5/18.
//

import UIKit

public class WaveView: UIView {
    
    enum DesignConstants{
        static let maxAmplitude: CGFloat = 20.0
        static let minAmplitude: CGFloat = 0
        static let maxP: CGFloat = 0.68
        static let minP: CGFloat = 0.3
        
        static let factor: CGFloat = {
            return (DesignConstants.maxP - DesignConstants.minP) / DesignConstants.maxAmplitude
        }()
        
        static let animationUnitTime = 0.008
    }
    
    private var amplitude: CGFloat = 0
    private var term: CGFloat = 0.0
    private var position: CGFloat = 0.0
    private var progress: CGFloat = 0.3
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override public func draw(_ rect: CGRect) {
        position = (1 - progress) * rect.height
        drawWave(originX: -10, fillColor: tintColor)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        term = bounds.width
    }
    
    func drawWave(originX: CGFloat, fillColor: UIColor) {
        let curvePath = UIBezierPath()
        curvePath.move(to: CGPoint(x: originX, y: position))
        
        var tempPoint = originX
        
        for _ in 1...3 {
            curvePath.addQuadCurve(to: keyPoint(x: tempPoint + term / 2, originX: originX),
                                   controlPoint: keyPoint(x: tempPoint + term / 4, originX: originX))
            tempPoint += term / 2
        }
        
        curvePath.addLine(to: CGPoint(x: curvePath.currentPoint.x, y: self.bounds.size.height))
        curvePath.addLine(to: CGPoint(x: CGFloat(originX), y: self.bounds.size.height))
        curvePath.close()
        
        fillColor.setFill()
        curvePath.lineWidth = 10
        curvePath.fill()
        
        
    }
    
    func keyPoint(x: CGFloat, originX: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: columnYPoint(x: x - originX))
    }
    
    func columnYPoint(x: CGFloat) -> CGFloat {
        let result = amplitude * sin((2 * CGFloat.pi / term) * x)
        return CGFloat(result + position)
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }
    
    func animateHide() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            while strongSelf.amplitude > DesignConstants.minAmplitude {
                strongSelf.amplitude -= 1
                strongSelf.updateUIForAnimation()
            }
        }
    }
    
    
    func animateShow() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            while strongSelf.amplitude < DesignConstants.maxAmplitude {
                strongSelf.amplitude += 1
                strongSelf.updateUIForAnimation()
            }
        }
    }
    
    func updateUIForAnimation(){
        progress = (DesignConstants.factor * amplitude) + DesignConstants.minP
        DispatchQueue.main.async(execute: { () -> Void in
            self.setNeedsDisplay()
        })
        Thread.sleep(forTimeInterval: DesignConstants.animationUnitTime)
    }
}
