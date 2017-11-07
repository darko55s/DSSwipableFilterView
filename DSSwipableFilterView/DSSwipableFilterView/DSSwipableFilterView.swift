//
//  DSSwipableFilterView.swift
//  TestCameraAUUU
//
//  Created by Darko Spasovski on 10/19/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import UIKit

open class DSSwipableFilterView: UIView {

    
    fileprivate var scrollView: UIScrollView
    fileprivate var numberOfPages: Int
    fileprivate var startingIndex: Int
    fileprivate var currentIndex: Int
    fileprivate var data = [DSFilter]()
    fileprivate var filterView: DSFilterView
    
    open weak var dataSource: DSSwipableFilterViewDataSource?
    
    var isPlayingLibraryVideo = false
    
    fileprivate var lastContentOffset:CGFloat = 0.0
    
    public override init(frame: CGRect) {
        
        numberOfPages = 3
        startingIndex = 0
        currentIndex = 0
        scrollView = UIScrollView(frame: frame)
        filterView = DSFilterView(frame: frame)
        
        super.init(frame: frame)
    
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func reloadData() {
        cleanData()
        loadData()
        presentData()
    }
    
    open func setRenderImage(image: CIImage){
        filterView.setRenderImage(image: isPlayingLibraryVideo ? image.scaleAndResize(forRect: frame, and: contentMode) : image)
    }

    fileprivate func cleanData() {
        currentIndex = 0
        for v in scrollView.subviews {
            v.removeFromSuperview()
        }
        data.removeAll()
    }
    
    fileprivate func loadData() {
        
        numberOfPages = dataSource!.numberOfFilters(self)
        startingIndex = dataSource!.startAtIndex(self)
        scrollView.contentSize = CGSize(width: frame.width*(CGFloat(numberOfPages)), height: frame.height)
        
        for i in 0..<self.numberOfPages {
            let filter = dataSource!.filter(self, filterAtIndex:i)
            data.append(filter)
        }
        
        scrollView.scrollRectToVisible(CGRect(x: positionOfPageAtIndex(startingIndex),y: 0,width: frame.width,height: frame.height), animated:false)
    }
    
    fileprivate func presentData() {

        if data.count >= 2{
            filterView.mainFilter = data[0]
            filterView.partFilter = data[1]
        }
        insertSubview(filterView, belowSubview: scrollView)
        
        for i in 0..<data.count {
            let view = UIView(frame: CGRect(x: positionOfPageAtIndex(i), y: 0, width: frame.width, height: frame.height))
            view.backgroundColor = UIColor.clear
            scrollView.addSubview(view)
        }
    }
    
    fileprivate func positionOfPageAtIndex(_ index: Int) -> CGFloat {
        return frame.size.width*CGFloat(index)
    }
    
}

extension DSSwipableFilterView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            scrollView.isUserInteractionEnabled = false
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.frame.width)
        let newPosition = fabs(scrollView.contentOffset.x - (CGFloat(index)*scrollView.frame.width))
        
        let x = scrollView.frame.width - newPosition
        
        if filterView.scrollViewDirection == .steady {
            if x > scrollView.frame.width/2.0 {
                filterView.scrollViewDirection = .forward
            }else{
                filterView.scrollViewDirection = .backward
            }
        }
        
        filterView.mainFilter = data[currentIndex]
        
        if index < currentIndex {
            filterView.partFilter = data[currentIndex-1]
        }else if index > currentIndex {
            filterView.partFilter = data[currentIndex+1]
        }else{
            if (index+1) < data.count {
                filterView.partFilter = data[index+1]
            }
        }
        
        filterView.setNewFilterPosition(x: x)
        filterView.setNeedsDisplay()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.frame.width)
        
        filterView.scrollViewDirection = .steady
        if currentIndex != index {
            filterView.mainFilter = filterView.partFilter
            filterView.setNeedsDisplay()
        }
        filterView.setNeedsDisplay()
        
        currentIndex = index
        
        scrollView.isUserInteractionEnabled = true
    }
}



