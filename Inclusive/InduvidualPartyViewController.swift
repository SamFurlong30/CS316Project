//
//  InduvidualPartyViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 12/10/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//


import UIKit
import FBSDKLoginKit
import FacebookCore
import FirebaseFirestore
    
class InduvidualPartyViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    struct typedPerson {
        var name: String!
        var email: String!
        var type: String!
    }
    @IBAction func TypeSelector(_ sender: Any) {
        self.Filter()
    }
    @IBOutlet weak var PartyNameLabel: UILabel!
    @IBOutlet weak var PartyImage: UIImageView!
    @IBOutlet weak var PartyDate: UILabel!
    
    @IBOutlet weak var SegmentedPeople: UISegmentedControl!
    @IBOutlet weak var PartyDescription: UITextView!
    @IBOutlet weak var PartyStartTime: UILabel!
    @IBOutlet weak var PartyEndTime: UILabel!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var PartyLocation: UITextView!
    
    @IBAction func InviteAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as! SelectFriendsViewController
        nextViewController.currentDocument = partyInfo.documentID
        nextViewController.isInviteMode = true
        nextViewController.currentDocument = self.partyInfo.documentID
        self.present(nextViewController, animated:true, completion:nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredItems.count;
    }
    func numberOfSections(in TableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ TableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "typeCell")! as UITableViewCell
        let person = filteredItems[indexPath.row]
        cell.textLabel?.text = person.name
        return cell
    }
    @IBAction func HostAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as! SelectFriendsViewController
        nextViewController.currentDocument = partyInfo.documentID
        nextViewController.isInviteMode = false
        present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func EditAction(_ sender: Any) {
        
    }
    func popoverPresentationControllerDidDismissPopover(popoverController: UIPopoverPresentationController){
        print("diddismiss")
        getAssociatedPeople()
    }
    
    @IBAction func VerifyAction(_ sender: Any) {
        let nextViewController = VerifyViewController()
        nextViewController.currentParty = partyInfo
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func DeleteAction(_ sender: Any) {
        //ToDo not that important
    }
    
    var partyInfo: pCell!
    var currentRow: Int!
    @objc func didSwipe(swipe: UISwipeGestureRecognizer) {
   
        if (swipe as? UISwipeGestureRecognizer) != nil{
            if(swipe.direction == UISwipeGestureRecognizerDirection.up){
                print("up")
                if(!partyInfo.isBouncer || !partyInfo.isActive || !partyInfo.isStale){
                self.presentAndRecordInput()
                }

            }
            else if (swipe.direction == UISwipeGestureRecognizerDirection.right) {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PartyViewController")
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(nextViewController, animated:false, completion:nil)
                
        }
            else if (swipe.direction == UISwipeGestureRecognizerDirection.left){
                if(partyInfo.isActive){
                let nextViewController = VerifyViewController()
                
                self.present(nextViewController, animated:true, completion:nil)
                nextViewController.currentParty = partyInfo
                nextViewController.currentRow = currentRow
                }
    }
    }
    else{
        print("WTF")
      
    }
}
    @IBOutlet weak var ManageBouncers: UIButton!
    @IBOutlet weak var ManageInvitees: UIButton!
    override func viewDidLoad() {
        TableView.delegate = self
        TableView.dataSource = self 
        super.viewDidLoad()
        let up = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        up.direction = .up
        self.view.addGestureRecognizer(up)
        let right = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        right.direction = .right
        self.view.addGestureRecognizer(right)
        let left = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        getAssociatedPeople()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var InputPopover: PartyInputViewController!
    @objc func doneAction(sender: Any){
        self.dismiss(animated: true, completion: {
          //populate from Currentcell of popover
            let party:pCell = self.InputPopover.currentCell
            self.partyInfo = party
            self.PartyDate.text = party.date
            self.PartyImage.image = party.image
            self.PartyDescription.text = party.partyDescription
            self.PartyLocation.text = party.partyAddress
            self.PartyNameLabel.text = party.partyName
            
            if(party.startMinute < 10){
                self.PartyStartTime.text = "Start Time:" + String(party.startHour) + ":0" + String(party.startMinute)
            }
            else{
                self.PartyStartTime.text = "Start Time:" + String(party.startHour) + ":" + String(party.startMinute)
                
            }
            if(party.endMinute < 10){
                self.PartyEndTime.text = "Start Time:" + String(party.endHour) + ":0" + String(party.endMinute)
            }
            else{
                self.PartyStartTime.text = "Start Time:" + String(party.endHour) + ":" + String(party.endMinute)
                
            }        })
        
    }
    func presentAndRecordInput(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        InputPopover = storyboard.instantiateViewController(withIdentifier: "PartyInput") as! PartyInputViewController
        InputPopover.modalPresentationStyle = .popover

        let popover = InputPopover.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .right
        self.present(InputPopover, animated: true, completion: nil)
        InputPopover.DoneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)

            InputPopover.isInitial = false
        
            let cell = partyInfo
            InputPopover.NameInput.text = cell?.partyName
            InputPopover.InviteInput.text = cell?.partyDescription
            InputPopover.LocationInput.text = cell?.partyAddress
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "mm dd yyyy"
        let date = dateFormatter.date(from: (cell?.date)!)
            let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents(year: 2017, month:1, day: 1, hour: cell?.startHour, minute: cell?.startMinute, second: 00)
            let startTime = calendar.date(from: components)!
        components = DateComponents(year: 2017, month:1, day: 1, hour: (cell?.endHour)!, minute: (cell?.endMinute)!, second: 00)
            let endTime = calendar.date(from: components)!
            
            
            InputPopover.StartDatePicker.date = startTime
            InputPopover.EndTimePicker.date = endTime
        InputPopover.PartyImageView.image = cell?.image
            InputPopover.currentRow = currentRow
        
        
    }
    var items:[typedPerson] = []
    var filteredItems:[typedPerson] = []
    func getAssociatedPeople(){
        items = []
        filteredItems = []
        print("tried to get parties with endpoint")
        let url = URL(string: "https://us-central1-inclu-af7f5.cloudfunctions.net/getInviteeStatusesForParty?pid=" + partyInfo.documentID)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do {
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                print(json)
                let bouncers  = json!["bouncers"] as! [[String:Any]]
                print(bouncers)

                for bouncer in bouncers {
                    let nameb = bouncer["name"] as! String
                    let emailb = bouncer["email"] as! String
                    let z = typedPerson(name: nameb,
                    email: emailb,
                    type: "bouncer")
                    self.items.append(z)
                    print(nameb)

                }
                let rsvps = json!["rsvp"] as! [[String:Any]]
                print(rsvps)
                
                for rsvp in rsvps {
                    print("rsvps")
                    let namer = rsvp["name"] as! String
                    let emailr = rsvp["email"] as! String
                    let r = typedPerson(name: namer,
                                        email: emailr,
                                        type: "rsvp")
                    self.items.append(r)
                    print(namer)

                }

                let checkedIn = json!["checkedIn"] as! [[String:Any]]
                print(checkedIn)

                for person in checkedIn {
                    print("checkedIn")
                    let namep = person["name"] as! String
                    let emailp = person["email"] as! String
                    let p = typedPerson(name: namep,
                                        email: emailp,
                                        type: "checkedIn")
                    self.items.append(p)
                    print(namep)

                }
                let invitedTo = json!["invitedTo"] as! [[String:Any]]
                print(invitedTo)
                for invitee in invitedTo {
                    print("invited")
                    let namei = invitee["name"] as! String
                    print(namei)
                    let emaili = invitee["email"] as! String
                    let q = typedPerson(name: namei,
                                        email: emaili,
                                        type: "invitedTo")
                    self.items.append(q)

                }
                DispatchQueue.main.sync {

                self.filteredItems = self.items
            
                    self.Filter()
                }
                    print("reloaded")
                
            print(self.items)
                
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
        }
        
        task.resume()
        
        
    }
    func Filter(){
        print("filter")
        
        switch self.SegmentedPeople.selectedSegmentIndex{
        case 0:
            filteredItems = items.filter { $0.type == "invitedTo" }
            
        case 1:
            filteredItems = items.filter{ $0.type == "rsvp" }
        case 2:
            filteredItems = items.filter{ $0.type == "checkedIn" }
        case 3:
            filteredItems = items.filter{ $0.type == "bouncer" }

        default:
            return
        }
      
      
        TableView.reloadData()
        
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
