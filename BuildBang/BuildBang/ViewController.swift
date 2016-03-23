//
//  ViewController.swift
//  BuildBang
//
//  Created by Simon Li on 2016-03-18.
//  Copyright © 2016 zemind. All rights reserved.
//

import UIKit
import Animo
import RandomColorSwift

class ViewController: UIViewController {
	
	struct EffectiveRange {
		var startX: CGFloat
		var effectiveWidth: CGFloat
		var valid: Bool
	}
	
	let buildBlockHeight: CGFloat = 35
	let buildBlockWidth: CGFloat = 180
	
	var gameLevel: NSTimeInterval = 1
	
	let securityHeight: CGFloat = 260
	
	var nextStartY: CGFloat = 0.0
	
	var currentScore: Int = 0
	
	var currentBuldingBlock: UIView?
	
	var scoreLabel: UILabel?
    
    var debugTime: DebugButton?
	
	var restartButton: UIButton?
	
	var gameRange: EffectiveRange = EffectiveRange(startX: 0, effectiveWidth: 0.0, valid: true)
	
	var stackedView: [UIView] = []
	
	// Position Adjustment Metrics
	let leftSaveSpace: CGFloat = 80
	let rightSaveSpace: CGFloat = 80
	
	// Bonus Metrics
	let bonusWidth: CGFloat = 20.0
	var straightPerfectTime: Int = 0
	let bonusThreshold = 5
    var continuePerfectMatch = false

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		
		setupConstraints()
		
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		
		startNewGame()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func setupViews() -> Void {
		let tapGestrue = UITapGestureRecognizer(target: self, action: "tappedScreen:")
		self.view.addGestureRecognizer(tapGestrue)
		
		self.scoreLabel = UILabel(frame: CGRectZero)
		self.scoreLabel?.translatesAutoresizingMaskIntoConstraints = false
		self.scoreLabel?.textColor = UIColor.blackColor()
		self.scoreLabel?.text = String("Score: \(currentScore)")
		self.scoreLabel?.font = UIFont.systemFontOfSize(18.0)
		self.view.addSubview(self.scoreLabel!)
		
		self.restartButton = UIButton(frame: CGRectZero)
		self.restartButton?.translatesAutoresizingMaskIntoConstraints = false
		self.restartButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
		self.restartButton?.titleLabel?.font = UIFont.systemFontOfSize(18.0)
		self.restartButton?.setTitle("Try Once More @_@ 😈😈😈", forState: UIControlState.Normal)
		self.restartButton?.hidden = true
		self.restartButton?.addTarget(self, action: "startNewGame", forControlEvents: UIControlEvents.TouchUpInside)
		self.view.addSubview(self.restartButton!)
        
        self.debugTime = DebugButton(title: "TimeInterval", initialValue: 1, delegate: self, frame: CGRectZero)
        self.debugTime?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.debugTime!)
        
