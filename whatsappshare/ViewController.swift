//
//  ViewController.swift
//  KiXrArVr
//
//  Created by Sandeep M on 10/12/19.
//  Copyright © 2019 Kiksar. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController,AVCapturePhotoCaptureDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var txtF: UITextField!
    @IBOutlet weak var shrTxtBtn: UIButton!
    
    @IBOutlet weak var preView: UIImageView!
       @IBOutlet weak var imgV: UIImageView!
       var captureSession: AVCaptureSession!
       var stillImageOutput: AVCapturePhotoOutput!
       var videoPreviewLayer: AVCaptureVideoPreviewLayer!
      var imagePicker: UIImagePickerController!
        var isHiddenImg = false
        var documentInteractionController:UIDocumentInteractionController!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgV.isHidden = true
        saveBtn.isHidden = true
        shrTxtBtn.isHidden = true
    }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            // Setup your camera here...
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .medium

            let newcam = AVCaptureDevice.devices(for: AVMediaType.video)
            for deviceFront in newcam {
                if let device = deviceFront as? AVCaptureDevice {
                    if device.position == AVCaptureDevice.Position.front {
                        do {
                              let input = try AVCaptureDeviceInput(device: device)
                              //Step 9
                              stillImageOutput = AVCapturePhotoOutput()

                              if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                                  captureSession.addInput(input)
                                  captureSession.addOutput(stillImageOutput)
                                  setupLivePreview()
                              }
                          }
                          catch let error  {
                              print("Error Unable to initialize front camera:  \(error.localizedDescription)")
                          }
                        break
                    }
                }
            }

        }
        func setupLivePreview() {
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            videoPreviewLayer.videoGravity = .resizeAspect
            videoPreviewLayer.connection?.videoOrientation = .portrait
            preView.layer.addSublayer(videoPreviewLayer)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.videoPreviewLayer.frame = self.preView.bounds
                }
            }
        }
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
            guard let imageData = photo.fileDataRepresentation()
                else { return }
            
            let image = UIImage(data: imageData)
            
            imgV.image = image
        }
        
    @IBAction func saveIMG(_ sender: Any) {
        
                    addImageSign()
                   let renderer = UIGraphicsImageRenderer(size: imgV.frame.size)
                   let image = renderer.image(actions: { context in
                              imgV.layer.render(in: context.cgContext)
                   })

               UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func doShareAct(_ sender: Any) {
            addImageSign()
//        forTextShare()
            forTxtNImg()
//        forImageShare()
        }
    
      @IBAction func doShareTxtAct(_ sender: Any) {
            forTextShare()
            }
    
    func forTxtNImg() {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
               if let whatsappURL = NSURL(string: urlString) {
                   if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    if let image = imgV.image {
                           if let imageData = image.jpegData(compressionQuality: 0.75) {
                               let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/abc.wai")

                               do {
                                   try imageData.write(to: tempFile!, options: .atomicWrite)
                                   self.documentInteractionController = UIDocumentInteractionController(url: tempFile!)
                                   self.documentInteractionController.uti = "net.whatsapp.image"
                                   self.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                                
                               } catch {
                                   print(error)
                               }
                           }
                       }
                   } else {
                       print("please install watsapp")
                    alertMSG(title:"Error",msg:"first Please install whatsdapp")

                   }
               }
           }
    }
    
    
    func forImageShare() {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
               if let whatsappURL = NSURL(string: urlString) {
                   if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    if let image = imgV.image {
                           if let imageData = image.jpegData(compressionQuality: 0.75) {
                               let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/abc.wai")

                               do {
                                   try imageData.write(to: tempFile!, options: .atomicWrite)
                                   self.documentInteractionController = UIDocumentInteractionController(url: tempFile!)
                                   self.documentInteractionController.uti = "net.whatsapp.image"
                                   self.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                                
                               } catch {
                                   print(error)
                               }
                           }
                       }
                   } else {
                       print("please install watsapp")
                    alertMSG(title:"Error",msg:"first Please install whatsdapp")

                   }
               }
           }
    }
    func forTextShare() {
                    let msg = txtF.text!
                    let urlWhats = "whatsapp://send?text=\(msg)"
                    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                        if let whatsappURL = NSURL(string: urlString) {
                            if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                                UIApplication.shared.openURL(whatsappURL as URL)
                            } else {
                                print("please install watsapp")
                                alertMSG(title:"Error",msg:"first Please install whatsdapp")
                            }
                        }
                    }

    }
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            alertMSG(title:"Saved",msg:"Your altered image has been saved to your photos.")

           
        }
    }
    
    @IBAction func openCamera(_ sender: Any) {
//            CaptureImageCamera()
            if !isHiddenImg {
            imgV.isHidden = false
                
                isHiddenImg = true
                captureBtn.setTitle("Retake pic", for: .normal)
                saveBtn.isHidden = false

                CaptureImageCamera()
                addImageSign()
                
            } else {
            imgV.isHidden = true
                isHiddenImg = false
                saveBtn.isHidden = true

                captureBtn.setTitle("Take a Pic", for: .normal)
                

            }

            
            
        }
 
    
    func addImageSign(){
        let imageView = UIImageView()
                      imageView.image =  #imageLiteral(resourceName: "abc")
                      imageView.frame = CGRect(x: imgV.frame.width-175, y: imgV.frame.height-45, width: 170, height: 25)
                      imgV.addSubview(imageView)
    }
    func alertMSG(title:String,msg:String) {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
               ac.addAction(UIAlertAction(title: "OK", style: .default))
               present(ac, animated: true)
    }
    func CaptureImageCamera()  {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                 stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.captureSession.stopRunning()
        }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        shrTxtBtn.isHidden = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
}

