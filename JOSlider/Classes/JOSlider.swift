//
//  JOSlider.swift
//  JOSlider
//
//  Created by Jorge R Ovalle Z on 5/1/18.
//

import UIKit
import Foundation

public class JOSlider: UIControl {
    
    // MARK: - DesignConstants
    private enum DesignConstants {
        static let marginSpacing: CGFloat = 10
        static let selectorSize: CGFloat = 50
        static let borderWidth: CGFloat = 5
    }
    
    // MARK: - Properties declaration
    
    override public var backgroundColor: UIColor? {
        didSet {
            guard let backgroundColor = backgroundColor else { return }
            selector.layer.borderColor = backgroundColor.cgColor
            selector.layer.borderWidth = DesignConstants.borderWidth
        }
    }
    
    public var contrastColor: UIColor? {
        didSet {
            guard let contrastColor = contrastColor else { return }
            minValueLabel.textColor = contrastColor
            maxValueLabel.textColor = contrastColor
        }
    }
    
    var value: Int {
        didSet {
            setPosition(for: value)
        }
    }
    
    private lazy var widthForLabel = {
        return DesignConstants.marginSpacing + (DesignConstants.selectorSize * 0.5) - DesignConstants.borderWidth
    }()
    
    private lazy var borders: (min: CGFloat, max: CGFloat) = {
        return (min: frame.width - widthForLabel, max: widthForLabel)
    }()
    
    var minValue = 10
    var maxValue = 100
    
    // MARK: - View components declaration
    
    private var selector: UILabel = {
        let selector = UILabel(frame: CGRect(x: 0, y: 0, width: DesignConstants.selectorSize, height: DesignConstants.selectorSize))
        selector.backgroundColor = .white
        selector.layer.cornerRadius = selector.frame.width / 2
        selector.font = UIFont.boldSystemFont(ofSize: 14)
        selector.textAlignment = .center
        selector.layer.masksToBounds = true
        return selector
    }()
    
    private lazy var minValueLabel: UILabel = type(of: self).newLabel(title: "\(self.minValue)")
    
    private lazy var maxValueLabel: UILabel = {
        let label =  type(of: self).newLabel(title: "\(self.maxValue)")
        return label
    }()
    
    private lazy var coordinateFactor: CGFloat = {
        return (borders.max - borders.min) / (CGFloat(maxValue) - CGFloat(minValue))
    }()
    
    private static func newLabel(title: String) -> UILabel {
        let label =  UILabel()
        label.text = title
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: UIControl lyfecycle
    
    override public init(frame: CGRect) {
        self.value = 50
        super.init(frame: frame)
        
        defer {
            self.value = 50
        }
        
        addSubview(minValueLabel)
        addSubview(maxValueLabel)
        addSubview(selector)
        
        setupUIConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUIConstraints() {
        let views = ["minLbl": minValueLabel, "maxLbl": maxValueLabel]
        let metrics = ["margin": DesignConstants.marginSpacing - DesignConstants.borderWidth, "sizeLbl": DesignConstants.selectorSize]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[minLbl(sizeLbl)]", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[minLbl]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[maxLbl(sizeLbl)]-margin-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maxLbl]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: UIView events
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: [], animations: {
            self.selector.center.y = (self.frame.height / 2) - 60
        })
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let origin = selector.center
        let point = touches.first?.location(in: self) ?? origin
        setValue(for: point)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.selector.center.y = self.frame.height / 2
        }
    }
    
    private func setPosition(for value: Int) {
        let valueForScreen = CGFloat(value)
        let xValue = ((valueForScreen - CGFloat(minValue)) * coordinateFactor) + borders.min
        selector.text = "\(value)"
        selector.center = CGPoint(x: xValue, y: frame.height / 2)
    }
    
    private func setValue(for position: CGPoint) {
        let greaterThanMinX = position.x >= borders.min
        let smallerThanMaxX = position.x <= borders.max
        
        if greaterThanMinX && smallerThanMaxX {
            value = Int((position.x - borders.min) / coordinateFactor) + minValue
            selector.text = "\(value)"
            selector.center = CGPoint(x: position.x, y: (frame.height / 2) - 60)
        } else if !greaterThanMinX {
            selector.text = "\(minValue)"
        } else if !smallerThanMaxX {
            selector.text = "\(maxValue)"
        }
    }
}


public extension JOSlider {
    public struct Configuration {
        var minValue: Int
        
    }
}
