//
//  LiveCameraFilteringViewController.swift
//  DSSwipableFilterView
//
//  Created by Darko Spasovski on 11/4/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import UIKit
import AVFoundation

class LiveCameraFilteringViewController: UIViewController {
   
    let filterList = [DSFilter(name: "No Filter", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectMono", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectChrome", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectTransfer", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectInstant", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectNoir", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectProcess", type: .ciFilter),
                      DSFilter(name: "CIPhotoEffectTonal", type: .ciFilter)]
    
    let filterSwipeView = DSSwipableFilterView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Live camera filter"
        prepareFilterView()
        prepareCaptureSession()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func prepareFilterView() {
        
        filterSwipeView.dataSource = self
        filterSwipeView.isUserInteractionEnabled = true
        filterSwipeView.isMultipleTouchEnabled = true
        filterSwipeView.isExclusiveTouch = false
        
        self.view.addSubview(filterSwipeView)
        filterSwipeView.reloadData()
    }
    
    fileprivate func prepareCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        let backCamera = AVCaptureDevice.default(for: .video)
        
        do{
            let input = try AVCaptureDeviceInput(device: backCamera!)
            captureSession.addInput(input)
        }catch{
            print("can't access camera")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(previewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        let serialQueue = DispatchQueue(label: "dsSwipeViewSerial")
        videoOutput.setSampleBufferDelegate(self, queue: serialQueue)
        if captureSession.canAddOutput(videoOutput)
        {
            captureSession.addOutput(videoOutput)
        }
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        captureSession.startRunning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LiveCameraFilteringViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        DispatchQueue.main.async {
            self.filterSwipeView.setRenderImage(image: cameraImage)
        }
    }
}

extension LiveCameraFilteringViewController: DSSwipableFilterViewDataSource {
    
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
