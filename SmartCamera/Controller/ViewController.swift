//
//  ViewController.swift
//  SmartCamera
//
//  Created by Cheong Chern Sian on 29/01/2019.
//  Copyright © 2019 Cheong Chern Sian. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var object: UILabel!
    var object1:String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        //Start up camera
        //from more details visit: https://www.letsbuildthatapp.com/course_video?id=1252
        
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.sessionPreset = .photo
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue "))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())
        guard let pixleBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            //perhaps check the error
//            print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier)
            let abc = (firstObservation.identifier)
            DispatchQueue.main.async { // Correct
                self.object.text = abc
            }
        }
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixleBuffer, options: [:]).perform([request])
    }
 

}

