//
//  ViewController.swift
//  BuildBang
//
//  Created by Simon Li on 2016-03-18.
//  Copyright © 2016 zemind. All rights reserved.
//

import UIKit
import Animo

class ViewController: UIViewController {
	
	struct EffectiveRange {
		var startX: CGFloat
		var effectiveWidth: CGFloat
	}
	
	let buildBlockHeight: CGFloat = 20
	let buildBlockWidth: CGFloat = 180
	
	var gameLevel: NSTimeInterval = 2
	
	var nextStartY: CGFloat = 0.0
	
	var currentScore: Int = 0
	
	var currentBuldingBlock: UIView?
	
	var gameRange: EffectiveRange = EffectiveRange(startX: 0, effectiveWidth: 0.0)

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		
		// SetStartY with current Screen Info
		nextStartY = CGRectGetMaxY(self.view.frame) - buildBlockHeight
		
		// Create Center Base One
		buildViewWithRect(CGRectMake((CGRectGetWidth(self.view.frame) - buildBlockWidth)/2.0, nextStartY, buildBlockWidth, buildBlockHeight))
		nextStartY -= buildBlockHeight
		
		// Setup EffectiveRange
		gameRange = EffectiveRange(startX: (CGRectGetWidth(self.view.frame) - buildBlockWidth)/2.0, effectiveWidth: buildBlockWidth)
		
		
		// Bring up first block
		
		createNewBlockFromLeft(true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func setupViews() -> Void {
		let tapGestrue = UITapGestureRecognizer(target: self, action: "tappedScreen:")
		self.view.addGestureRecognizer(tapGestrue)
	}
	
	func tappedScreen(gestureRecognizer: UITapGestureRecognizer) {
		if let buildBlock = currentBuldingBlock, currentPresentationLayer = buildBlock.layer.presentationLayer() as? CALayer{
			buildBlock.layer.removeAllAnimations()
			
			print("Current one frame is x:\(currentPresentationLayer.frame.origin.x) y: \(currentPresentationLayer.frame.origin.y)")
			
			// First, we judge if there has some intersection
			
			
			
			
			let newView = buildViewWithRect(currentPresentationLayer.frame)
			buildBlock.removeFromSuperview()
			
			currentBuldingBlock = newView
			
			createNewBlockFromLeft(true)
			
			
			// Settle current building Block
			
			// Game over or not
			
			// If not bringup next block
		}
	}

	// Build a view with rect and add it to left or right side of the screen
	func buildViewWithRect(rect: CGRect) -> UIView {
		let view = UIView(frame: rect)
		view.backgroundColor = UIColor.blackColor()
		
		self.view.addSubview(view)
		return view
	}
	
	func createNewBlockFromLeft(left: Bool) {
		let screenWidth = CGRectGetWidth(self.view.frame)
		
		var blockX: CGFloat = 0.0
		
		let moveDistance = screenWidth - buildBlockWidth
		
		if !left {
			blockX = screenWidth - buildBlockWidth
		}
		
		currentBuldingBlock = buildViewWithRect(CGRectMake(blockX, nextStartY, buildBlockWidth, buildBlockHeight))
		
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

