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
        present(InputPopover, animated: true, completion: nil)

        InputPopover.DoneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        

    }
    @objc func doneAction(sender: Any){
        self.dismiss(animated: true, completion: {
            //maybe something here but probably not
        })
    
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
        cell.PartyName.text = currentCell.partyName
        cell.PartyImage.image = currentCell.image
        print(currentCell.image)
        print(currentCell.image)
        cell.StartDate.text = currentCell.date
        cell.PartyImage.image = currentCell.image
      
      
        //else is not active
        //end time
 
        
        return cell as UITableViewCell;

    }

    
    @IBAction func ManualLogout(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    @objc func didSwipe(swipe: UISwipeGestureRecognizer) {
        print("fuck")
        print(swipe.direction)
        if  swipe.direction == UISwipeGestureRecognizerDirection.left
        {
            let gesture = swipe as UIGestureRecognizer
            let swipeLocation = gesture.location(in: self.TableView)
            if let swipedIndexPath = TableView.indexPathForRow(at: swipeLocation) {
                if let swipedCell = self.TableView.cellForRow(at: swipedIndexPath) {
                    // Swipe happened. Do stuff!
                    print("swipe")
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let partyView = storyBoard.instantiateViewController(withIdentifier: "InduvidualPartyViewController") as! InduvidualPartyViewController
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    let party:pCell = self.filteredItems[swipedIndexPath.row]
                    partyView.partyInfo = party
                    self.present(partyView, animated:false, completion:nil)
                    partyView.currentRow = swipedIndexPath.row
                    partyView.PartyDate.text = party.date
                    partyView.PartyImage.image = party.image
                    partyView.PartyDescription.text = party.partyDescription
                    partyView.PartyLocation.text = party.partyAddress
                    partyView.PartyNameLabel.text = party.partyName
                    if(party.isStale){
                        //hide bouncers and invitees button if party is active
                        partyView.ManageBouncers.isHidden = true
                        partyView.ManageInvitees.isHidden = true
                    }
                    if(party.startMinute < 10){
                        partyView.PartyStartTime.text = "Start Time:" + String(party.startHour) + ":0" + String(party.startMinute)
                    }
                    else{
                        partyView.PartyStartTime.text = "Start Time:" + String(party.startHour) + ":" + String(party.startMinute)
                        
                    }
                    if(party.endMinute < 10){
                        partyView.PartyEndTime.text = "Start Time:" + String(party.endHour) + ":0" + String(party.endMinute)
                    }
                    else{
                        partyView.PartyStartTime.text = "Start Time:" + String(party.endHour) + ":" + String(party.endMinute)
                        
                    }
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let left = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        left.direction = .left
        self.TableView.addGestureRecognizer(left)
        let right = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        right.direction = .right
        self.TableView.addGestureRecognizer(right)
        if(storeItems.count>1){
        items = storeItems
        filteredItems = items
        }
        self.Filter()

        TableView.dataSource = self
        TableView.reloadData()
        self.getParties()

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
                    self.items.removeAll()
                    storeItems.removeAll()
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
        let partyID = party["partyId"] as! String
        var myParty: pCell = pCell(partyName: name, partyAddress: location, partyDescription: description, documentID: partyID , startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, date: date, isBouncer: party["hostType"] as! String != "host", image: UIImage(), isStale: isStale, isActive: isActive)
        DispatchQueue.main.sync() {
            // place code for main thread here
            self.Filter()
            self.TableView.reloadData()
            self.items.append(myParty)
            storeItems.append(myParty)
            
        }
        let imageURL:String = party["partyId"] as! String + ".png"
        let pathReference = storage.reference(withPath: "PartyImages/"+imageURL)
        pathReference.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("broken")

                print(error)
            }
            else if data != nil {
               //  Data for "images/island.jpg" is returned
                
                myParty.image = UIImage(data: data! as Data)!
                
               
                print("endpoint hit and reload")
                self.items = self.items.filter{$0.documentID != myParty.documentID}
                self.items.append(myParty)
                
                storeItems = self.items
                
                self.Filter()

                
           
            print("hit here")

        
                
    }
            else{
                print("no error but also no data")
            }
        }

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
