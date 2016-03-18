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
	
	let buildBlockHeight: CGFloat = 20
	let buildBlockWidth: CGFloat = 180
	
	var gameLevel: NSTimeInterval = 6
	
	var nextStartY: CGFloat = 0.0
	
	var currentScore: Int = 0
	
	var currentBuldingBlock: UIView?
	
	var scoreLabel: UILabel?
	
	var gameRange: EffectiveRange = EffectiveRange(startX: 0, effectiveWidth: 0.0, valid: true)

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		
		// SetStartY with current Screen Info
		nextStartY = CGRectGetMaxY(self.view.frame) - buildBlockHeight
		
		// Create Center Base One
		buildViewWithRect(CGRectMake((CGRectGetWidth(self.view.frame) - buildBlockWidth)/2.0, nextStartY, buildBlockWidth, buildBlockHeight))
		nextStartY -= buildBlockHeight
		
		// Setup EffectiveRange
		gameRange = EffectiveRange(startX: (CGRectGetWidth(self.view.frame) - buildBlockWidth)/2.0, effectiveWidth: buildBlockWidth, valid: true)
		
		
		// Bring up first block
		
		createNewBlockFromLeft(true, width: buildBlockWidth)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func setupViews() -> Void {
		let tapGestrue = UITapGestureRecognizer(target: self, action: "tappedScreen:")
		self.view.addGestureRecognizer(tapGestrue)
		
		self.scoreLabel = UILabel(frame: CGRectMake(160, 70, 160, 30))
		self.scoreLabel?.textColor = UIColor.blackColor()
		self.scoreLabel?.text = String("Score: \(currentScore)")
		self.scoreLabel?.font = UIFont.systemFontOfSize(18.0)
		self.view.addSubview(self.scoreLabel!)
	}
	
	func tappedScreen(gestureRecognizer: UITapGestureRecognizer) {
		if let buildBlock = currentBuldingBlock, currentPresentationLayer = buildBlock.layer.presentationLayer() as? CALayer{
			buildBlock.layer.removeAllAnimations()
			buildBlock.removeFromSuperview()
			
			print("Current one frame is x:\(currentPresentationLayer.frame.origin.x) y: \(currentPresentationLayer.frame.origin.y)")
			
			// First, we judge if there has some intersection
			
			let thisTurnResultRange = retreiveNewGameRangeWithFrame(currentPresentationLayer.frame)
			
			
			if thisTurnResultRange.valid == false {
				print("game over")
				self.scoreLabel?.text = "Game Over!!!"
				return
			}
			currentScore += 1
			self.scoreLabel?.text = String("Score: \(currentScore)")
			gameRange = thisTurnResultRange
			
			// Secondly, if game continue, we should use new gameRange truncate our current buildBlock to two parts.
			if gameRange.startX > CGRectGetMinX(currentPresentationLayer.frame) {
				// Drop Left Part
				
				// Demo first no animation
				let keptView = buildViewWithRect(CGRectMake(gameRange.startX, currentPresentationLayer.frame.origin.y, gameRange.effectiveWidth, buildBlockHeight))
				keptView.backgroundColor = randomColor()
				
			} else {
				// Drop Right Part
				
				// Demo first no animation
				let keptView = buildViewWithRect(CGRectMake(gameRange.startX, currentPresentationLayer.frame.origin.y, gameRange.effectiveWidth, buildBlockHeight))
				keptView.backgroundColor = randomColor()
			}
			
			
			
			createNewBlockFromLeft(true, width: gameRange.effectiveWidth)
			
			
			// Settle current building Block
			
			// Game over or not
			
			// If not bringup next block
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

