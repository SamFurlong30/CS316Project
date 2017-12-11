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
    var isStale: Bool;
    var isActive: Bool;


    
}
var storeItems:[pCell] = []
class PartyViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)

    func updateSearchResults(for searchController: UISearchController) {
//        print("filter check")
//        if(searchController.searchBar.text!.lowercased() == ""){
//            filteredItems = items
//        }
//
//        // Filter the results
//        if(showHistory){
//        filteredItems = items.filter { $0.partyName.lowercased().contains(searchController.searchBar.text!.lowercased()) & $0.isStale == true}
//        }
//        else{
//            filteredItems = items.filter { $0.partyName.lowercased().contains(searchController.searchBar.text!.lowercased()) & $0.isStale == false}
//        }
        
        self.TableView.reloadData()
    }
    @IBAction func HostFilterAction(_ sender: Any) {
        self.Filter()
    }
    
    @IBOutlet weak var SegmentHostFilter: UISegmentedControl!
    
    @IBOutlet weak var SegmentFilter: UISegmentedControl!
    
    @IBAction func FilterBySegment(_ sender: UISegmentedControl) {
       self.Filter()
    }
    func Filter(){
   
        switch self.SegmentFilter.selectedSegmentIndex{
        case 0:
            filteredItems = items.filter { $0.isActive }
            
        case 1:
            filteredItems = items.filter{ !$0.isStale && !$0.isActive }
        case 2:
            filteredItems = items.filter{ $0.isStale }
        default:
            return
        }
        if(self.SegmentHostFilter.selectedSegmentIndex==0){
            filteredItems = filteredItems.filter{!$0.isBouncer}
        }
        else{
            filteredItems = filteredItems.filter{$0.isBouncer}

        }
        TableView.reloadData()
    }
    var InputPopover: PartyInputViewController!
    var datepicker: UIDatePicker = UIDatePicker()
    @IBOutlet weak var PartyBar: UIToolbar!
    var items: [pCell] = []
    var filteredItems: [pCell] = []
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
            InputPopover.isInitial = false
            present(InputPopover, animated: true, completion: nil)

        var cell = filteredItems[send]
            print(cell)
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
        nextViewController.currentParty = filteredItems[sender.tag].documentID
        self.present(nextViewController, animated:true, completion:nil)
    }
    @objc
    func inviteTapped(sender: UIButton){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as! SelectFriendsViewController
        nextViewController.currentDocument = filteredItems[sender.tag].documentID
        nextViewController.isInviteMode = true

        self.present(nextViewController, animated:true, completion:nil)

    }
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 175.0;//Your custom row height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredItems.count;
    }
   func numberOfSections(in TableView: UITableView) -> Int{
        return 1
    }
    @objc func deleteTapped(sender: UIButton){
        
       var docId = filteredItems[sender.tag].documentID
        db.collection("Parties").document(docId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        db.collection("Hosts").document(FBSDKAccessToken.current().userID).collection("Party").document(docId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        filteredItems.remove(at: sender.tag)
        TableView.reloadData()
        //also need to remove the bouncers for this party
        //which is pretty fuck ass and we may ignore it
        //need to delete rsvps too
        //need to delete checked in also
        //this function fucking suckkkkkks
        //lotta stale data
        
        

    }
    

    var selectedCell: Int = 124
    func tableView(_ TableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "cell") as! PartyCell

        let currentCell = filteredItems[indexPath.row]
        cell.PartyName.text = currentCell.partyName
        cell.Location.text = currentCell.partyAddress
        cell.Location.allowsEditingTextAttributes = false

       
                if(currentCell.isActive){
                cell.VerifyParty.tag = indexPath.row
                cell.VerifyParty.addTarget(self, action:#selector(verifyTapped), for: UIControlEvents.touchUpInside)
                cell.Invite.isHidden = true
                    cell.EditParty.isHidden = true
                
                }
                if(!currentCell.isStale && !currentCell.isActive){
                    cell.Invite.isHidden = false
                    cell.EditParty.isHidden = false
                cell.Invite.addTarget(self, action:#selector(inviteTapped), for: UIControlEvents.touchUpInside)
                    cell.Invite.tag = indexPath.row
                    cell.VerifyParty.isHidden = true
                    cell.EditParty.addTarget(self, action:#selector(editTapped), for: UIControlEvents.touchUpInside)
                    cell.EditParty.tag = indexPath.row
                    if(currentCell.startMinute < 10){
                        cell.StartTimeEndTime.text = "Start Time:" + String(currentCell.startHour) + ":0" + String(currentCell.startMinute)
                    }
                    else{
                        cell.StartTimeEndTime.text = "Start Time:" + String(currentCell.startHour) + ":" + String(currentCell.startMinute)
                        
                    }
                }
                
        
            if(currentCell.isStale){
                cell.Invite.isHidden = true
                cell.EditParty.isHidden = true
                cell.VerifyParty.isHidden = true
            }
            if(!currentCell.isBouncer){
                cell.DeletePartyButton.addTarget(self, action:#selector(deleteTapped), for: UIControlEvents.touchUpInside)
                cell.DeletePartyButton.tag = indexPath.row
                cell.AddBouncers.addTarget(self,action:#selector(addBouncers), for: UIControlEvents.touchUpInside)
                cell.AddBouncers.tag = indexPath.row

            }
            else{
                cell.DeletePartyButton.isHidden = true
                cell.AddBouncers.isHidden = true
                cell.Analytics.isHidden = true
                cell.Invite.isHidden = true
                cell.EditParty.isHidden = true
                cell.PartyName.text = "Bouncer for:" + cell.PartyName.text! as! String
                
            }
        if(currentCell.endMinute < 10){
            cell.StartTimeEndTime.text = "End Time:" + String(currentCell.endHour) + ":0" + String(currentCell.endMinute)
        }
        else{
            cell.StartTimeEndTime.text = "Start Time:" + String(currentCell.startHour) + ":" + String(currentCell.startMinute)
            
        }

       
        
        cell.PartyImage.image = currentCell.image
        cell.StartDate.text = currentCell.date
      
      
        //else is not active
        //end time
 
        
        return cell as UITableViewCell;

    }
    @objc func addBouncers(sender: UIButton){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectFriendsViewController") as! SelectFriendsViewController
        nextViewController.currentDocument = filteredItems[sender.tag].documentID
        nextViewController.isInviteMode = false

        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func ManualLogout(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    @objc func didSwipe(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            let swipeLocation = recognizer.location(in: self.TableView)
            if let swipedIndexPath = TableView.indexPathForRow(at: swipeLocation) {
                if let swipedCell = self.TableView.cellForRow(at: swipedIndexPath) {
                    // Swipe happened. Do stuff!
                    print("swipe")
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "InduvidualPartyViewController") as UIViewController
                    self.present(nextViewController, animated:true, completion:nil)

                    
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var recognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        
        self.TableView.addGestureRecognizer(recognizer)
        items = storeItems
        filteredItems = items
        self.getParties()
        TableView.dataSource = self
        TableView.reloadData()
        self.searchController.searchResultsUpdater = self
        
}
    func getParties(){
        print("tried to get parties with endpoint")
        let url = URL(string: "https://us-central1-inclu-af7f5.cloudfunctions.net/getActiveParties?uid=" + FBSDKAccessToken.current().userID)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let parties = json["partyData"] as? [[String: Any]] {
                    print(parties)
                    for party in parties {
                        self.jsonToPCell(party:party)
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }

        }
        task.progress.isFinished
        task.resume()
    }
    func jsonToPCell(party:[String:Any]){
        let description = party["Description"] as! String
        let name = party["Name"] as! String
        let location = party["Location"] as! String
        let date = party["date"] as! String
        let startMinute = party["startMinute"] as! Int
        let startHour = party["startHour"] as! Int
        let endMinute = party["endMinute"] as! Int
        let endHour = party["endHour"] as! Int
        let isActive = party["isActive"] as! Bool
        let isStale = party["isStale"] as! Bool

       // let imageURL:String = party["partyID"] as! String + ".png"
//        let pathReference = storage.reference(withPath: "PartyImages/"+imageURL)
//        pathReference.getData(maxSize: 1024 * 1024 * 1024) { data, error in
//            if let error = error {
//                // Uh-oh, an error occurred!
//                print("broken")
//
//                print(error)
//            } else {
        
                // Data for "images/island.jpg" is returned
               // let image = UIImage(data: data!)
                let image = UIImage()
        var myParty: pCell = pCell(partyName: name, partyAddress: location, partyDescription: description, documentID: "", startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, date: date, isBouncer: party["hostType"] as! String != "host", image: image, isStale: isStale, isActive: isActive)
        print(myParty)
        self.items.append(myParty)
        storeItems.append(myParty)
                print("endpoint hit and reload")
        DispatchQueue.main.sync() {
            // place code for main thread here
            self.Filter()
            self.TableView.reloadData()

        }
        
           // }
     //   }

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
