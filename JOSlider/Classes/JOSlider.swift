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
        static let separationFromSlider: CGFloat = 20
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
    
    var value: Int = 0 {
        didSet {
            setPosition(for: value)
        }
    }
    
    private lazy var spaceFromBorder = {
        return DesignConstants.marginSpacing + (DesignConstants.selectorSize * 0.5) - DesignConstants.borderWidth
    }()
    
    private var borders: (min: CGFloat, max: CGFloat) = (0, 0)
    
    private var coordinateFactor: CGFloat = 0
    
    // MARK: - View components declaration
    
    private var selector: UILabel = {
        let selector = UILabel(frame: CGRect(x: 0, y: 0, width: DesignConstants.selectorSize, height: DesignConstants.selectorSize))
        selector.backgroundColor = .white
        selector.layer.cornerRadius = DesignConstants.selectorSize / 2
        selector.font = UIFont.boldSystemFont(ofSize: 14)
        selector.textAlignment = .center
        selector.layer.masksToBounds = true
        return selector
    }()
    
    private lazy var minValueLabel: UILabel = type(of: self).newLabel(title: "\(self.settings.minValue)")
    
    private lazy var maxValueLabel: UILabel = type(of: self).newLabel(title: "\(self.settings.maxValue)")
    
    private static func newLabel(title: String) -> UILabel {
        let label =  UILabel()
        label.text = title
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    public private(set) var settings: Settings
    
    // MARK: UIControl lyfecycle
    
    public init(frame: CGRect, settings: Settings = .default) {
        self.settings = settings
        super.init(frame: frame)
        
        setupUIComponents()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.settings = .default
        super.init(coder: aDecoder)
        
        setupUIComponents()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        borders = (min: spaceFromBorder, max: bounds.width - spaceFromBorder)
        coordinateFactor = (borders.max - borders.min) / (CGFloat(settings.maxValue) - CGFloat(settings.minValue))
        setPosition(for: value)
    }
    
    private func setupUIComponents() {
        layer.cornerRadius = 10
        
        addSubview(minValueLabel)
        addSubview(maxValueLabel)
        addSubview(selector)
        
        setupUIConstraints()
        
        value = settings.valueByDefault
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
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        setValue(for: point, animated: true)
        return super.beginTracking(touch, with: event)
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        setValue(for: point)
        return super.continueTracking(touch, with: event)
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        endAnimation()
    }
    
    public override func cancelTracking(with event: UIEvent?) {
        endAnimation()
    }
    
    private func setPosition(for value: Int) {
        let valueForScreen = CGFloat(value)
        let xValue = ((valueForScreen - CGFloat(settings.minValue)) * coordinateFactor) + borders.min
        selector.text = "\(value)"
        selector.center = CGPoint(x: xValue, y: bounds.midY)
    }
    
    private func setValue(for position: CGPoint, animated: Bool = false) {
        let clampedPosition = min(max(position.x, borders.min), borders.max)
        value = Int((clampedPosition - borders.min) / coordinateFactor) + settings.minValue
        selector.text = "\(value)"
        let newPosition = CGPoint(x: clampedPosition, y: self.bounds.midY - (DesignConstants.selectorSize + DesignConstants.separationFromSlider))
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 2.5, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                self.selector.center = newPosition
            })
        } else {
            selector.center = newPosition
        }
        
        
    }
    
    private func endAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: [], animations: {
            self.selector.center.y = self.bounds.midY
        })
    }
}


public extension JOSlider {
    public struct Settings {
        var minValue: Int
        var maxValue: Int
        var valueByDefault: Int
        
        public static var `default` = Settings(minValue: 0, maxValue: 100, valueByDefault: 50)
    }
}

