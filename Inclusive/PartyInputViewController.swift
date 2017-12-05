//
//  PartyInputViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/30/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
class PartyInputViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var MessageInput: UITextView!
    
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
        StartTimePicker.datePickerMode = .time
        EndTimePicker.datePickerMode = .time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        Date = dateFormatter.string(from: StartDatePicker.date)
        EndTime = EndTimePicker.date
        StartTime = StartTimePicker.date
     
        

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
