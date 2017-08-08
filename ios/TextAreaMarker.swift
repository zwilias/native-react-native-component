//
//  TextAreaMarker.swift
//  FindText
//
//  Created by Ilias Van Peer on 8/7/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision

@objc(TextAreaMarker)
class TextAreaMarkerView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
  let boxes = CAShapeLayer()
  let session = AVCaptureSession()
  var request: VNDetectTextRectanglesRequest?
  let handler = VNSequenceRequestHandler()
  var buffer: CVPixelBuffer?
  var previewLayer: AVCaptureVideoPreviewLayer?

  override init(frame: CGRect) {
    super.init( frame: frame)
    self.start()
  }

  init() {
    super.init(frame: CGRect())
    self.start()
  }

  func start() {
    self.request = VNDetectTextRectanglesRequest(completionHandler: self.requestHandler)
    self.request?.reportCharacterBoxes = true

    do {
      if let dualCameraDevice = AVCaptureDevice.default(for: AVMediaType.video) {
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high

        let videoDeviceInput = try AVCaptureDeviceInput(device: dualCameraDevice)
        let outputData = AVCaptureVideoDataOutput()
        let captureSessionQueue = DispatchQueue(label: "CameraSessionQueue", attributes: [])
        outputData.setSampleBufferDelegate(self, queue: captureSessionQueue)

        session.addInput(videoDeviceInput)
        session.addOutput(outputData)
        session.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)

        boxes.opacity = 0.5
        boxes.lineWidth = 2
        boxes.lineJoin = kCALineJoinMiter
        boxes.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: 0.53, alpha: 1.0).cgColor
        boxes.fillColor = UIColor(hue: 0.786, saturation: 0.15, brightness: 0.89, alpha: 1.0).cgColor

        self.layer.addSublayer(previewLayer!)
        self.layer.addSublayer(self.boxes)

        session.startRunning()
      }
    } catch {
      print("failed - \(error)")
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    previewLayer?.frame = self.frame
  }

  func requestHandler(request: VNRequest, error: Error?) {
    guard let observations = request.results as? [VNTextObservation] else { return }

    DispatchQueue.main.async {
      let width = self.frame.width
      let height = self.frame.height

      let mPath = UIBezierPath()

      for o in observations {
        for box in o.characterBoxes ?? [] {
          mPath.append(self.drawBox(box, width: width, height: height))
        }
      }

      self.boxes.path = mPath.cgPath
      self.boxes.displayIfNeeded()
    }
  }

  func drawBox(_ box: VNRectangleObservation, width: CGFloat, height: CGFloat) -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: toPoint(box.bottomLeft, width: width, height: height))
    path.addLine(to: toPoint(box.topLeft, width: width, height: height))
    path.addLine(to: toPoint(box.topRight, width: width, height: height))
    path.addLine(to: toPoint(box.bottomRight, width: width, height: height))
    path.close()

    return path
  }

  func toPoint(_ point: CGPoint, width: CGFloat, height: CGFloat) -> CGPoint {
    return CGPoint(
      x: point.y * (width),
      y: point.x * (height)
    )
  }

  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
    ) {
    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    self.buffer = pixelBuffer
    _ = try? self.handler.perform([self.request!], on: pixelBuffer!)
  }
}
