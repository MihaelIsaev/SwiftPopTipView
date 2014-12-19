//
//  SwiftPopTipView.swift
//  SwiftPopTipView
//
//  Created by Mihael Isaev on 18.12.14.
//  Copyright (c) 2014 Mihael Isaev inc. All rights reserved.
//

import Foundation
import UIKit

enum PointDirection: Int {
    case Any = 0
    case Up, Down
}

enum SwiftPopTipAnimation: Int {
    case Slide = 0
    case Pop
}

protocol SwiftPopTipViewDelegate {
    func popTipViewWasDismissedByUser(popTipView:SwiftPopTipView)
}

class SwiftPopTipView: UIView {
    var delegate: SwiftPopTipViewDelegate?
    var disableTapToDismiss = false
    var dismissTapAnywhere = true
    var isShowing = false
    var title: NSString?
    var message: NSString?
    var customView: UIView?
    var targetObject: AnyObject?
    var popColor = UIColor.whiteColor()
    var titleColor: UIColor?
    var titleFont = UIFont.boldSystemFontOfSize(16)
    var textColor = UIColor.blackColor()
    var textFont = UIFont.boldSystemFontOfSize(14)
    var titleAlignment: NSTextAlignment = .Center
    var textAlignment: NSTextAlignment = .Center
    var has3DStyle = false
    var borderColor = UIColor.blackColor()
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0.1
    var highlight = false
    var hasShadow: Bool {
        get {
            return self.hasShadow
        }
        set {
            self.hasShadow = newValue
            if newValue {
                self.layer.shadowOffset = CGSizeMake(0, 3)
                self.layer.shadowRadius = 2
                self.layer.shadowColor = UIColor.blackColor().CGColor
                self.layer.shadowOpacity = 0.3
            } else {
                self.layer.shadowOpacity = 0.0
            }
        }
    }
    var animation: SwiftPopTipAnimation = .Slide
    var maxWidth: CGFloat?
    var preferredPointDirection: PointDirection = .Any
    var pointDirection: PointDirection = .Any
    var hasGradientBackground = false
    var sidePadding: CGFloat = 2
    var topMargin: CGFloat = 2
    var pointerSize: CGFloat = 12
    var bubbleSize: CGSize = CGSizeZero
    var targetPoint: CGPoint = CGPointZero
    var autoDismissTimer: NSTimer?
    var dismissTarget: UIButton?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    init(title: String? = nil, message: String? = nil, customView: UIView? = nil) {
        super.init(frame: CGRectZero)
        self.title = title
        self.message = message
        
        self.backgroundColor = UIColor.clearColor()
        self.titleFont = UIFont.boldSystemFontOfSize(16)
        self.titleColor = UIColor.blackColor()
        self.titleAlignment = .Center
        self.textFont = UIFont.systemFontOfSize(14)
        self.textColor = UIColor.blackColor()
        if let aView = customView {
            self.customView = aView
            self.addSubview(self.customView!)
        }
    }
    
    func bubbleFrame() -> CGRect {
        var bubbleFrame: CGRect
        if self.pointDirection == .Up {
            bubbleFrame = CGRectMake(self.sidePadding, self.targetPoint.y+self.pointerSize, self.bubbleSize.width, self.bubbleSize.height);
        }
        else {
            bubbleFrame = CGRectMake(self.sidePadding, self.targetPoint.y-self.pointerSize-self.bubbleSize.height, self.bubbleSize.width, self.bubbleSize.height);
        }
        return bubbleFrame
    }
    
    func contentFrame() -> CGRect {
        var bubbleFrame = self.bubbleFrame()
        var contentFrame = CGRectMake(bubbleFrame.origin.x + self.cornerRadius,
            bubbleFrame.origin.y + self.cornerRadius,
            bubbleFrame.size.width - self.cornerRadius*2,
            bubbleFrame.size.height - self.cornerRadius*2)
        return contentFrame
    }
    
    override func layoutSubviews() {
        if let customView = self.customView {
            var contentFrame = self.contentFrame()
            customView.frame = contentFrame
        }
    }
    
