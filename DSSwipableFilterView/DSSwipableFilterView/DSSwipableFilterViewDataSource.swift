//
//  DSSwipableFilterViewDataSourec.swift
//  TestCameraAUUU
//
//  Created by Darko Spasovski on 10/19/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import Foundation
import UIKit


public protocol DSSwipableFilterViewDataSource : class {
    
    func numberOfFilters(_ filterView: DSSwipableFilterView) -> Int
    
    func filter(_ filterView: DSSwipableFilterView, filterAtIndex index: Int) -> DSFilter
    
    func startAtIndex(_ filterView: DSSwipableFilterView) -> Int
}
