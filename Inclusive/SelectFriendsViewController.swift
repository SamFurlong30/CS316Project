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
import JavaScriptCore
struct friend{
    init(name: String, id: String, pic: UIImageView) {
        self.name = name
        self.fbID = id
        self.pic = pic
    }
    var fbID: String
    var name: String
    var pic: UIImageView
    
}
class SelectFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    var donePressed:(()->Void)?
    let searchController = UISearchController(searchResultsController: nil)
    var currentDocument: String!
    var isInviteMode: Bool!
    
    @IBAction func DoneAction(_ sender: Any) {
    
        var requestString:String = ""
        if(isInviteMode){
            requestString = "https://us-central1-inclu-af7f5.cloudfunctions.net/addMembersToParty?uid="

        }
        else{
            requestString = "https://us-central1-inclu-af7f5.cloudfunctions.net/addBouncersToParty?uid="
        }
        
        
        var ids: [String] = []
        
        for item in self.selectedItems {
            ids.append(item.fbID)
        }
        
        let json: [String:[Any]] = ["invitedTo": ids]     

        
        // create post request
        let url = URL(string: requestString + FBSDKAccessToken.current().userID + "&pid=" + self.currentDocument)!
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: json)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error)                                 // some fundamental network error
                return
            }
            
            do {
                let responseObject = try JSONSerialization.jsonObject(with: data)
                print(responseObject)
            } catch let jsonError {
                print(jsonError)
                print(String(data: data, encoding: .utf8))   // often the `data` contains informative description of the nature of the error, so let's look at that, too
            }
        }
        task.resume()
    
                //add all of the new selected friends to the database
        self.dismiss(animated: true, completion: donePressed!)
       
       
    }
    
 func ClearAction() {
        //clear all added friends
        for i in selectedItems {
            items.append(i)
        }
        selectedItems.removeAll()
        self.FriendsTable.reloadData()
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
            return filteredItems.count
            
        case 1:
            return selectedItems.count
            
        default:
            return 0
        }

    }
    func numberOfSections(in TableView: UITableView) -> Int{
        return 2
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && self.filteredItems.count>=1){
        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = false
        self.selectedItems.append(self.filteredItems[indexPath.row])
        self.items.remove(at: indexPath.row)
        self.FriendsTable.reloadData()
        }
    }
    @objc func addAction(sender: UIButton!) {
        let f:friend = self.filteredItems[sender.tag]
        self.selectedItems.append(f)
        
        if (items.contains(where: {$0.fbID == f.fbID}) ){
            let i: Int = self.items.index(where: {$0.fbID == f.fbID})!
        items.remove(at: i)
        }
        self.filteredItems.remove(at: sender.tag)
        self.FriendsTable.reloadData()
        
        
    }
    @objc func deleteAction(sender: UIButton!) {
        let f:friend = self.selectedItems[sender.tag]
        self.items.append(f)
        selectedItems.remove(at: sender.tag)
        self.FriendsTable.reloadData()
        
    }
  
    
    @IBAction func ClearButton(_ sender: Any) {
        ClearAction()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("added row")
        switch (indexPath.section) {
        case 0:
            let cell:FriendNotInvitedCell = tableView.dequeueReusableCell(withIdentifier: "FriendNotInvitedCell", for: indexPath) as! FriendNotInvitedCell
               
            let currentFriend = filteredItems[indexPath.row]
                print("tableview invited")
                cell.tag = indexPath.row
                cell.ProfilePic.image = currentFriend.pic.image
                cell.AddToListAction.tag = indexPath.row
                cell.NameLabel?.text = currentFriend.name
                cell.AddToListAction.addTarget(self, action: #selector(addAction), for: .touchUpInside)
            return cell
        
        case 1:

            let cell: FriendInvitedCell = tableView.dequeueReusableCell(withIdentifier: "FriendInvitedCell", for: indexPath) as!FriendInvitedCell
                print(indexPath.row)
                print(selectedItems.count)
            let currentFriend = selectedItems[indexPath.row]
            cell.NameLabel!.text = currentFriend.name
                cell.ProfilePic.image = currentFriend.pic.image
                cell.DeleteInviteAction.tag = indexPath.row
              cell.DeleteInviteAction.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            cell.tag = indexPath.row
                
                return cell
                

            
        
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
   
    var items = [friend]()
    var selectedItems = [friend]()
    var filteredItems = [friend]()
    var shouldShowSearchResults = false
    @IBOutlet weak var FriendsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.FriendsTable.delegate = self
        self.FriendsTable.dataSource = self
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.view.addSubview(self.searchController.searchBar)
        
        let params = ["fields" : "email, name, picture.type(large)"]
        let graphRequest = GraphRequest(graphPath: "me/friends", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            print("trying request")
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    let friends = responseDictionary["data"] as! NSArray
                    //query to see invited friends
                    
                    for myFriend in friends{
                       let friendInfo = myFriend as! NSDictionary
                        let name = friendInfo["name"]
                        let id = friendInfo["id"]
                        var col:String
                        if(self.isInviteMode){
                            col = "invitedTo"
                        }
                        else{
                            col = "Bouncers"

                        }
                        
                    
                        db.collection(col).document(self.currentDocument).collection("Invitees").getDocuments(){ (querySnapshot, error) in
                                print("this be documents")
                            
                            var flag: Bool = true
                                for i in querySnapshot!.documents {
                                    //check to see if friend is already invitied
                                    if(i.documentID as String == id as! String ){
                                        flag = false
                                        if let imageString = ((friendInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                                            print(imageString)
                                            let imageURL = URL(string: imageString)
                                            print(imageURL)
                                            // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
                                            let session = URLSession(configuration: .default)
                                            print("download pic")
                                            DispatchQueue.global(qos: .userInitiated).async {
                                                
                                                let imageData:NSData = NSData(contentsOf: imageURL!)!
                                                
                                                print("task queued")
                                                // When from background thread, UI needs to be updated on main_queue
                                                DispatchQueue.main.async {
                                                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:200, height:200))
                                                    imageView.center = self.view.center
                                                    let image = UIImage(data: imageData as Data)
                                                    imageView.image = image
                                                    imageView.contentMode = UIViewContentMode.scaleAspectFit
                                                    print("done")
                                                    self.selectedItems.append(friend(name: name as! String, id: id as! String, pic: imageView))
                                                    self.FriendsTable.reloadData()

                                                    print("appended one item to selectedItems")
                                                    
                                                }
                                            }
                                            //Download image from imageURL
                                        }
                                       
                                    }
                                  
                                    //add friend to selected
                            }
                            if(flag){
                                if let imageString = ((friendInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                                    print(imageString)
                                    let imageURL = URL(string: imageString)
                                    print(imageURL)
                                    // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
                                    let session = URLSession(configuration: .default)
                                    print("download pic")
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        
                                      
                                        DispatchQueue.main.async {
                                            let imageData:NSData = NSData(contentsOf: imageURL!)!
                                            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:200, height:200))
                                            imageView.center = self.view.center
                                            print("task queued")
                                            // When from background thread, UI needs to be updated on main_queue
                                            let image = UIImage(data: imageData as Data)
                                            imageView.image = image
                                            imageView.contentMode = UIViewContentMode.scaleAspectFit
                                            print("done")
                                            self.items.append(friend(name: name as! String, id: id as! String, pic: imageView))
                                            print("Appended to Items")

                                        }
                                    }
                                    //Download image from imageURL
                                }
                                

                                self.FriendsTable.reloadData()

                        
                            
                            }
                        }
                        self.filteredItems = self.items
                        
                        print("trying to grab picture")
                        print(friendInfo)
                    
                        
                       
                     }

                    
                    
                }
            
                
            }
        }
        //do a firebase query for all of the added friends
        //append all of the added friends to addedItems
        //remove all of the added friends from filtered items
      
    }

  
    @IBOutlet weak var EmailField: UITextField!
    
    @IBAction func EmailButton(_ sender: Any) {
        selectedItems.append(friend(name: EmailField.text!, id: "nahfam", pic: UIImageView()))
        FriendsTable.reloadData()
        
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
