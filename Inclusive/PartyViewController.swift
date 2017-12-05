//
//  PartyViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/25/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FBSDKLoginKit
import FacebookCore
import FirebaseFirestore
var isInviteMode: Bool = false
var currentDocument: String = ""
struct pCell{
    var partyName: String;
    var partyAddress: String;
    var partyDescription: String;
    var documentID: String;
    var startHour: Int;
    var startMinute: Int;
    var endHour: Int;
    var endMinute: Int;
    var date: String;
    var isBouncer: Bool;
    var image: UIImage;

    
}
var storeItems:[pCell] = []
class PartyViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate {
    var InputPopover: PartyInputViewController!
    var datepicker: UIDatePicker = UIDatePicker()
    @IBOutlet weak var PartyBar: UIToolbar!
    var items: [pCell] = []
    @IBOutlet weak var TableView: UITableView!
    @IBAction func AddPartyButtonAction(_ sender: Any) {
        presentAndRecordInput(act:0, send: 0)
    }
    func presentAndRecordInput(act: Int, send: Int){
      
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
     
        InputPopover = storyboard.instantiateViewController(withIdentifier: "PartyInput") as! PartyInputViewController
        InputPopover.modalPresentationStyle = .popover
        let popover = InputPopover.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .up
        if(act == 1){
            present(InputPopover, animated: true, completion: nil)

        var cell = items[send]
        InputPopover.NameInput.text = cell.partyName
        InputPopover.InviteInput.text = cell.partyDescription
        InputPopover.LocationInput.text = cell.partyAddress
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "mm dd yyyy"
            let date = dateFormatter.date(from: cell.date)
            var calendar = Calendar(identifier: .gregorian)
            var components = DateComponents(year: 2017, month:1, day: 1, hour: cell.startHour, minute: cell.startMinute, second: 00)
            let startTime = calendar.date(from: components)!
            components = DateComponents(year: 2017, month:1, day: 1, hour: cell.endHour, minute: cell.endMinute, second: 00)
            let endTime = calendar.date(from: components)!
            

            InputPopover.StartDatePicker.date = startTime
            InputPopover.EndTimePicker.date = endTime
            InputPopover.PartyImageView.image = cell.image
        InputPopover.isInitial = false
        InputPopover.currentRow = send
        return
        }
        present(InputPopover, animated: true, completion: nil)

       

    }

    @objc func doneActionForEdit(sender: UIButton){
       
        self.TableView.reloadData()
    

    }
  
    @objc
    func editTapped(sender: UIButton){
        presentAndRecordInput(act:1, send: sender.tag)
    }
    @objc
    func verifyTapped(sender: UIButton){
      
        
        let nextViewController = VerifyViewController()
        nextViewController.currentParty = items[sender.tag].documentID
        self.present(nextViewController, animated:true, completion:nil)
    }
    @objc
    func inviteTapped(sender: UIButton){
        isInviteMode = true
        currentDocument = items[sender.tag].documentID
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 175.0;//Your custom row height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
   func numberOfSections(in TableView: UITableView) -> Int{
        return 1
    }

    
    func tableView(_ TableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "cell") as! PartyCell

        let currentCell = items[indexPath.row]
        if(currentCell.isBouncer){
           //different cell
        }
        else{
        print(currentCell)
        cell.PartyName.text = currentCell.partyName
        cell.Location.text = currentCell.partyAddress
        cell.Location.allowsEditingTextAttributes = false
        cell.EditParty.addTarget(self, action:#selector(editTapped), for: UIControlEvents.touchUpInside)
            cell.VerifyParty.tag = indexPath.row
            cell.VerifyParty.addTarget(self, action:#selector(verifyTapped), for: UIControlEvents.touchUpInside)
         cell.Invite.addTarget(self, action:#selector(inviteTapped), for: UIControlEvents.touchUpInside)
        cell.EditParty.tag = indexPath.row
        cell.VerifyParty.tag = indexPath.row
        cell.Invite.tag = indexPath.row

        cell.PartyImage.image = currentCell.image

        cell.StartDate.text = currentCell.date
        //if is not active
        print(currentCell.startMinute)
        print(currentCell.startHour)
        if(currentCell.startMinute < 10){
            cell.StartTimeEndTime.text = "Start Time:" + String(currentCell.startHour) + ":0" + String(currentCell.startMinute)
        }
        else{
            cell.StartTimeEndTime.text = "Start Time:" + String(currentCell.startHour) + ":" + String(currentCell.startMinute)

        }
        //else is not active
        //end time
    cell.AddBouncers.addTarget(self,action:#selector(addBouncers), for: UIControlEvents.touchUpInside)
        cell.AddBouncers.tag = indexPath.row
        }
        return cell as UITableViewCell;

    }
    @objc func addBouncers(sender: UIButton){
        isInviteMode = false
        currentDocument = items[sender.tag].documentID
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func ManualLogout(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        items = storeItems
        if(items.count != 0){
            TableView.dataSource = self
            TableView.reloadData()
            print("storeItems used")
        }
        else{
    TableView.dataSource = self
        TableView.reloadData()
   // db.collection("Host/"+Auth.auth().currentUser!.uid).getDocuments(completion: )
    db.collection("Hosts").document(FBSDKAccessToken.current().userID).collection("Party").getDocuments(){(querySnapshot, err) in
        print("quering hosts")
        //should also query bouncers here or after
        //bouncers should have isBouncer true and this will signal to not initialize certain values in the cells
    if let err = err {
        print(err)
    
    }else{
        for document in querySnapshot!.documents{
            print(document)
              db.collection("Parties").document(document.documentID).getDocument{ (document,error) in
                print(error)
                let description = document?.data()["Description"] as! String
                let name = document?.data()["Name"] as! String
                let location = document?.data()["Location"] as! String
                let date = document?.data()["date"] as! String
                let startMinute = document?.data()["startMinute"] as! Int
                let startHour = document?.data()["startHour"] as! Int
                let endMinute = document?.data()["endMinute"] as! Int
                let endHour = document?.data()["endHour"] as! Int
                let imageURL:String = (document?.documentID)! + ".png"
                let pathReference = storage.reference(withPath: "PartyImages/"+imageURL)
                pathReference.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print("broken")

                        print(error)
                    } else {
                        
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.items.append(pCell(partyName: name, partyAddress: location, partyDescription: description,documentID: document?.documentID as! String, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, date: date, isBouncer: false, image: image!))
                        storeItems.append(pCell(partyName: name, partyAddress: location, partyDescription: description,documentID: document?.documentID as! String, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, date: date, isBouncer: false, image: image!))
                        self.TableView.reloadData()
                        
                    }
                }
                
            }
            
        }
    }
        //write query to get parties for bouncers 

    
        }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
