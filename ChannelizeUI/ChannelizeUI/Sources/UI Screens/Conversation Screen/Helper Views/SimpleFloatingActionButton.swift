//
//  SimpleFloatingActionButton.swift
//  PrimeMessenger
//
//  Created by Ashish on 26/12/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

//
//  SimpleFloatingActionButton.swift
//  SimpleFloatingActionButton


import UIKit
import QuartzCore

@IBDesignable
class SimpleFloatingActionButton: UIButton {
    
    //PROPERTIES RIPPLE EFFECT - USAGE PROGRAMMATICALY
    var ripplePercent: Float = 2.0 {
        didSet {
            setupRippleView()
        }
    }
    
    var rippleColor: UIColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    var rippleBackgroundColor: UIColor = UIColor(white: 0.95, alpha: 1) {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    private var rippleMask: CAShapeLayer? {
        get {
            if !rippleOverBounds {
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: bounds,
                                              cornerRadius: layer.cornerRadius).cgPath
                return maskLayer
            } else {
                return nil
            }
        }
    }
    
    //PROPERTIES RIPPLE EFFECT - USAGE INTERFACE BUILDER
    @IBInspectable var rippleOverBounds: Bool = false
    @IBInspectable var shadowRippleRadius: Float = 1
    @IBInspectable var shadowRippleEnable: Bool = true
    @IBInspectable var trackTouchLocation: Bool = false
    @IBInspectable var buttonBackgroundColor: UIColor = UIColor(red:0.96, green:0.26, blue:0.21, alpha:1.0) //Red Color Material Design
    
    //FOR DESIGN
    private let rippleView = UIView()
    private let rippleBackgroundView = UIView()
    
    //FOR DATA
    private var tempShadowRadius: CGFloat = 0
    private var tempShadowOpacity: Float = 0
    
    private var count = 0
    var badge = BadgeSwift()
    //MARK: INITIALISERS
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init () {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    //MARK: LIFE OF VIEW
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupRippleView()
        
        let oldCenter = rippleView.center
        rippleView.center = oldCenter
        
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask
        
        
    }
    
    //MARK: SETUP SimpleFloatingButton
    
    //General setup of the view
    private func setup() {
        setupViewFrame()
        setupRippleView()
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        layer.addSublayer(rippleBackgroundView.layer)
        
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        rippleBackgroundView.layer.addSublayer(rippleView.layer)
        rippleBackgroundView.alpha = 0
        
        self.setImage(getImage("ic_expand_more")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = CHAppConstant.themeStyle == CHLightThemeColors.tintColor
        
        setupBadge()
    }
    
    //Setup the frame view
    private func setupViewFrame(){
        let value:CGFloat = CHStyle.hasNotchAvailable == true ? 190 : 160
        //Defaull Value
        var dim: CGFloat = UIScreen.main.bounds.height / 20
        var y: CGFloat = UIScreen.main.bounds.height - dim - value //120
        var x: CGFloat = UIScreen.main.bounds.width - dim - 10 //10
        
        if(UIDevice.current.orientation.isLandscape) {
            dim = UIScreen.main.bounds.height / 6
            y = UIScreen.main.bounds.height - dim - 20
            x = UIScreen.main.bounds.width - dim - 20
        }
        
        let newFrame = CGRect.init(x:0, y:0, width:dim, height:dim)
        self.frame = newFrame
        self.frame = CGRect(x:x, y:y, width:self.frame.height, height:self.frame.height)
        self.layer.cornerRadius = 0.5 * self.frame.height
        
    }
    
    //Setup the ripple effect
    private func setupRippleView() {
        let size: CGFloat = bounds.width * CGFloat(ripplePercent)
        let x: CGFloat = (bounds.width/2) - (size/2)
        let y: CGFloat = (bounds.height/2) - (size/2)
        let corner: CGFloat = size/2
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRect(x:x, y:y, width:size, height:size)
        rippleView.layer.cornerRadius = corner
    }
    
    private func setupBadge(){
        
        badge.badgeColor = UIColor.red
        badge.textColor = UIColor.white
        badge.font = UIFont.systemFont(ofSize: 14.0)
        badge.layer.masksToBounds = true
        badge.isHidden = true
        
        self.addSubview(badge)
        
        
    }
    
    func updateBadgeCount(){
        count+=1
        let x = self.frame.width - 15
        badge.isHidden = false
        badge.text = String(count)
        badge.frame = CGRect.init(x:x, y:-2, width:badge.intrinsicContentSize.width, height:badge.intrinsicContentSize.height)
    }
    
    func removeBadgeCount(){
        count = 0
        badge.isHidden = true
    }
    
    func updateHeight(isOpen:Bool){
        if(isOpen){
            self.frame.origin.y -= 250
        }else{
            self.frame.origin.y += 250
        }
    }
    //Draw the cross on button
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(ovalIn: rect)
        UIColor.white.setFill()
        path.fill()
        
    }
    
    
    
    //MARK: Handles Touch Tracking and Animations
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        if trackTouchLocation {
            rippleView.center = touch.location(in: self)
        }
        
        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.rippleBackgroundView.alpha = 1
        }, completion: nil)
        
        rippleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut,
                       animations: {
                        self.rippleView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        if shadowRippleEnable {
            tempShadowRadius = layer.shadowRadius
            tempShadowOpacity = layer.shadowOpacity
            
            let shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
            shadowAnim.toValue = shadowRippleRadius
            
            let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
            opacityAnim.toValue = 1
            
            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.7
            groupAnim.fillMode = CAMediaTimingFillMode.forwards
            groupAnim.isRemovedOnCompletion = false
            groupAnim.animations = [shadowAnim, opacityAnim]
            
            layer.add(groupAnim, forKey:"shadow")
        }
        return super.beginTracking(touch, with: event)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        animateToNormal()
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        animateToNormal()
    }
    
    private func animateToNormal(){
        UIView.animate(withDuration: 0.1,animations: {
            self.rippleBackgroundView.alpha = 1
        },completion: {(success: Bool) -> () in
            UIView.animate(withDuration: 0.6 ,animations: {
                self.rippleBackgroundView.alpha = 0
            }, completion: nil)
        })
        
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveEaseOut,animations: {
            self.rippleView.transform = CGAffineTransform.identity
            
            let shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
            shadowAnim.toValue = self.tempShadowRadius
            
            let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
            opacityAnim.toValue = self.tempShadowOpacity
            
            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.7
            groupAnim.fillMode = CAMediaTimingFillMode.forwards
            groupAnim.isRemovedOnCompletion = false
            groupAnim.animations = [shadowAnim, opacityAnim]
            
            self.layer.add(groupAnim, forKey:"shadowBack")
        }, completion: nil)
    }
    
}


