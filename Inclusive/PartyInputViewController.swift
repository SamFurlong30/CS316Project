//
//  PartyInputViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/30/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
import FirebaseStorage
import FBSDKCoreKit

class PartyInputViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let imagePicker = UIImagePickerController()
    var isInitial: Bool = true
    var currentRow: Int = 0
    var currentCell: pCell!
    var doneTransition: (()->Void)?
    var invites:Int!
    var checkIns:Int!
    var RSVPs:Int!
    
    
    
@IBAction func AddLocation(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(nextViewController, animated:true, completion:nil)
        nextViewController.complete = {
            if let myString = nextViewController.pointAnnotation?.title {
                self.LocationInput.text = myString
                print("setLocationInput")
            }
            print("no location")
        
    }
    
    }
    @IBAction func DoneAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: doneTransition)

        var nCell: pCell

        EndTime = EndTimePicker.date
        StartTime = StartTimePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        Date = dateFormatter.string(from: StartDatePicker.date)
        if(isInitial){
        let name:String = self.NameInput.text!
           
        let starDate = self.Date
        let endTime = self.EndTime
        let components = Calendar.current.dateComponents([.hour, .minute], from: endTime!)
            print(endTime)

        let endhour = components.hour
        let endminute =  components.minute
        let startTime = self.StartTime
            print(startTime)

        let componentA = Calendar.current.dateComponents([.hour, .minute], from: startTime!)
        let starthour = componentA.hour
        let startminute = componentA.minute
        let partyImage:UIImage = self.PartyImageView.image!
        let location:String = self.LocationInput.text!
        let desc:String = self.InviteInput.text!
            nCell = pCell(partyName: name, partyAddress: location, partyDescription: desc, documentID: "", startHour: starthour!, startMinute: startminute!, endHour: endhour!, endMinute: endminute!,  date: starDate!, isBouncer: false, image: self.PartyImageView.image!, isStale: false, isActive: false, isCoHost: false)
        let ref = db.collection("Hosts").document(FBSDKAccessToken.current().userID).collection("Party").addDocument(data: ["hostType":"Owner"])
        let did = ref.documentID
            db.collection("Parties").document(did).setData(["Name": nCell.partyName, "Location":nCell.partyAddress, "Description" : nCell.partyDescription, "startMinute": startminute, "startHour":starthour, "endMinute":endminute, "endHour": endhour, "date": starDate, "numInvites": 0, "numRsvps": 0, "numCheckedIn": 0])
        let storageRef = storage.reference().child("PartyImages").child(did + ".png")
        
        if let imageData = UIImagePNGRepresentation(partyImage) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/PNG"
            print("trying to upload")
            let uploadTask = storageRef.putData(imageData, metadata: metadata, completion:{ (metadata, error) in
                print("succeeded")
    
            })
            nCell.documentID = did
            storeItems.append(nCell)
        }
}
        
        else{
            let name:String = self.NameInput.text!
            let starDate = self.Date
            
            let endTime = self.EndTime
            print(endTime)
            let components = Calendar.current.dateComponents([.hour, .minute], from: endTime!)
            let endhour = components.hour
            print(endhour)
            let endminute =  components.minute
            print(endminute)
            let startTime = self.StartTime
            let componentA = Calendar.current.dateComponents([.hour, .minute], from: startTime!)
            let starthour = componentA.hour
            print(starthour)
            let startminute = componentA.minute
            print(startminute)
            let partyImage:UIImage = self.PartyImageView.image!
            let location:String = self.LocationInput.text!
            let desc:String = self.InviteInput.text!
            nCell = pCell(partyName: name, partyAddress: location, partyDescription: desc, documentID: "", startHour: starthour!, startMinute: startminute!, endHour: endhour!, endMinute: endminute!,  date: starDate!, isBouncer: false, image:self.PartyImageView.image!, isStale: false, isActive: false, isCoHost: false)
            let did = storeItems[currentRow].documentID
            db.collection("Parties").document(currentCell.documentID).setData(["Name": nCell.partyName, "Location":nCell.partyAddress, "Description" : nCell.partyDescription, "startMinute": startminute, "startHour":starthour, "endMinute":endminute, "endHour": endhour, "date": starDate, "numInvites":self.invites, "numRsvps": self.RSVPs, "numCheckedIn":self.checkIns])
            let storageRef = storage.reference().child("PartyImages").child(did + ".png")
            
            if let imageData = UIImagePNGRepresentation(partyImage) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/PNG"
                print("trying to upload")
                let uploadTask = storageRef.putData(imageData, metadata: metadata, completion:{ (metadata, error) in
                    print("succeeded")
                    
                    
                })
        storeItems.remove(at: currentRow)
            storeItems.append(nCell)
        

        }
}
            currentCell = nCell

    
        
}
    @IBOutlet weak var LocationInput: UITextField!
  
   
    @IBAction func PartyImageAction(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var PartyImageView: UIImageView!
    var StartTime:Date!
    var EndTime:Date!
    var Date:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        StartDatePicker.datePickerMode = .date
        StartDatePicker.setValue(UIColor.green, forKeyPath: "textColor")

        StartTimePicker.datePickerMode = .time
        EndTimePicker.datePickerMode = .time
        StartTimePicker.setValue(UIColor.green, forKeyPath: "textColor")
        EndTimePicker.setValue(UIColor.green, forKeyPath: "textColor")
        
        

        // Do any additional setup after loading the view.
    }

  
    @IBOutlet weak var StartDatePicker: UIDatePicker!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var StartTimePicker: UIDatePicker!
    @IBOutlet weak var EndTimePicker: UIDatePicker!
    @IBOutlet weak var NameInput: UITextField!
    
    @IBOutlet weak var InviteInput: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [String : Any]){
    PartyImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    
    dismiss(animated: true, completion: nil)
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