        // TestViewToDebug
	}
	
	func setupConstraints() -> Void {
		let constraint1 = self.scoreLabel?.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
		let constraint2 = self.restartButton?.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
		
		let constraint3 = self.scoreLabel?.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: 20.0)
		let constraint4 = self.restartButton?.topAnchor.constraintEqualToAnchor(self.scoreLabel?.bottomAnchor, constant: 20.0)
        
        let con1 = self.debugTime?.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: 90)
        let con2 = self.debugTime?.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
		NSLayoutConstraint.activateConstraints([constraint1!, constraint2!, constraint3!, constraint4!, con1!, con2!])
	}
	
	func startNewGame() -> Void {
		// Remove old views
		for view in self.stackedView {
			view.removeFromSuperview()
		}
		
		self.stackedView = []
		
		currentScore = 0
		self.restartButton?.hidden = true
		
		self.scoreLabel?.hidden = false
		self.scoreLabel?.text = String("Score: \(currentScore)")
		// SetStartY with current Screen Info
		nextStartY = CGRectGetMaxY(self.view.frame) - buildBlockHeight
		
		// Create Center Base One
		let baseView = buildViewWithRect(CGRectMake((CGRectGetWidth(self.view.frame) - buildBlockWidth)/2.0, nextStartY, buildBlockWidth, buildBlockHeight))
		nextStartY -= buildBlockHeight
		self.stackedView.append(baseView)
		
		// Setup EffectiveRange
		gameRange = EffectiveRange(startX: (CGRectGetWidth(self.view.frame) - buildBlockWidth)/2.0, effectiveWidth: buildBlockWidth, valid: true)
		
		// Bring up first block
		createNewBlockFromLeft(true, width: buildBlockWidth)
	}
	
	func tappedScreen(gestureRecognizer: UITapGestureRecognizer) {
		if let buildBlock = currentBuldingBlock, currentPresentationLayer = buildBlock.layer.presentationLayer() as? CALayer{
			buildBlock.layer.removeAllAnimations()
			buildBlock.removeFromSuperview()
			
			//print("Current one frame is x:\(currentPresentationLayer.frame.origin.x) y: \(currentPresentationLayer.frame.origin.y)")
			
			// First, we judge if there has some intersection
			
			let previousRange = gameRange
			
			let thisTurnResultRange = retreiveNewGameRangeWithFrame(currentPresentationLayer.frame)
			
			
			if thisTurnResultRange.valid == false {
				self.scoreLabel?.text = "Game Over!!! Your score is \(currentScore)"
				
				self.restartButton?.hidden = false
				return
			}
			
			currentScore += 1
			self.scoreLabel?.text = String("Score: \(currentScore)")
			
			gameRange = thisTurnResultRange
			
			// here we add some effect for "perfect" match!
			// TODO: test
			
			var perfectMatch = false
            if abs(previousRange.effectiveWidth - self.gameRange.effectiveWidth) < 5.0 {
				gameRange = previousRange
				perfectMatch = true
                
                if continuePerfectMatch {
                    self.straightPerfectTime = bonusThreshold
                } else {
                    self.straightPerfectTime += 1
                }
				
				if self.straightPerfectTime == bonusThreshold {
					self.straightPerfectTime = 0
                    continuePerfectMatch = true
					gameRange.effectiveWidth += bonusWidth
					
					if gameRange.effectiveWidth > buildBlockWidth {
						gameRange.effectiveWidth = buildBlockWidth
					}
				}
			} else {
                self.straightPerfectTime = 0
                self.continuePerfectMatch = false
            }
			
			// Secondly, if game continue, we should use new gameRange truncate our current buildBlock to two parts.
			if gameRange.startX > CGRectGetMinX(currentPresentationLayer.frame) {
				// Drop Left Part
				
				
			} else {
				// Drop Right Part
				
			}
			
			// Demo first no animation
			let keptView = buildViewWithRect(CGRectMake(gameRange.startX, currentPresentationLayer.frame.origin.y, gameRange.effectiveWidth, buildBlockHeight))
			keptView.backgroundColor = randomColor()
			self.stackedView.append(keptView)
			
			if perfectMatch {
				keptView.layer.runAnimation(
					Animo.autoreverse(
						Animo.group(
							Animo.scaleX(by:2, duration: 1, timingMode: .EaseInOutBack),
							Animo.scaleY(by:0.5, duration: 1, timingMode: .EaseInOutBack)
						)
					)
				)
			}
			
			
			// If we are two high, move the bottomest one off the screen.
			if nextStartY < securityHeight {
				moveStackDropOneLevel()
			}
			
			
			// If we are too left-shifted or right-shifted, move views to center
			if gameRange.startX < leftSaveSpace {
				// Move to right
				let screenWidth = CGRectGetWidth(self.view.frame)
				let midMinX = (screenWidth - gameRange.effectiveWidth)/2.0
				
				let moveDistance = midMinX - gameRange.startX
				
				for view in self.stackedView {
					UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
						view.frame.origin.x += moveDistance
						}) { (someValue) -> Void in
					}
				}
				
				gameRange.startX += moveDistance
			}
			
			if rightSaveSpace > CGRectGetWidth(self.view.frame) - gameRange.startX - gameRange.effectiveWidth {
				// Move to left
				let screenWidth = CGRectGetWidth(self.view.frame)
				let midMaxX = (screenWidth + gameRange.effectiveWidth)/2.0
				
				let moveDistance = gameRange.startX + gameRange.effectiveWidth - midMaxX
				
				for view in self.stackedView {
					UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
						view.frame.origin.x -= moveDistance
						}) { (someValue) -> Void in
					}
				}
				
				gameRange.startX -= moveDistance
			}
			
			
			createNewBlockFromLeft(true, width: gameRange.effectiveWidth)
		}
	}
    
	
	func retreiveNewGameRangeWithFrame(frame: CGRect) -> EffectiveRange {
		
		if CGRectGetMaxX(frame) < gameRange.startX || CGRectGetMinX(frame) > gameRange.startX + gameRange.effectiveWidth {
			return EffectiveRange(startX: 0.0, effectiveWidth: 0.0, valid: false)
		}
		
		var newStartX: CGFloat = 0.0
		if CGRectGetMinX(frame) < gameRange.startX {
			newStartX = gameRange.startX
		} else {
			newStartX = CGRectGetMinX(frame)
		}
		
		var newWidth: CGFloat = 0.0
		if CGRectGetMaxX(frame) <  gameRange.startX + gameRange.effectiveWidth {
			newWidth = CGRectGetMaxX(frame) - gameRange.startX
		} else {
			newWidth = gameRange.startX + gameRange.effectiveWidth - CGRectGetMinX(frame)
		}
		
		return EffectiveRange(startX: newStartX, effectiveWidth: newWidth, valid: true)
	}
	
	func moveStackDropOneLevel() {
		let lastView = self.stackedView.first
		
		UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
			lastView!.frame.origin.y += self.buildBlockHeight
			}) { (someValue) -> Void in
				self.stackedView = Array(self.stackedView.dropFirst())
				lastView?.removeFromSuperview()
		}
		
		for view in self.stackedView {
			UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
				view.frame.origin.y += self.buildBlockHeight
				}) { (someValue) -> Void in
			}
	
		}
		
		nextStartY += buildBlockHeight
	}

	// Build a view with rect and add it to left or right side of the screen
	func buildViewWithRect(rect: CGRect) -> UIView {
		let view = UIView(frame: rect)
		view.backgroundColor = UIColor.blackColor()
		
		self.view.addSubview(view)
		return view
	}
	
	func createNewBlockFromLeft(left: Bool, width: CGFloat) {
		let screenWidth = CGRectGetWidth(self.view.frame)
		
		var blockX: CGFloat = 0.0
		
		let moveDistance = screenWidth - width
		
		if !left {
			blockX = screenWidth - width
		}
		
		currentBuldingBlock = buildViewWithRect(CGRectMake(blockX, nextStartY, width, buildBlockHeight))
		
		let leftToRightAnimo = Animo.group(
			Animo.keyPath("backgroundColor", to: UIColor.blueColor(), duration: gameLevel),
			Animo.move(by: CGPoint(x: moveDistance, y: 0), duration: gameLevel),
			timingMode: .EaseInOut
		)
		
		let rightToLeftAnimo = Animo.group(
			Animo.keyPath("backgroundColor", to: UIColor.blackColor(), duration: gameLevel),
			Animo.move(by: CGPoint(x: -moveDistance, y: 0), duration: gameLevel),
			timingMode: .EaseInOut
		)
		
		if left {
			currentBuldingBlock?.layer.runAnimation(
				Animo.replayForever(
					Animo.sequence(
						leftToRightAnimo,
						rightToLeftAnimo
					)
				)
			)
		} else {
			currentBuldingBlock?.layer.runAnimation(
				Animo.replayForever(
					Animo.sequence(
						rightToLeftAnimo,
						leftToRightAnimo
					)
				)
			)
		}
		
		nextStartY -= buildBlockHeight
	}
}

extension ViewController: DebugButtonDelegate {
    func addValue(value: Int) -> Void {
        self.gameLevel += NSTimeInterval(value)
    }
    
    func reduceValue(value: Int) -> Void {
        self.gameLevel -= NSTimeInterval(value)
    }
}

