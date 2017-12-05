//
//  VerifyViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/26/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
class VerifyViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
   


    // MARK: - QRCodeReaderViewController Delegate Methods
    var currentParty: String!
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    var device = AVCaptureDevice.default(for: AVMediaType.video)
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    var code: String = ""
    var isVerified: Bool = false
    var scannedCode = UILabel()

 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
        self.addLabelForDisplayingCode()
        // Do any additional setup after loading the view.
    }
    private func setupCamera() {
        print("setupCamera")
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if self.captureSession.canAddInput(input!) {
            self.captureSession.addInput(input!)
        }
        else{
            print("can't add input")
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = self.view.bounds
            view.layer.addSublayer(videoPreviewLayer)
        }
        else{
            print("no video layer")
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [ AVMetadataObject.ObjectType.qr]
            
        } else {
            print("Could not add metadata output")
        }
    }
    @objc func doneAction(sender: UIButton){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let party = storyboard.instantiateViewController(withIdentifier: "PartyViewController") as! UIViewController
        self.present(party, animated: false)
    }
    private func addLabelForDisplayingCode() {
        
        view.addSubview(scannedCode)
        let done = UIButton()
        done.titleLabel?.text = "Done"
        done.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        view.addSubview(done)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        done.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        done.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        scannedCode.translatesAutoresizingMaskIntoConstraints = false
        scannedCode.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0).isActive = true
        scannedCode.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        scannedCode.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        scannedCode.heightAnchor.constraint(equalToConstant: 100).isActive = true
        scannedCode.font = UIFont.preferredFont(forTextStyle: .title2)
        scannedCode.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scannedCode.textAlignment = .center
        scannedCode.textColor = UIColor.white
        scannedCode.text = "Scanning...."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view appeared")
        if (captureSession.isRunning == false) {
            captureSession.startRunning();
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("shit")
        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
    }
   func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        // This is the delegate'smethod that is called when a code is readed

    for metadata in metadataObjects {

        let readableObject = metadata as! AVMetadataMachineReadableCodeObject
        if(readableObject.stringValue! != code){
            self.scannedCode.text = "Checking"

            code = readableObject.stringValue!
        print(code)
        print("code")
        db.collection("invitedTo").document(currentParty).collection("Invitees").getDocuments{ (querySnapshot,error) in
            for document in (querySnapshot?.documents)!{
                print(document.documentID)
                print(self.code)
                print("QR Verified")
                if(document.documentID == self.code ){
                    self.scannedCode.text = "Verified"
                    self.isVerified = true
                }
            }
            self.scannedCode.text = "Not Verified"

        }
        //insert some logic that checks from database and put a check mark for verify
    }
    }

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
