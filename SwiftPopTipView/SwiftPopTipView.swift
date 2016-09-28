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
    case any = 0
    case up, down
}

enum SwiftPopTipAnimation: Int {
    case slide = 0
    case pop
}

protocol SwiftPopTipViewDelegate {
    func popTipViewWasDismissedByUser(_ popTipView:SwiftPopTipView)
}

class SwiftPopTipView: UIView {
    var delegate: SwiftPopTipViewDelegate?
    var disableTapToDismiss = false
    var dismissTapAnywhere = true
    var isShowing = false
    var title: String?
    var message: String?
    var customView: UIView?
    var targetObject: Any?
    var popColor = UIColor.white
    var titleColor: UIColor?
    var titleFont = UIFont.boldSystemFont(ofSize: 16)
    var textColor = UIColor.black
    var textFont = UIFont.boldSystemFont(ofSize: 14)
    var titleAlignment: NSTextAlignment = .center
    var textAlignment: NSTextAlignment = .center
    var has3DStyle = false
    var borderColor = UIColor.black
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
                layer.shadowOffset = CGSize(width: 0, height: 3)
                layer.shadowRadius = 2
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.3
            } else {
                layer.shadowOpacity = 0.0
            }
        }
    }
    var animation: SwiftPopTipAnimation = .slide
    var maxWidth: CGFloat?
    var preferredPointDirection: PointDirection = .any
    var pointDirection: PointDirection = .any
    var hasGradientBackground = false
    var sidePadding: CGFloat = 2
    var topMargin: CGFloat = 2
    var pointerSize: CGFloat = 12
    var bubbleSize: CGSize = CGSize.zero
    var targetPoint: CGPoint = CGPoint.zero
    var autoDismissTimer: Timer?
    var dismissTarget: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    required init () {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        titleFont = UIFont.boldSystemFont(ofSize: 16)
        titleColor = UIColor.black
        titleAlignment = .center
        textFont = UIFont.systemFont(ofSize: 14)
        textColor = UIColor.black
    }
    
    init(title: String? = nil, message: String? = nil, customView: UIView? = nil) {
        super.init(frame: CGRect.zero)
        self.title = title
        self.message = message
        
        backgroundColor = UIColor.clear
        titleFont = UIFont.boldSystemFont(ofSize: 16)
        titleColor = UIColor.black
        titleAlignment = .center
        textFont = UIFont.systemFont(ofSize: 14)
        textColor = UIColor.black
        if let aView = customView {
            self.customView = aView
            addSubview(customView!)
        }
    }
    
    func bubbleFrame() -> CGRect {
        var bubbleFrame: CGRect
        if pointDirection == .up {
            bubbleFrame = CGRect(x: sidePadding, y: targetPoint.y+pointerSize, width: bubbleSize.width, height: bubbleSize.height);
        } else {
            bubbleFrame = CGRect(x: sidePadding, y: targetPoint.y-pointerSize-bubbleSize.height, width: bubbleSize.width, height: bubbleSize.height);
        }
        return bubbleFrame
    }
    
    func contentFrame() -> CGRect {
        let customBubbleFrame = bubbleFrame()
        let contentFrame = CGRect(x: customBubbleFrame.origin.x + cornerRadius,
                                  y: customBubbleFrame.origin.y + cornerRadius,
                                  width: customBubbleFrame.size.width - cornerRadius*2,
                                  height: customBubbleFrame.size.height - cornerRadius*2)
        return contentFrame
    }
    
    override func layoutSubviews() {
        if let customView = customView {
            let customContentFrame = contentFrame()
            customView.frame = customContentFrame
        }
    }
    
    override func draw(_ rect: CGRect) {
        let bubbleRect = bubbleFrame()
        
        let c = UIGraphicsGetCurrentContext()
        
        c?.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        c?.setLineWidth(borderWidth)
        
        let bubblePath = CGMutablePath()
        
        if pointDirection == .up {
            bubblePath.move(to: CGPoint(x: targetPoint.x+sidePadding, y: targetPoint.y))
            bubblePath.addLine(to: CGPoint(x: targetPoint.x+sidePadding+pointerSize, y: targetPoint.y+pointerSize))
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width, y: bubbleRect.origin.y),
                              tangent2End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width, y: bubbleRect.origin.y+cornerRadius),
                              radius: cornerRadius)
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width, y: bubbleRect.origin.y+bubbleRect.size.height),
                              tangent2End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, y: bubbleRect.origin.y+bubbleRect.size.height),
                              radius: cornerRadius)
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x, y: bubbleRect.origin.y+bubbleRect.size.height),
                              tangent2End: CGPoint(x: bubbleRect.origin.x, y: bubbleRect.origin.y+bubbleRect.size.height-cornerRadius),
                              radius: cornerRadius)
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x, y: bubbleRect.origin.y),
                              tangent2End: CGPoint(x: bubbleRect.origin.x+cornerRadius, y: bubbleRect.origin.y),
                              radius: cornerRadius)
            bubblePath.addLine(to: CGPoint(x: targetPoint.x+sidePadding-pointerSize, y: targetPoint.y+pointerSize))
        } else {
            bubblePath.move(to: CGPoint(x: targetPoint.x+sidePadding, y: targetPoint.y))
            bubblePath.addLine(to: CGPoint(x: targetPoint.x+sidePadding-pointerSize, y: targetPoint.y-pointerSize))
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x, y: bubbleRect.origin.y+bubbleRect.size.height),
                              tangent2End: CGPoint(x: bubbleRect.origin.x, y: bubbleRect.origin.y+bubbleRect.size.height-cornerRadius),
                              radius: cornerRadius)
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x, y: bubbleRect.origin.y),
                              tangent2End: CGPoint(x: bubbleRect.origin.x+cornerRadius, y: bubbleRect.origin.y),
                              radius: cornerRadius)
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width, y: bubbleRect.origin.y),
                              tangent2End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width, y: bubbleRect.origin.y+cornerRadius),
                              radius: cornerRadius)
            bubblePath.addArc(tangent1End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width, y: bubbleRect.origin.y+bubbleRect.size.height),
                              tangent2End: CGPoint(x: bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, y: bubbleRect.origin.y+bubbleRect.size.height),
                              radius: cornerRadius)
            bubblePath.addLine(to: CGPoint(x: targetPoint.x+sidePadding+pointerSize, y: targetPoint.y-pointerSize))
        }
        
        bubblePath.closeSubpath()
        
        c?.saveGState()
        c?.addPath(bubblePath)
        c?.clip()
        
        if !hasGradientBackground {
            c?.setFillColor(popColor.cgColor)
            c?.fill(bounds)
        } else {
            let bubbleMiddle = (bubbleRect.origin.y+(bubbleRect.size.height/2)) / bounds.size.height
            
            var myGradient: CGGradient
            var myColorSpace: CGColorSpace
            let locationCount: size_t = 5
            let locationList: [CGFloat] = [0.0, bubbleMiddle-0.03, bubbleMiddle, bubbleMiddle+0.03, 1.0]
            
            var colourHL: CGFloat = 0
            if highlight {
                colourHL = 0.25
            }
            
            var red, green, blue, alpha: CGFloat
            let numComponents: size_t = backgroundColor!.cgColor.numberOfComponents
            let components = backgroundColor!.cgColor.components
            if numComponents == 2 {
                red = (components?[0])!
                green = (components?[0])!
                blue = (components?[0])!
                alpha = (components?[1])!
            } else {
                red = (components?[0])!
                green = (components?[1])!
                blue = (components?[2])!
                alpha = (components?[3])!
            }
            let colorList: [CGFloat] = [
                red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
                red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
                red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
                red+colourHL, green+colourHL, blue+colourHL, alpha,
                red+colourHL, green+colourHL, blue+colourHL, alpha
            ]
            myColorSpace = CGColorSpaceCreateDeviceRGB()
            myGradient = CGGradient(colorSpace: myColorSpace, colorComponents: colorList, locations: locationList, count: locationCount)!
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: bounds.maxY)
            
            c?.drawLinearGradient(myGradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        }
        
        if has3DStyle {
            c?.saveGState()
            let innerShadowPath = CGMutablePath()
            innerShadowPath.addRect(bubblePath.boundingBoxOfPath.insetBy(dx: -30, dy: -30))
            innerShadowPath.addPath(bubblePath)
            innerShadowPath.closeSubpath()
            
            let highlightColor = UIColor(white: 1, alpha: 0.75)
            c?.setFillColor(highlightColor.cgColor)
            c?.setShadow(offset: CGSize(width: 0, height: 4), blur: 4, color: highlightColor.cgColor)
            c?.addPath(innerShadowPath)
            c?.fillPath()
            
            let shadowColor = UIColor(white: 0, alpha: 0.4)
            c?.setFillColor(shadowColor.cgColor)
            c?.setShadow(offset: CGSize(width: 0, height: -4), blur: 4, color: shadowColor.cgColor)
            c?.addPath(innerShadowPath)
            c?.fillPath()
            c?.restoreGState()
        }
        
        c?.restoreGState()
        
        if borderWidth > 0 {
            let numBorderComponents: size_t = borderColor.cgColor.numberOfComponents
            let borderComponents = borderColor.cgColor.components
            var r, g, b, a: CGFloat
            if numBorderComponents == 2 {
                r = (borderComponents?[0])!
                g = (borderComponents?[0])!
                b = (borderComponents?[0])!
                a = (borderComponents?[1])!
            } else {
                r = (borderComponents?[0])!
                g = (borderComponents?[1])!
                b = (borderComponents?[2])!
                a = (borderComponents?[3])!
            }
            
            c?.setStrokeColor(red: r, green: g, blue: b, alpha: a)
            c?.addPath(bubblePath)
            c?.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        if let title = title {
            titleColor?.set()
            let titleFrame = contentFrame()
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = titleAlignment
            titleParagraphStyle.lineBreakMode = .byClipping
            title.draw(with: titleFrame, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: titleColor!, NSParagraphStyleAttributeName: titleParagraphStyle], context: nil)
        }
        
        if let message = message {
            textColor.set()
            var textFrame = contentFrame()
            
            if let title = title {
                let titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.alignment = titleAlignment
                titleParagraphStyle.lineBreakMode = .byClipping
                textFrame.origin.y += title.boundingRect(with: CGSize(width: textFrame.size.width, height: 99999.0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleFont, NSParagraphStyleAttributeName: titleParagraphStyle], context: nil).size.height
            }
            
            let textParagraphStyle = NSMutableParagraphStyle()
            textParagraphStyle.alignment = textAlignment
            textParagraphStyle.lineBreakMode = .byWordWrapping
            
            message.draw(with: textFrame, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont, NSParagraphStyleAttributeName: textParagraphStyle, NSForegroundColorAttributeName: textColor], context: nil)
        }
    }
    
    func presentPointingAtBarButtonItem(_ barButtonItem: UIBarButtonItem, animated: Bool) {
        let targetView = barButtonItem.value(forKey: "view") as! UIView
        let targetSuperview = targetView.superview
        var containerView: UIView?
        if type(of: targetSuperview!) === UINavigationBar.self {
            containerView = UIApplication.shared.keyWindow
        } else if type(of: targetSuperview!) === UIToolbar.self {
            containerView = targetSuperview?.superview
        }
        containerView = targetSuperview?.superview
        
        if containerView == nil {
            NSLog("Cannot determine container view from UIBarButtonItem: %@", barButtonItem);
            targetObject = nil
            return
        }
        
        targetObject = barButtonItem
        
        self.presentPointingAtView(targetView, containerView: containerView!, animated: animated)
    }
    
    func presentPointingAtView(_ targetView: UIView, containerView: UIView, animated: Bool) {
        if isShowing {
            return
        }
        isShowing = true
        if targetObject == nil {
            targetObject = targetView
        }
        
        if dismissTapAnywhere {
            dismissTarget = UIButton(type: .custom)
            dismissTarget?.addTarget(self, action: #selector(dismissTapAnywhereFired(_:)), for: .touchUpInside)
            dismissTarget?.setTitle("", for: UIControlState())
            dismissTarget?.frame = containerView.bounds
            if let dismissTarget = dismissTarget {
                containerView.addSubview(dismissTarget)
            }
        }
        
        containerView.addSubview(self)
        
        var rectWidth: CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let maxWidth = maxWidth {
                if maxWidth < containerView.frame.size.width {
                    rectWidth = maxWidth
                } else {
                    rectWidth = containerView.frame.size.width - 20
                }
            } else {
                rectWidth = containerView.frame.size.width/3
            }
        } else {
            if let maxWidth = maxWidth {
                if maxWidth < containerView.frame.size.width {
                    rectWidth = maxWidth
                } else {
                    rectWidth = containerView.frame.size.width - 10
                }
            } else {
                rectWidth = containerView.frame.size.width*2/3
            }
        }
        
        var textSize = CGSize.zero
        
        if let message = message {
            let textParagraphStyle = NSMutableParagraphStyle()
            textParagraphStyle.alignment = textAlignment
            textParagraphStyle.lineBreakMode = .byWordWrapping
            textSize = message.boundingRect(with: CGSize(width: rectWidth, height: 99999.0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont, NSParagraphStyleAttributeName: textParagraphStyle], context: nil).size
        }
        if let customView = customView {
            textSize = customView.frame.size
        }
        if let title = title {
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineBreakMode = .byClipping
            textSize.height += title.boundingRect(with: CGSize(width: rectWidth, height: 99999.0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleFont, NSParagraphStyleAttributeName: titleParagraphStyle], context: nil).size.height
        }
        
        bubbleSize = CGSize(width: textSize.width + cornerRadius*2, height: textSize.height + cornerRadius*2)
        
        var superview = containerView.superview
        
        if let sv = superview, type(of: sv) === UIWindow.self {
            superview = containerView
        }
        
        let targetRelativeOrigin = targetView.superview!.convert(targetView.frame.origin, to:superview)
        let containerRelativeOrigin = superview!.convert(containerView.frame.origin, to:superview)
        
        var pointerY: CGFloat
        
        
        if targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y {
            pointerY = 0
            pointDirection = .up
        } else if targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height {
            pointerY = containerView.bounds.size.height
            pointDirection = .down
        } else {
            pointDirection = preferredPointDirection
            let targetOriginInContainer = targetView.convert(CGPoint(x: 0.0, y: 0.0), to:containerView)
            let sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y
            if pointDirection == .any {
                if sizeBelow > targetOriginInContainer.y {
                    pointerY = targetOriginInContainer.y + targetView.bounds.size.height
                    pointDirection = .up
                } else {
                    pointerY = targetOriginInContainer.y
                    pointDirection = .down
                }
            } else {
                if pointDirection == .down {
                    pointerY = targetOriginInContainer.y
                } else {
                    pointerY = targetOriginInContainer.y + targetView.bounds.size.height
                }
            }
        }
        
        let W = containerView.bounds.size.width
        
        let p = targetView.superview!.convert(targetView.center, to:containerView)
        var x_p = p.x
        var x_b = x_p - CGFloat(roundf(Float(bubbleSize.width/2)))
        if x_b < sidePadding {
            x_b = sidePadding
        }
        if x_b + bubbleSize.width + sidePadding > W {
            x_b = W - bubbleSize.width - sidePadding
        }
        if x_p - pointerSize < x_b + cornerRadius {
            x_p = x_b + cornerRadius + pointerSize
        }
        if x_p + pointerSize > x_b + bubbleSize.width - cornerRadius {
            x_p = x_b + bubbleSize.width - cornerRadius - pointerSize
        }
        
        let fullHeight = bubbleSize.height + pointerSize + 10
        var y_b: CGFloat
        if pointDirection == .up {
            y_b = topMargin + pointerY
            targetPoint = CGPoint(x: x_p-x_b, y: 0)
        } else {
            y_b = pointerY - fullHeight
            targetPoint = CGPoint(x: x_p-x_b, y: fullHeight-2)
        }
        
        let finalFrame = CGRect(x: x_b-sidePadding, y: y_b, width: bubbleSize.width+sidePadding*2, height: fullHeight)
        if animated {
            if animation == .slide {
                alpha = 0
                var startFrame = finalFrame
                startFrame.origin.y += 10
                frame = startFrame
            } else if animation == .pop {
                frame = finalFrame
                alpha = 0.5
                
                transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDelegate(self)
                UIView.setAnimationDidStop(#selector(popAnimationDidStop(_:finished:context:)))
                UIView.setAnimationDuration(0.15)
                transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                alpha = 1
                UIView.commitAnimations()
            }
            
            setNeedsDisplay()
            
            if animation == .slide {
                UIView.beginAnimations(nil, context: nil)
                alpha = 1
                frame = finalFrame
                UIView.commitAnimations()
            }
        } else {
            setNeedsDisplay()
            frame = finalFrame
        }
    }
    
    func finaliseDismiss() {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        
        if let dismissTarget = dismissTarget {
            dismissTarget.removeFromSuperview()
            self.dismissTarget = nil
        }
        
        removeFromSuperview()
        
        highlight = false
        targetObject = nil
    }
    
    func dismissAnimated(_ animated: Bool) {
        isShowing = false
        if animated {
            var customFrame = frame
            customFrame.origin.y += 10
            
            UIView.beginAnimations(nil, context: nil)
            alpha = 0
            frame = customFrame
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStop(#selector(finaliseDismiss))
            UIView.commitAnimations()
        } else {
            finaliseDismiss()
        }
    }
    
    func autoDismissAnimatedDidFire(_ theTimer: Timer) {
        let animated = (theTimer.userInfo as! [String: Any])["animated"] as! Bool
        dismissAnimated(animated)
        notifyDelegatePopTipViewWasDismissedByUser()
    }
    
    func autoDismissAnimated(_ animated: Bool, atTimeInterval timeInvertal:TimeInterval) {
        autoDismissTimer = Timer.scheduledTimer(timeInterval: timeInvertal, target: self, selector: #selector(autoDismissAnimatedDidFire(_:)), userInfo: ["animated": true], repeats: false)
    }
    
    func notifyDelegatePopTipViewWasDismissedByUser() {
        delegate?.popTipViewWasDismissedByUser(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if disableTapToDismiss {
            super.touchesBegan(touches, with: event)
            return
        }
        dismissByUser()
    }
    
    func dismissTapAnywhereFired(_ button: UIButton) {
        dismissByUser()
    }
    
    func dismissByUser() {
        highlight = true
        setNeedsDisplay()
        dismissAnimated(true)
        notifyDelegatePopTipViewWasDismissedByUser()
    }
    
    func popAnimationDidStop(_ animationID: String, finished: Bool, context: Any) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.1)
        transform = CGAffineTransform.identity
        UIView.commitAnimations()
    }
    
    func presentAnimatedPointingAtBarButtonItem(_ barButtonItem: UIBarButtonItem, autodismissAtTime time:TimeInterval) {
        presentPointingAtBarButtonItem(barButtonItem, animated: true)
        autoDismissAnimated(true, atTimeInterval: time)
    }
    
    func presentAnimatedPointingAtView(_ atView: UIView, inView: UIView, autodismissAtTime time:TimeInterval) {
        presentPointingAtView(atView, containerView: inView, animated: true)
        autoDismissAnimated(true, atTimeInterval: time)
    }
}
