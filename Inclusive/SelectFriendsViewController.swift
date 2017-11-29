//
//  SelectFriendsViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/26/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookCore
import FirebaseAuth

struct friend{
    init(name: String, id: String) {
        self.name = name
        self.fbID = id
    }
    var fbID: String
    var name: String
}

class SelectFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)

    @IBAction func DoneAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PartyViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
        //make backend call to add friends
        
        
    }
    
    @IBAction func ClearAction(_ sender: Any) {
    }
    func updateSearchResults(for searchController: UISearchController) {
        print("filter check")

        
            // Filter the results
        filteredItems = items.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        
        
        self.FriendsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            if(filteredItems.count == 0){
                return 1
            }
            else{
            return filteredItems.count
            }
        case 1:
            if(filteredItems.count == 0){
                return 1
            }
            else{
            return selectedItems.count
            }
        default:
            return 0
        }

    }
    func numberOfSections(in TableView: UITableView) -> Int{
        return 2
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && self.filteredItems.count>1){
        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = false
        self.selectedItems.append(self.filteredItems[indexPath.row])
        self.filteredItems.remove(at: indexPath.row)
        self.items.remove(at: indexPath.row)
        self.FriendsTable.reloadData()
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("added row")
        switch (indexPath.section) {
        case 0:
            if(indexPath.row < filteredItems.count){
            let cell:FriendNotInvitedCell = tableView.dequeueReusableCell(withIdentifier: "FriendNotInvitedCell", for: indexPath) as! FriendNotInvitedCell
            let currentFriend = filteredItems[indexPath.row]
            cell.textLabel!.text = currentFriend.name
            cell.tag = indexPath.row
            return cell
            }
            else{
                return UITableViewCell()
            }
        case 1:
            if(indexPath.row < selectedItems.count){

            let cell: FriendInvitedCell = tableView.dequeueReusableCell(withIdentifier: "FriendInvitedCell", for: indexPath) as!FriendInvitedCell
            let currentFriend = selectedItems[indexPath.row]
            cell.textLabel!.text = currentFriend.name + "is invited"
            cell.tag = indexPath.row
                return cell

            }
            else{
                return UITableViewCell()
            }
        default:
            let cell: FriendInvitedCell = tableView.dequeueReusableCell(withIdentifier: "FriendInvitedCell", for: indexPath) as! FriendInvitedCell
            let currentFriend = selectedItems[indexPath.row]
            cell.textLabel!.text = currentFriend.name
            cell.tag = indexPath.row
            return cell
        }
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
      
        case 1:
            return "Invited"
        default:
            return nil
        }
    }
    var items = [friend]()
    var selectedItems = [friend]()
    var filteredItems = [friend]()
    var shouldShowSearchResults = false
    @IBOutlet weak var FriendsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        
        let params = ["fields" : "email, name"]
        let graphRequest = GraphRequest(graphPath: "me/friends", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    let friends = responseDictionary["data"] as! NSArray
                    for myFriend in friends{
                       let friendInfo = myFriend as! NSDictionary
                        let name = friendInfo["name"]
                        let id = friendInfo["id"]
                        let newFriend:friend = friend(name: name! as! String, id: id! as! String )
                        self.items.append(newFriend)
                        self.filteredItems = self.items
                        self.FriendsTable.dataSource = self
                        self.FriendsTable.delegate = self
                        self.searchController.searchResultsUpdater = self
                        self.searchController.dimsBackgroundDuringPresentation = false
                        self.definesPresentationContext = true
                        
                        self.FriendsTable.tableHeaderView = self.searchController.searchBar
                        
                        self.FriendsTable.reloadData()

                     }
                    
                    
                }

                
            }
        }
        //do a firebase query for all of the added friends
        //append all of the added friends to addedItems
        //remove all of the added friends from filtered items 
      
    }
    @IBOutlet weak var InviteBar: UIToolbar!
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch(section){
        
    case 0:
        return InviteBar.vie
        
    default:
        return nil
    }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
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
