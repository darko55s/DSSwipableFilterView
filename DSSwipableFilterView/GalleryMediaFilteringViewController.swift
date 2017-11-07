//
//  GalleryMediaFilteringViewController.swift
//  DSSwipableFilterView
//
//  Created by Darko Spasovski on 11/4/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class GalleryMediaFilteringViewController: UIViewController {

    let filterList = [DSFilter(name: "No Filter", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectMono", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectChrome", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectTransfer", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectInstant", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectNoir", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectProcess", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectTonal", type: .ciFilter)]
    
    let filterSwipeView = DSSwipableFilterView(frame: UIScreen.main.bounds)

    var player = AVPlayer()
    
    let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])

    var galleryVideoTranform: CGAffineTransform?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gallery media filter"
        prepareFilterView()
        openGallery()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func prepareFilterView() {
        filterSwipeView.dataSource = self
        filterSwipeView.isUserInteractionEnabled = true
        filterSwipeView.isMultipleTouchEnabled = true
        filterSwipeView.isExclusiveTouch = false
        
        self.view.addSubview(filterSwipeView)
        filterSwipeView.reloadData()
    }
    
    fileprivate func openGallery() {
        let mediaPicker = UIImagePickerController()
        mediaPicker.sourceType = .savedPhotosAlbum
        mediaPicker.allowsEditing = false
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(mediaPicker, animated: true, completion: nil)
    }
    
    fileprivate func preview(image: UIImage) {
        let ciImage = CIImage(cgImage: image.cgImage!)
        let fixedImage = ciImage.transformed(by: image.transformToFixImage())
        filterSwipeView.setRenderImage(image: fixedImage)
    }
    
    fileprivate func previewVideoWith(url: URL) {
        galleryVideoTranform = nil

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player.currentItem?.add(videoOutput)
        setTransformFor(item: item)
        player.play()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidReresh(link:)))
        displayLink.add(to: .main, forMode: .commonModes)

    }
    
    fileprivate func setTransformFor(item: AVPlayerItem) {
        var transform = CGAffineTransform.identity
        let videoTracks = item.asset.tracks(withMediaType: .video)
        if videoTracks.count > 0 {
            let track = videoTracks.first!
            transform = track.preferredTransform
            
            if transform.b == 1 && transform.c == -1 {
                transform = transform.rotated(by: CGFloat(Double.pi))
            }
            
            let videoSize = track.naturalSize
            let viewSize = filterSwipeView.frame.size
            let outRect = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height).applying(transform)
            
            let viewIsWide = viewSize.width / viewSize.height > 1
            let videoIsWide = outRect.size.width / outRect.size.height > 1
     
            if viewIsWide != videoIsWide {
                transform = transform.rotated(by: CGFloat(Double.pi/2.0))
            }
        }
        
        galleryVideoTranform = transform
    }
    
    @objc fileprivate func displayLinkDidReresh(link: CADisplayLink) {
        let itemTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
        
        if videoOutput.hasNewPixelBuffer(forItemTime: itemTime) {
            if let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
                let image = CIImage(cvImageBuffer: pixelBuffer)
                if let transform = galleryVideoTranform {
                    let img = image.transformed(by: transform)
                    filterSwipeView.setRenderImage(image: img)
                }
            }
        }
    }

}

extension GalleryMediaFilteringViewController: DSSwipableFilterViewDataSource {
    
    func numberOfFilters(_ filterView: DSSwipableFilterView) -> Int {
        return filterList.count
    }
    
    func filter(_ filterView: DSSwipableFilterView, filterAtIndex index: Int) -> DSFilter {
        return filterList[index]
    }
    
    func startAtIndex(_ filterView: DSSwipableFilterView) -> Int {
        return 0
    }
    
}

extension GalleryMediaFilteringViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let url = info[UIImagePickerControllerMediaURL]
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        picker.dismiss(animated: true, completion:nil)
        
        if mediaType == kUTTypeMovie {
            filterSwipeView.isPlayingLibraryVideo = true
            previewVideoWith(url: url as! URL)
        }else{
            filterSwipeView.isPlayingLibraryVideo = true
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            preview(image: image)
        }
    }
}

