//
//  DebugButton.swift
//  BuildBang
//
//  Created by yansong li on 2016-03-19.
//  Copyright © 2016 zemind. All rights reserved.
//

import Foundation
import UIKit

protocol DebugButtonDelegate: class {
    func addValue(value: Int) -> Void
    func reduceValue(value: Int) -> Void
}

class DebugButton: UIView {
    
    let title: String
    let initialValue: Int
    
    var titleLabel: UILabel?
    var valueLabel: UILabel?
    
    var addButton: UIButton?
    var reduceButton: UIButton?
    
    weak var tapDelegate: DebugButtonDelegate?
    
    override convenience init(frame: CGRect) {
        self.init(title:"", initialValue: 0, frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(200, 80)
    }
    
    init(title: String, initialValue: Int = 0, delegate:DebugButtonDelegate? = nil, frame: CGRect = CGRectZero) {
        self.title = title
        self.initialValue = initialValue
        self.tapDelegate = delegate
        super.init(frame: frame)
        setupSubViews()
        setupConstraints()
    }
    
    func setupSubViews() {
        self.titleLabel = createLabelWithTitle(title)
        self.valueLabel = createLabelWithTitle(String(initialValue))
        self.addButton = createButtonWithTitle("+", action: "addValue:")
        self.reduceButton = createButtonWithTitle("-", action: "reduceValue:")
    }
    
    func setupConstraints() {
        let titleCenterY = self.titleLabel?.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
        let titleLeading = self.titleLabel?.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: 20)
        
        let valueCenterY = self.valueLabel?.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
        let valueLeading = self.valueLabel?.leadingAnchor.constraintEqualToAnchor(self.titleLabel?.trailingAnchor, constant: 10)
        
        let addCenterY = self.addButton?.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
        let addLeading = self.addButton?.leadingAnchor.constraintEqualToAnchor(self.valueLabel?.trailingAnchor, constant: 10)
        
        let reduceCenterY = self.reduceButton?.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
        let reduceLeading = self.reduceButton?.leadingAnchor.constraintEqualToAnchor(self.addButton?.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activateConstraints([titleCenterY!, titleLeading!, valueCenterY!, valueLeading!, addCenterY!, addLeading!, reduceCenterY!, reduceLeading!])
    }
    
    // MARK: Actions
    func addValue(button: UIButton) -> Void {
        if let value =  Int((self.valueLabel?.text!)!) {
            self.valueLabel?.text = String(value + 1)
        }
        self.tapDelegate?.addValue(1)
    }
    
    func reduceValue(button: UIButton) -> Void {
        if let value =  Int((self.valueLabel?.text!)!) {
            self.valueLabel?.text = String(value - 1)
        }
        self.tapDelegate?.reduceValue(1)
    }
    
    // MARK: Helpers
    func createLabelWithTitle(title: String) -> UILabel {
        let retVal = UILabel(frame: CGRectZero)
        retVal.translatesAutoresizingMaskIntoConstraints = false
        retVal.textColor = UIColor.blackColor()
        retVal.text = title
        self.addSubview(retVal)
        return retVal
    }
    
    func createButtonWithTitle(title: String, action: Selector) -> UIButton {
        let retVal = UIButton(frame: CGRectZero)
        retVal.translatesAutoresizingMaskIntoConstraints = false
        retVal.setTitle(title, forState: UIControlState.Normal)
        retVal.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        retVal.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(retVal)
        return retVal
    }
}