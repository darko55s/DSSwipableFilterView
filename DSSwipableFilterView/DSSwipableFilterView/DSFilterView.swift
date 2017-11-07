//
//  DSFilterView.swift
//  TestCameraAUUU
//
//  Created by Darko Spasovski on 10/19/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import Foundation
import GLKit
import CoreImage

enum ScrollingDirection{
    case forward
    case backward
    case steady
}

class DSFilterView: GLKView {
    
    fileprivate var newFilterPosition: CGFloat = 0.0
    fileprivate var image: CIImage?
    fileprivate var ciContext: CIContext?
    
    fileprivate var lastPosition = 0.0

    var scrollViewDirection:ScrollingDirection = .steady
    var mainFilter: DSFilter!
    var partFilter: DSFilter!
    
    override init(frame: CGRect){
        super.init(frame: frame, context: EAGLContext(api: .openGLES2)!)
        EAGLContext.setCurrent(self.context)
        self.ciContext = CIContext(eaglContext: self.context)
        self.mainFilter = DSFilter(name: "No Filter")
        self.partFilter = DSFilter(name: "No Filter")
        self.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self.context = EAGLContext(api: .openGLES2)!
        EAGLContext.setCurrent(self.context)
        self.ciContext = CIContext(eaglContext: self.context)
        self.contentMode = .scaleAspectFit
    }
    
    func setRenderImage(image: CIImage){
        self.image = image
        setNeedsDisplay()
    }
    
    func setNewFilterPosition(x: CGFloat) {
        lastPosition = Double(newFilterPosition)
        newFilterPosition = x
    }
    
    func getComposedImageOf(sourceImage: CIImage, overImage: CIImage, cropRect: CGRect) -> CIImage {
        let cropedSecond = sourceImage.cropped(to: cropRect)
        let output = cropedSecond.composited(over: overImage)
        return output
    }
    
    func getFilteredCapturedImage() -> UIImage {
        if let capturedImage = self.image {
            let cgImage = ciContext?.createCGImage(mainFilter.filter(image: capturedImage), from: capturedImage.extent)
            if let image = cgImage {
                return UIImage(cgImage: image);
            }
        }
        return UIImage()
    }

    override func draw(_ rect: CGRect){
        
        let scale = UIScreen.main.scale
        let newFrame = CGRect(x: rect.minX, y: rect.minY, width: rect.width * scale, height: rect.height * scale)
        
        if let image = image{
            
            let filterOneFrame = (newFrame.width - (CGFloat(newFilterPosition) * scale)) * (image.extent.width/newFrame.width)
            let lastOneFrame = (newFrame.width - (CGFloat(lastPosition) * scale)) * (image.extent.width/newFrame.width)
            let cropRect = CGRect(x: (image.extent.width - filterOneFrame), y: 0, width:image.extent.width, height: image.extent.height)
            
            if scrollViewDirection == .forward {
                if filterOneFrame == 0.0 && lastOneFrame >= (image.extent.width - 10){
                    ciContext?.draw(self.partFilter.filter(image: image), in: newFrame, from: image.extent)
                }else if filterOneFrame == 0.0 && lastOneFrame < 15{
                    ciContext?.draw(self.mainFilter.filter(image: image), in: newFrame, from: image.extent)
                }else{
                    ciContext?.draw(getComposedImageOf(sourceImage: self.partFilter.filter(image: image), overImage: self.mainFilter.filter(image: image), cropRect: cropRect), in: newFrame, from: image.extent)
                }
            }else if scrollViewDirection == .backward{
                if filterOneFrame == 0.0 && lastOneFrame < 15 {
                    ciContext?.draw(self.partFilter.filter(image: image), in: newFrame, from: image.extent)
                }else if filterOneFrame == 0.0 && lastOneFrame >= (image.extent.width - 10) {
                    ciContext?.draw(self.mainFilter.filter(image: image), in: newFrame, from: image.extent)
                }else {
                    ciContext?.draw(getComposedImageOf(sourceImage: self.mainFilter.filter(image: image), overImage: self.partFilter.filter(image: image), cropRect: cropRect), in: newFrame, from: image.extent)
                }
            }else if scrollViewDirection == .steady {
                ciContext?.draw(self.mainFilter.filter(image: image), in: newFrame, from: image.extent)
            }
        }
    }
}
