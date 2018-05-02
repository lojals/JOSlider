//
//  JOSlider.swift
//  JOSlider
//
//  Created by Jorge R Ovalle Z on 5/1/18.
//

import UIKit

class Slider: UIControl {
    
    override var backgroundColor: UIColor? {
        didSet {
            guard let backgroundColor = backgroundColor else { return }
            selector.layer.borderColor = backgroundColor.cgColor
            selector.layer.borderWidth = DesignConstants.borderWidth
        }
    }
    
    var contrastColor: UIColor? {
        didSet {
            guard let contrastColor = contrastColor else { return }
            minValueLabel.textColor = contrastColor
            maxValueLabel.textColor = contrastColor
        }
    }
    
    enum DesignConstants {
        static let marginSpacing: CGFloat = 10
        static let selectorSize: CGFloat = 50
        static let borderWidth: CGFloat = 5
    }
    
    private var shouldStick: Stick = .shouldNotStick
    
    
    var value: Int {
        didSet {
            setPosition(for: value)
        }
    }
    
    
    var minValue = 10
    var maxValue = 100
    
    private var selector: UILabel = {
        let selector = UILabel(frame: CGRect(x: 0, y: 0, width: DesignConstants.selectorSize, height: DesignConstants.selectorSize))
        selector.backgroundColor = .white
        selector.layer.cornerRadius = selector.frame.width / 2
        selector.font = UIFont.boldSystemFont(ofSize: 14)
        selector.textAlignment = .center
        selector.layer.masksToBounds = true
        return selector
    }()
    
    private lazy var minValueLabel: UILabel = {
        let label =  UILabel()
        label.text = "\(self.minValue)"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.frame = CGRect(x: DesignConstants.marginSpacing - DesignConstants.borderWidth, y: 0, width: DesignConstants.selectorSize, height: self.frame.height)
        return label
    }()
    
    private lazy var maxValueLabel: UILabel = {
        let label =  UILabel()
        label.text = "\(self.maxValue)"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.frame = CGRect(x: self.frame.width - DesignConstants.marginSpacing - DesignConstants.selectorSize + DesignConstants.borderWidth, y: 0, width: DesignConstants.selectorSize, height: self.frame.height)
        return label
    }()
    
    override init(frame: CGRect) {
        self.value = 50
        super.init(frame: frame)
        
        defer {
            self.value = 50
        }
        
        addSubview(minValueLabel)
        addSubview(maxValueLabel)
        addSubview(selector)
        
        test(point: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: [], animations: {
            self.selector.center.y = (self.frame.height / 2) - 60
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let origin = selector.center
        let point = touches.first?.location(in: self) ?? origin
        test(point: point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            switch self.shouldStick {
            case .stickMin:
                self.selector.center = self.minValueLabel.center
            case .stickMax:
                self.selector.center = self.maxValueLabel.center
            case .shouldNotStick:
                self.selector.center.y = self.frame.height / 2
            }
        }
    }
    
    func test(point: CGPoint) {
        let sizeForLabel = DesignConstants.marginSpacing + (DesignConstants.selectorSize * 0.5) - DesignConstants.borderWidth
        
        let maxPosibleX = frame.width - sizeForLabel
        let minPosibleX = sizeForLabel
        
        let greaterThanMinX = point.x >= minPosibleX
        let smallerThanMaxX = point.x <= maxPosibleX
        
        if greaterThanMinX && smallerThanMaxX {
            let factor =  (maxPosibleX - minPosibleX) / (CGFloat(maxValue) - CGFloat(minValue))
            value = Int((point.x - minPosibleX) / factor) + minValue
            selector.text = "\(value)"
            selector.center = CGPoint(x: point.x, y: (frame.height / 2) - 60)
            
            shouldStick = .shouldNotStick
        } else if !greaterThanMinX {
            selector.text = "\(minValue)"
            shouldStick = .stickMin
        } else if !smallerThanMaxX {
            selector.text = "\(maxValue)"
            shouldStick = .stickMax
        }
    }
    
    private func setPosition(for value: Int) {
        let valueForScreen = CGFloat(value)
        let sizeForLabel = DesignConstants.marginSpacing + (DesignConstants.selectorSize * 0.5) - DesignConstants.borderWidth
        
        let maxPosibleX = frame.width - sizeForLabel
        let minPosibleX = sizeForLabel
        
        let factor =  (maxPosibleX - minPosibleX) / (CGFloat(maxValue) - CGFloat(minValue))
        let xValue = ((valueForScreen - CGFloat(minValue)) * factor) + minPosibleX
        
        selector.text = "\(value)"
        selector.center = CGPoint(x: xValue, y: (frame.height / 2))
    }
    
    private enum Stick {
        case stickMin, stickMax, shouldNotStick
    }
}
