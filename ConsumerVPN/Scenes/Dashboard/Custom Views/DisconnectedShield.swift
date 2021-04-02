//
//  DisconnectedShield.swift
//  ConsumerVPN
//
//  Copyright © 2020 NetProtect. All rights reserved.
//

import UIKit

class DisconnectedShield: NSObject {
    //MARK: - Canvas Drawings
	class func drawArtboard(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 118, height: 153), resizing: ResizingBehavior = .aspectFit) {

		if Theme.drawCustomShield {
			DisconnectedShield.drawCustom()
			return
		}
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
		DisconnectedShield.drawArtboard()
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
