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
    var currentParty: pCell!
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    var device = AVCaptureDevice.default(for: AVMediaType.video)
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    var code: String = ""
    var isVerified: Bool = false
    var scannedCode = UILabel()
    var currentRow: Int!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
        self.addLabelForDisplayingCode()
        let right = UISwipeGestureRecognizer(target: self, action: #selector(doneAction))
        right.direction = .right
        self.view.addGestureRecognizer(right)
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
    @objc func doneAction(sender: UISwipeGestureRecognizer){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let partyView = storyboard.instantiateViewController(withIdentifier: "InduvidualPartyViewController") as! InduvidualPartyViewController
        self.present(partyView, animated: false)

        partyView.partyInfo = currentParty
        partyView.currentRow = self.currentRow
        partyView.PartyDate.text = currentParty.date
        partyView.PartyImage.image = currentParty.image
        partyView.PartyDescription.text = currentParty.partyDescription
        partyView.PartyLocation.text = currentParty.partyAddress
        partyView.PartyNameLabel.text = currentParty.partyName
        
        if(currentParty.startMinute < 10){
            partyView.PartyStartTime.text = "Start Time:" + String(currentParty.startHour) + ":0" + String(currentParty.startMinute)
        }
        else{
            partyView.PartyStartTime.text = "Start Time:" + String(currentParty.startHour) + ":" + String(currentParty.startMinute)
            
        }
        if(currentParty.endMinute < 10){
            partyView.PartyEndTime.text = "Start Time:" + String(currentParty.endHour) + ":0" + String(currentParty.endMinute)
        }
        else{
            partyView.PartyStartTime.text = "Start Time:" + String(currentParty.endHour) + ":" + String(currentParty.endMinute)
            
        }
    }
    private func addLabelForDisplayingCode() {
        
        view.addSubview(scannedCode)
       
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
        db.collection("RSVP").document(currentParty.documentID).collection("Invitees").getDocuments{ (querySnapshot,error) in
            var flag = true
            for document in (querySnapshot?.documents)!{
                print(document.documentID)
                print(self.code)
                print("QR Verified")
                if(document.documentID == self.code ){
                    self.scannedCode.text = "Verified"
                    flag = false
                    self.isVerified = true
                    db.collection("checkedIn").document(self.currentParty.documentID).collection("Invitees").document(self.code).setData(["checkedInBy" : ""])
                }
                print(self.code)
                print(document.documentID)
            }
            if(flag){
            self.scannedCode.text = "Not Verified"
            }

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
