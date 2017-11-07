//
//  UIImage+Transform.swift
//  DSSwipableFilterView
//
//  Created by Darko Spasovski on 11/4/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import UIKit

extension UIImage {
    func transformToFixImage() -> CGAffineTransform {
        if imageOrientation == .up {
            return .identity
        }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            break
        case .up, .upMirrored:
            break;
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .up, .down, .left, .right:
            break
        }
        
        return transform
    }
}


extension CIImage {
    
    func scaleAndResize(forRect rect: CGRect, and contentMode: UIViewContentMode) -> CIImage {
        
        let imageSize = extent.size
        
        var horizontalScale = rect.size.width / imageSize.width
        var verticalScale = rect.size.height / imageSize.height
        
        let mode = contentMode
        
        if mode == .scaleAspectFill {
            horizontalScale = max(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        }else if mode == .scaleAspectFit {
            horizontalScale = max(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        }
        
        return transformed(by: CGAffineTransform(scaleX: horizontalScale, y: verticalScale))
    }
}