    override func drawRect(rect: CGRect) {
        var bubbleRect = self.bubbleFrame()
        
        var c = UIGraphicsGetCurrentContext()
        
        CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0)
        CGContextSetLineWidth(c, self.borderWidth)
        
        var bubblePath = CGPathCreateMutable()
        
        if self.pointDirection == .Up {
            CGPathMoveToPoint(bubblePath, nil, self.targetPoint.x+self.sidePadding, self.targetPoint.y)
            CGPathAddLineToPoint(bubblePath, nil, self.targetPoint.x+self.sidePadding+self.pointerSize, self.targetPoint.y+self.pointerSize)
            
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
                bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+self.cornerRadius,
                self.cornerRadius)
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
                bubbleRect.origin.x+bubbleRect.size.width-self.cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
                self.cornerRadius)
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
                bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-self.cornerRadius,
                self.cornerRadius)
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x, bubbleRect.origin.y,
                bubbleRect.origin.x+self.cornerRadius, bubbleRect.origin.y,
                self.cornerRadius)
            CGPathAddLineToPoint(bubblePath, nil, self.targetPoint.x+self.sidePadding-self.pointerSize, self.targetPoint.y+self.pointerSize)
        } else {
            CGPathMoveToPoint(bubblePath, nil, self.targetPoint.x+self.sidePadding, self.targetPoint.y)
            CGPathAddLineToPoint(bubblePath, nil, self.targetPoint.x+self.sidePadding-self.pointerSize, self.targetPoint.y-self.pointerSize)
            
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
                bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-self.cornerRadius,
                self.cornerRadius)
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x, bubbleRect.origin.y,
                bubbleRect.origin.x+self.cornerRadius, bubbleRect.origin.y,
                self.cornerRadius)
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
                bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+self.cornerRadius,
                self.cornerRadius)
            CGPathAddArcToPoint(bubblePath, nil,
                bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
                bubbleRect.origin.x+bubbleRect.size.width-self.cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
                self.cornerRadius)
            CGPathAddLineToPoint(bubblePath, nil, self.targetPoint.x+self.sidePadding+self.pointerSize, self.targetPoint.y-self.pointerSize)
        }
        
        CGPathCloseSubpath(bubblePath)
        
        CGContextSaveGState(c)
        CGContextAddPath(c, bubblePath)
        CGContextClip(c)
        
        if !self.hasGradientBackground {
            CGContextSetFillColorWithColor(c, self.popColor.CGColor)
            CGContextFillRect(c, self.bounds)
        } else {
            var bubbleMiddle = (bubbleRect.origin.y+(bubbleRect.size.height/2)) / self.bounds.size.height
            
            var myGradient: CGGradientRef
            var myColorSpace: CGColorSpaceRef
            var locationCount: size_t = 5
            var locationList: [CGFloat] = [0.0, bubbleMiddle-0.03, bubbleMiddle, bubbleMiddle+0.03, 1.0]
            
            var colourHL: CGFloat = 0
            if self.highlight {
                colourHL = 0.25
            }
            
            var red, green, blue, alpha: CGFloat
            var numComponents: size_t = CGColorGetNumberOfComponents(self.backgroundColor!.CGColor)
            var components = CGColorGetComponents(self.backgroundColor!.CGColor)
            if numComponents == 2 {
                red = components[0]
                green = components[0]
                blue = components[0]
                alpha = components[1]
            } else {
                red = components[0]
                green = components[1]
                blue = components[2]
                alpha = components[3]
            }
            var colorList: [CGFloat] = [
                red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
                red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
                red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
                red+colourHL, green+colourHL, blue+colourHL, alpha,
                red+colourHL, green+colourHL, blue+colourHL, alpha
            ]
            myColorSpace = CGColorSpaceCreateDeviceRGB()
            myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount)
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: CGRectGetMaxY(self.bounds))
            
            CGContextDrawLinearGradient(c, myGradient, startPoint, endPoint,0)
        }
        
        if self.has3DStyle {
            CGContextSaveGState(c)
            var innerShadowPath = CGPathCreateMutable()
            
            CGPathAddRect(innerShadowPath, nil, CGRectInset(CGPathGetPathBoundingBox(bubblePath), -30, -30))
            
            CGPathAddPath(innerShadowPath, nil, bubblePath)
            CGPathCloseSubpath(innerShadowPath)
            
            var highlightColor = UIColor(white: 1, alpha: 0.75)
            CGContextSetFillColorWithColor(c, highlightColor.CGColor)
            CGContextSetShadowWithColor(c, CGSizeMake(0, 4), 4, highlightColor.CGColor)
            CGContextAddPath(c, innerShadowPath)
            CGContextEOFillPath(c)
            
            var shadowColor = UIColor(white: 0, alpha: 0.4)
            CGContextSetFillColorWithColor(c, shadowColor.CGColor)
            CGContextSetShadowWithColor(c, CGSizeMake(0, -4), 4, shadowColor.CGColor)
            CGContextAddPath(c, innerShadowPath)
            CGContextEOFillPath(c)
            CGContextRestoreGState(c)
        }
        
        CGContextRestoreGState(c)
        
        if self.borderWidth > 0 {
            var numBorderComponents: size_t = CGColorGetNumberOfComponents(self.borderColor.CGColor)
            var borderComponents = CGColorGetComponents(self.borderColor.CGColor)
            var r, g, b, a: CGFloat
            if numBorderComponents == 2 {
                r = borderComponents[0]
                g = borderComponents[0]
                b = borderComponents[0]
                a = borderComponents[1]
            } else {
                r = borderComponents[0]
                g = borderComponents[1]
                b = borderComponents[2]
                a = borderComponents[3]
            }
            
            CGContextSetRGBStrokeColor(c, r, g, b, a)
            CGContextAddPath(c, bubblePath)
            CGContextDrawPath(c, kCGPathStroke)
        }
        
        if let title = self.title {
            self.titleColor?.set()
            var titleFrame = self.contentFrame()
            var titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = self.titleAlignment
            titleParagraphStyle.lineBreakMode = .ByClipping
            title.drawWithRect(titleFrame, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.titleFont, NSForegroundColorAttributeName: self.titleColor!, NSParagraphStyleAttributeName: titleParagraphStyle], context: nil)
        }
        
        if let message = self.message {
            self.textColor.set()
            var textFrame = self.contentFrame()
            
            if let title = self.title {
                var titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.alignment = self.titleAlignment
                titleParagraphStyle.lineBreakMode = .ByClipping
                textFrame.origin.y += title.boundingRectWithSize(CGSizeMake(textFrame.size.width, 99999.0), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.titleFont, NSParagraphStyleAttributeName: titleParagraphStyle], context: nil).size.height
            }
            
            var textParagraphStyle = NSMutableParagraphStyle()
            textParagraphStyle.alignment = self.textAlignment
            textParagraphStyle.lineBreakMode = .ByWordWrapping

            message.drawWithRect(textFrame, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.textFont, NSParagraphStyleAttributeName: textParagraphStyle, NSForegroundColorAttributeName: self.textColor], context: nil)
        }
    }
    
    func presentPointingAtBarButtonItem(barButtonItem: UIBarButtonItem, animated: Bool) {
        var targetView = barButtonItem.valueForKey("view") as UIView
        var targetSuperview = targetView.superview
        var containerView: UIView?
        if targetSuperview!.dynamicType === UINavigationBar.self {
            containerView = UIApplication.sharedApplication().keyWindow
        } else if targetSuperview!.dynamicType === UIToolbar.self {
            containerView = targetSuperview?.superview
        }
        containerView = targetSuperview?.superview
        
        if containerView == nil {
            NSLog("Cannot determine container view from UIBarButtonItem: %@", barButtonItem);
            self.targetObject = nil
            return
        }
        
        self.targetObject = barButtonItem
        
        self.presentPointingAtView(targetView, containerView: containerView!, animated: animated)
    }
    
    func presentPointingAtView(targetView: UIView, containerView: UIView, animated: Bool) {
        if self.isShowing {
            return
        }
        self.isShowing = true
        if self.targetObject == nil {
            self.targetObject = targetView
        }
        
        if self.dismissTapAnywhere {
            self.dismissTarget = UIButton.buttonWithType(.Custom) as? UIButton
            self.dismissTarget?.addTarget(self, action: "dismissTapAnywhereFired:", forControlEvents: .TouchUpInside)
            self.dismissTarget?.setTitle("", forState: .Normal)
            self.dismissTarget?.frame = containerView.bounds
            if let dismissTarget = self.dismissTarget {
                containerView.addSubview(dismissTarget)
            }
        }
        
        containerView.addSubview(self)
        
        var rectWidth: CGFloat
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let maxWidth = self.maxWidth {
                if maxWidth < containerView.frame.size.width {
                    rectWidth = maxWidth
                } else {
                    rectWidth = containerView.frame.size.width - 20
                }
            } else {
                rectWidth = containerView.frame.size.width/3
            }
        } else {
            if let maxWidth = self.maxWidth {
                if maxWidth < containerView.frame.size.width {
                    rectWidth = maxWidth
                } else {
                    rectWidth = containerView.frame.size.width - 10
                }
            } else {
                rectWidth = containerView.frame.size.width*2/3
            }
        }
        
        var textSize = CGSizeZero
        
        if let message = self.message {
            var textParagraphStyle = NSMutableParagraphStyle()
            textParagraphStyle.alignment = self.textAlignment
            textParagraphStyle.lineBreakMode = .ByWordWrapping
            textSize = message.boundingRectWithSize(CGSizeMake(rectWidth, 99999.0), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.textFont, NSParagraphStyleAttributeName: textParagraphStyle], context: nil).size
        }
        if let customView = self.customView {
            textSize = customView.frame.size
        }
        if let title = self.title {
            var titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineBreakMode = .ByClipping
            textSize.height += title.boundingRectWithSize(CGSizeMake(rectWidth, 99999.0), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.titleFont, NSParagraphStyleAttributeName: titleParagraphStyle], context: nil).size.height
        }
        
        self.bubbleSize = CGSizeMake(textSize.width + self.cornerRadius*2, textSize.height + self.cornerRadius*2)
        
        var superview = containerView.superview
        
        if superview?.dynamicType === UIWindow.self {
            superview = containerView
        }
        
        let targetRelativeOrigin = targetView.superview!.convertPoint(targetView.frame.origin, toView:superview)
        let containerRelativeOrigin = superview!.convertPoint(containerView.frame.origin, toView:superview)
        
        var pointerY: CGFloat
        
        
        if targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y {
            pointerY = 0
            self.pointDirection = .Up
        } else if targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height {
            pointerY = containerView.bounds.size.height
            self.pointDirection = .Down
        } else {
            self.pointDirection = self.preferredPointDirection
            let targetOriginInContainer = targetView.convertPoint(CGPointMake(0.0, 0.0), toView:containerView)
            let sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y
            if self.pointDirection == .Any {
                if sizeBelow > targetOriginInContainer.y {
                    pointerY = targetOriginInContainer.y + targetView.bounds.size.height
                    self.pointDirection = .Up
                } else {
                    pointerY = targetOriginInContainer.y
                    self.pointDirection = .Down
                }
            } else {
                if self.pointDirection == .Down {
                    pointerY = targetOriginInContainer.y
                } else {
                    pointerY = targetOriginInContainer.y + targetView.bounds.size.height
                }
            }
        }
        
        var W = containerView.bounds.size.width
        
        var p = targetView.superview!.convertPoint(targetView.center, toView:containerView)
        var x_p = p.x
        var x_b = x_p - CGFloat(roundf(Float(self.bubbleSize.width/2)))
        if x_b < self.sidePadding {
            x_b = self.sidePadding
        }
        if x_b + self.bubbleSize.width + self.sidePadding > W {
            x_b = W - self.bubbleSize.width - self.sidePadding
        }
        if x_p - self.pointerSize < x_b + self.cornerRadius {
            x_p = x_b + self.cornerRadius + self.pointerSize
        }
        if x_p + self.pointerSize > x_b + self.bubbleSize.width - self.cornerRadius {
            x_p = x_b + self.bubbleSize.width - self.cornerRadius - self.pointerSize
        }
        
        var fullHeight = self.bubbleSize.height + self.pointerSize + 10
        var y_b: CGFloat
        if self.pointDirection == .Up {
            y_b = self.topMargin + pointerY
            self.targetPoint = CGPointMake(x_p-x_b, 0)
        } else {
            y_b = pointerY - fullHeight
            self.targetPoint = CGPointMake(x_p-x_b, fullHeight-2)
        }
        
        var finalFrame = CGRectMake(x_b-self.sidePadding, y_b, self.bubbleSize.width+self.sidePadding*2, fullHeight)
        if animated {
            if self.animation == .Slide {
                self.alpha = 0
                var startFrame = finalFrame
                startFrame.origin.y += 10
                self.frame = startFrame
            } else if self.animation == .Pop {
                self.frame = finalFrame
                self.alpha = 0.5
                
                self.transform = CGAffineTransformMakeScale(0.75, 0.75)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDelegate(self)
                UIView.setAnimationDidStopSelector("popAnimationDidStop:finished:context:")
                UIView.setAnimationDuration(0.15)
                self.transform = CGAffineTransformMakeScale(1.1, 1.1)
                self.alpha = 1
                UIView.commitAnimations()
            }
            
            self.setNeedsDisplay()
            
            if self.animation == .Slide {
                UIView.beginAnimations(nil, context: nil)
                self.alpha = 1
                self.frame = finalFrame
                UIView.commitAnimations()
            }
        } else {
            self.setNeedsDisplay()
            self.frame = finalFrame
        }
    }
    
    func finaliseDismiss() {
        self.autoDismissTimer?.invalidate()
        self.autoDismissTimer = nil
        
        if let dismissTarget = self.dismissTarget {
            dismissTarget.removeFromSuperview()
            self.dismissTarget = nil
        }
        
        self.removeFromSuperview()
        
        self.highlight = false
        self.targetObject = nil
    }
    
    func dismissAnimated(animated: Bool) {
        self.isShowing = false
        if animated {
            var frame = self.frame
            frame.origin.y += 10
            
            UIView.beginAnimations(nil, context: nil)
            self.alpha = 0
            self.frame = frame
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector("finaliseDismiss")
            UIView.commitAnimations()
        } else {
            self.finaliseDismiss()
        }
    }
    
    func autoDismissAnimatedDidFire(theTimer: NSTimer) {
        var animated = theTimer.userInfo?.objectForKey("animated") as Bool
        self.dismissAnimated(animated)
        self.notifyDelegatePopTipViewWasDismissedByUser()
    }
    
    func autoDismissAnimated(animated: Bool, atTimeInterval timeInvertal:NSTimeInterval) {
        var userInfo = NSDictionary(object: true, forKey: "animated")
        self.autoDismissTimer = NSTimer.scheduledTimerWithTimeInterval(timeInvertal, target: self, selector: "autoDismissAnimatedDidFire:", userInfo: userInfo, repeats: false)
    }
    
    func notifyDelegatePopTipViewWasDismissedByUser() {
        self.delegate?.popTipViewWasDismissedByUser(self)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.disableTapToDismiss {
            super.touchesBegan(touches, withEvent: event)
            return
        }
        self.dismissByUser()
    }
    
    func dismissTapAnywhereFired(button: UIButton) {
        self.dismissByUser()
    }
    
    func dismissByUser() {
        self.highlight = true
        self.setNeedsDisplay()
        self.dismissAnimated(true)
        self.notifyDelegatePopTipViewWasDismissedByUser()
    }
    
    func popAnimationDidStop(animationID: String, finished: Bool, context: AnyObject) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.1)
        self.transform = CGAffineTransformIdentity
        UIView.commitAnimations()
    }
    
    func presentAnimatedPointingAtBarButtonItem(barButtonItem: UIBarButtonItem, autodismissAtTime time:NSTimeInterval) {
        self.presentPointingAtBarButtonItem(barButtonItem, animated: true)
        self.autoDismissAnimated(true, atTimeInterval: time)
    }
    
    func presentAnimatedPointingAtView(atView: UIView, inView: UIView, autodismissAtTime time:NSTimeInterval) {
        self.presentPointingAtView(atView, containerView: inView, animated: true)
        self.autoDismissAnimated(true, atTimeInterval: time)
    }
}