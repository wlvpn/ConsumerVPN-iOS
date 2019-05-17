//
//  ConnectedShield.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/22/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class ConnectedShield: NSObject {
    //MARK: - Canvas Drawings
    class func drawArtboard(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 118, height: 153), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 118, height: 153), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 118, y: resizedFrame.height / 153)
        
        /// Group 6
        do {
            context.saveGState()
            
            /// Group 3
            do {
                context.saveGState()
                
                /// Fill 1
                let fill1 = UIBezierPath()
                fill1.move(to: CGPoint(x: 112.03, y: 72.41))
                fill1.addCurve(to: CGPoint(x: 65.41, y: 143.07), controlPoint1: CGPoint(x: 112.03, y: 103.27), controlPoint2: CGPoint(x: 93.65, y: 131.12))
                fill1.addLine(to: CGPoint(x: 65.39, y: 143.08))
                fill1.addLine(to: CGPoint(x: 57.87, y: 146.35))
                fill1.addLine(to: CGPoint(x: 51.33, y: 143.48))
                fill1.addCurve(to: CGPoint(x: 5.65, y: 73.2), controlPoint1: CGPoint(x: 23.61, y: 131.26), controlPoint2: CGPoint(x: 5.69, y: 103.68))
                fill1.addLine(to: CGPoint(x: 5.65, y: 35.04))
                fill1.addLine(to: CGPoint(x: 58.08, y: 6.09))
                fill1.addLine(to: CGPoint(x: 112.03, y: 35.06))
                fill1.addLine(to: CGPoint(x: 112.03, y: 72.41))
                fill1.close()
                fill1.move(to: CGPoint(x: 59.39, y: 0.34))
                fill1.addCurve(to: CGPoint(x: 56.7, y: 0.35), controlPoint1: CGPoint(x: 58.55, y: -0.12), controlPoint2: CGPoint(x: 57.54, y: -0.11))
                fill1.addLine(to: CGPoint(x: 1.47, y: 30.85))
                fill1.addCurve(to: CGPoint(x: 0, y: 33.35), controlPoint1: CGPoint(x: 0.56, y: 31.35), controlPoint2: CGPoint(x: 0, y: 32.31))
                fill1.addLine(to: CGPoint(x: 0, y: 73.2))
                fill1.addCurve(to: CGPoint(x: 49.07, y: 148.7), controlPoint1: CGPoint(x: 0.03, y: 105.95), controlPoint2: CGPoint(x: 19.29, y: 135.58))
                fill1.addLine(to: CGPoint(x: 56.73, y: 152.07))
                fill1.addCurve(to: CGPoint(x: 58.98, y: 152.07), controlPoint1: CGPoint(x: 57.45, y: 152.38), controlPoint2: CGPoint(x: 58.27, y: 152.38))
                fill1.addLine(to: CGPoint(x: 67.62, y: 148.31))
                fill1.addCurve(to: CGPoint(x: 117.69, y: 72.41), controlPoint1: CGPoint(x: 97.95, y: 135.47), controlPoint2: CGPoint(x: 117.69, y: 105.56))
                fill1.addLine(to: CGPoint(x: 117.69, y: 33.35))
                fill1.addCurve(to: CGPoint(x: 116.19, y: 30.84), controlPoint1: CGPoint(x: 117.69, y: 32.3), controlPoint2: CGPoint(x: 117.11, y: 31.33))
                fill1.addLine(to: CGPoint(x: 59.39, y: 0.34))
                fill1.close()
                context.saveGState()
                context.translateBy(x: 0.04, y: -0)
                fill1.usesEvenOddFillRule = true
                context.saveGState()
                fill1.addClip()
                context.drawLinearGradient(CGGradient(colorsSpace: nil, colors: [
                    UIColor(hue: 0.59, saturation: 0.78, brightness: 0.803, alpha: 1).cgColor,
                    UIColor(hue: 0.59, saturation: 0.364, brightness: 1, alpha: 1).cgColor,
                    ] as CFArray, locations: [0, 1])!,
                                           start: CGPoint(x: 58.84, y: 76.15),
                                           end: CGPoint(x: 58.84, y: 2.79),
                                           options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
                context.restoreGState()
                context.restoreGState()
                
                context.restoreGState()
            }
            
            /// Fill 4
            let fill4 = UIBezierPath()
            fill4.move(to: CGPoint(x: 4.95, y: 11.82))
            fill4.addCurve(to: CGPoint(x: 0.99, y: 11.5), controlPoint1: CGPoint(x: 3.94, y: 10.63), controlPoint2: CGPoint(x: 2.16, y: 10.49))
            fill4.addCurve(to: CGPoint(x: 0.67, y: 15.49), controlPoint1: CGPoint(x: -0.19, y: 12.52), controlPoint2: CGPoint(x: -0.33, y: 14.31))
            fill4.addLine(to: CGPoint(x: 15.51, y: 33.01))
            fill4.addCurve(to: CGPoint(x: 19.41, y: 33.37), controlPoint1: CGPoint(x: 16.5, y: 34.18), controlPoint2: CGPoint(x: 18.23, y: 34.34))
            fill4.addLine(to: CGPoint(x: 53.96, y: 5.03))
            fill4.addCurve(to: CGPoint(x: 54.37, y: 1.04), controlPoint1: CGPoint(x: 55.17, y: 4.04), controlPoint2: CGPoint(x: 55.35, y: 2.26))
            fill4.addCurve(to: CGPoint(x: 50.42, y: 0.64), controlPoint1: CGPoint(x: 53.39, y: -0.17), controlPoint2: CGPoint(x: 51.62, y: -0.35))
            fill4.addLine(to: CGPoint(x: 18, y: 27.23))
            fill4.addLine(to: CGPoint(x: 4.95, y: 11.82))
            fill4.close()
            context.saveGState()
            context.translateBy(x: 32, y: 60)
            fill4.usesEvenOddFillRule = true
            UIColor(hue: 0.59, saturation: 0.674, brightness: 0.886, alpha: 1).setFill()
            fill4.fill()
            context.restoreGState()
            
            context.restoreGState()
        }
        
        context.restoreGState()
    }
    
    //MARK: - Canvas Images
    class func imageOfArtboard() -> UIImage {
        struct LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 118, height: 153), false, 0)
        ConnectedShield.drawArtboard()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        LocalCache.image = image
        return image
    }
    
    //MARK: - Resizing Behavior
    enum ResizingBehavior {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
