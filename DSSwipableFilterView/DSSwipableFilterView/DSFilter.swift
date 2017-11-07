//
//  DSFilter.swift
//  TestCameraAUUU
//
//  Created by Darko Spasovski on 10/19/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import UIKit
import CoreImage

public enum FilterType {
    case ciFilter
    case combinedFilter
    case locationFilter
}

public enum LocationFilterType {
    case none
    case country
    case city
}

open class DSFilter {

    fileprivate var name:String?
    fileprivate var filter: CIFilter?
    fileprivate var combinedFilters: [CIFilter] = [CIFilter]()
    
    var type: FilterType = .ciFilter
    var locationType: LocationFilterType = .none
    
    public init(name: String, filter: CIFilter){
        self.name = filter.name
        self.filter = filter
    }
    
    public init(name: String, filter: CIFilter, type: FilterType){
        self.name = name
        self.filter = filter
        self.type = type
    }
    
    public init(text: String, locationType: LocationFilterType){
        self.name = text
        self.type = .locationFilter
        self.locationType = locationType
    }
    
    public init(name: String, type: FilterType){
        self.name = name
        self.type = type
        if name != "No Filter" {
            filter = CIFilter(name: name)
            filter!.setDefaults()
        }
    }
    
    public init(combinedFilter: [CIFilter]){
        self.name = "Combined"
        self.combinedFilters = combinedFilter
        self.type = .combinedFilter
    }
    
    public init(name: String) {
        self.name = name
        
        if name != "No Filter" {
            filter = CIFilter(name: name)
            filter!.setDefaults()
        }
    }
    
    open func getName() -> String {
        return name!
    }

    open func getFilter() -> CIFilter? {
        return filter
    }
    
    open func filter(image: CIImage) -> CIImage {
        switch type {
        case .ciFilter:
            return filterOne(image:image)
        case .combinedFilter:
            return combineFiltersOn(image: image)
        case .locationFilter:
            return image
        }
    }
    
    fileprivate func combineFiltersOn(image: CIImage) -> CIImage{
        let firstFilter = combinedFilters.first!
        firstFilter.setValue(image, forKey: kCIInputImageKey)
        let firstImage = firstFilter.value(forKey: kCIOutputImageKey) as! CIImage
      
        let secondFilter = combinedFilters.last!
        secondFilter.setValue(firstImage, forKey: kCIInputImageKey)
        let secondImage = secondFilter.value(forKey: kCIOutputImageKey) as! CIImage
        
        return secondImage
    }
    
    fileprivate func filterOne(image: CIImage) -> CIImage {
        if name == "No Filter" {
            return image
        }
        filter!.setValue(image, forKey: kCIInputImageKey)
        let filteredImage = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        return filteredImage
    }
    
    
}
