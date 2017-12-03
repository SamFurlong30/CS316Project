//
//  PartyViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/25/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
import FirebaseAuth
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

    
}
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
        
        present(InputPopover, animated: true, completion: nil)
        if(act == 0){
            //initial
            InputPopover.DoneButton.addTarget(self, action: #selector(doneActionForInitial), for: .touchUpInside)
        }
        else{
            InputPopover.InviteInput.text = items[send].partyDescription
            InputPopover.NameInput.text = items[send].partyName
            InputPopover.LocationInput.text =  items[send].partyAddress
            InputPopover.DoneButton.tag = send
        
            InputPopover.DoneButton.addTarget(self, action: #selector(doneActionForEdit), for: .touchUpInside)
            //non initial
        }

    }
    @objc func doneActionForInitial(sender: UIButton){
      
       
        let name:String = InputPopover.NameInput.text!
        let starDate = InputPopover.Date
        
        let endTime = InputPopover.EndTime
        let components = Calendar.current.dateComponents([.hour, .minute], from: endTime!)
        let endhour = components.hour
        let endminute =  components.minute
        print(endhour)
        print(endminute)
        let startTime = InputPopover.StartTime
        let component = Calendar.current.dateComponents([.hour, .minute], from: startTime!)
        let starthour = component.hour
        let startminute = component.minute
        let location:String = InputPopover.LocationInput.text!
        let desc:String = InputPopover.InviteInput.text!
        var nCell:pCell = pCell(partyName: name, partyAddress: location, partyDescription: desc, documentID: "", startHour: starthour!, startMinute: startminute!, endHour: endhour!, endMinute: endminute!,  date: starDate!)
        let ref = db.collection("Hosts").document(FBSDKAccessToken.current().userID).collection("Party").addDocument(data: ["hostType":"Owner"])
        let did = ref.documentID
        db.collection("Parties").document(did).setData(["Name": nCell.partyName, "Location":nCell.partyAddress, "Description" : nCell.partyDescription])
        nCell.documentID = did
        items.append(nCell)
        self.TableView.reloadData()
        
    }
  
    @objc func doneActionForEdit(sender: UIButton){
        let name:String = InputPopover.NameInput.text!
        let starDate = InputPopover.Date
        
        let endTime = InputPopover.EndTime
        let components = Calendar.current.dateComponents([.hour, .minute], from: endTime!)
        let endhour = components.hour
        let endminute =  components.minute
        
        let startTime = InputPopover.StartTime
        let component = Calendar.current.dateComponents([.hour, .minute], from: startTime!)
        let starthour = component.hour
        let startminute = component.minute
        let location:String = InputPopover.LocationInput.text!
        let desc:String = InputPopover.InviteInput.text!
         var nCell:pCell = pCell(partyName: name, partyAddress: location, partyDescription: desc, documentID: "", startHour: starthour!, startMinute: startminute!, endHour: endhour!, endMinute: endminute!,  date: starDate!)
    db.collection("Parties").document(items[sender.tag].documentID).setData(["Name": nCell.partyName, "Location":nCell.partyAddress, "Description" : nCell.partyDescription])
        nCell.documentID = items[sender.tag].documentID
        items.remove(at: sender.tag)
        items.append(nCell)
        self.TableView.reloadData()
    

    }
    func addPartyToDataBase(cell:pCell){
        
        
    }
  
    @objc
    func editTapped(sender: UIButton){
        presentAndRecordInput(act:1, send: sender.tag)
    }
    @objc
    func verifyTapped(sender: UIButton){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyViewController") as UIViewController
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

        let currentCell = items[indexPath.row]
        print(currentCell)
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "cell") as! PartyCell
        cell.PartyName.text = currentCell.partyName
        cell.Location.text = currentCell.partyAddress
        cell.EditParty.addTarget(self, action:#selector(editTapped(sender:)), for: UIControlEvents.touchUpInside)
        cell.VerifyParty.addTarget(self, action:#selector(verifyTapped(sender:)), for: UIControlEvents.touchUpInside)
         cell.Invite.addTarget(self, action:#selector(inviteTapped(sender:)), for: UIControlEvents.touchUpInside)
        cell.EditParty.tag = indexPath.row
        cell.VerifyParty.tag = indexPath.row
        cell.Invite.tag = indexPath.row
    cell.AddBouncers.addTarget(self,action:#selector(addBouncers), for: UIControlEvents.touchUpInside)
        cell.AddBouncers.tag = indexPath.row
        return cell as UITableViewCell;
    }
    @objc func addBouncers(sender: UIButton){
        isInviteMode = false
        currentDocument = items[sender.tag].documentID
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
override func viewDidLoad() {
        super.viewDidLoad()
    TableView.dataSource = self
   // db.collection("Host/"+Auth.auth().currentUser!.uid).getDocuments(completion: )
    db.collection("Hosts").document(FBSDKAccessToken.current().userID).collection("Party").getDocuments(){(querySnapshot, err) in
        print("quering hosts")
    if let err = err {
        print(err)
    
    }else{
        for document in querySnapshot!.documents{
            print(document)

            
              db.collection("Parties").document(document.documentID).getDocument{ (document,error) in
                let description = document?.data()["Description"] as! String
                let name = document?.data()["Location"] as! String
                let location = document?.data()["Name"] as! String
//                let endTime = document?.data()["endTime"] as! String
//                let startTime = document?.data()["startTime"] as! String
                self.items.append(pCell(partyName: name, partyAddress: location, partyDescription: description,documentID: document?.documentID as! String, startHour: 0, startMinute: 0, endHour: 0, endMinute: 0, date: " "))
                
                self.TableView.reloadData()
                
            }
            
        }
    }
        //write query to get parties for bouncers 
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
