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
struct pCell{
    var partyName: String;
    var partyAddress: String;
    var partyDescription: String;
    var documentID: String;
    
}
class PartyViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var PartyBar: UIToolbar!
    var items: [pCell] = []
    @IBOutlet weak var TableView: UITableView!
    
    @IBAction func AddPartyButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Party Info", message: "Please give us some info about your party:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if (alertController.textFields![0] as? UITextField) != nil {
                // store your data
                let name = alertController.textFields![0].text
                let address = alertController.textFields![1].text
                let theme = alertController.textFields![2].text
                var ref: DocumentReference? = nil
                ref = db.collection("Parties").addDocument(data: [
                    "Description" : name ?? "",
                    "Location" : address ?? "",
                    "Name" : theme ?? "",
                    "startTime":"",
                    "endTime":""
                    ])
                {err in
                    if let err = err {
                        
                    }
                    else{
                        db.collection("Hosts").document(FBSDKAccessToken.current().userID).collection("Party").document(ref!.documentID).setData(["hostType":"Owner"])

                    }
                    
                }
                
                let newCell: pCell = pCell(partyName: name!, partyAddress: address!, partyDescription: theme!, documentID: ref!.documentID)
                self.items.append(newCell)
                
                self.TableView.reloadData()
              
                //store dis shit
                
                
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Party Name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Party Address"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Party Description/Theme"
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
    }
    @objc
    func editTapped(sender: UIButton){
        let row = sender.tag
        var myCell: pCell = items[row]
        let alertController = UIAlertController(title: "Party Info", message: "Please give us some info about your party:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if (alertController.textFields![0] as? UITextField) != nil {
                // store your data
                let name = alertController.textFields![0].text
                let address = alertController.textFields![1].text
                let theme = alertController.textFields![2].text
                let newCell: pCell = pCell(partyName: name!, partyAddress: address!, partyDescription: theme!, documentID: myCell.documentID)
                self.items.remove(at: row)
                self.items.insert(newCell, at: 0)
                
                self.TableView.reloadData()
                
                //store dis shit
                print("should be adding to database")
                db.collection("Parties").document(myCell.documentID).setData([
                    "Description" : newCell.partyDescription,
                    "Location" : newCell.partyAddress,
                    "Name" : newCell.partyName,
                    "startTime":"",
                    "endTime":""
                    ])
                {err in
                    if let err = err {
                        
                    }
                    else{
                        }
                    
                }

                
            } else {
                // user did not fill field
            }
        }
    
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.text = myCell.partyName
        }
        alertController.addTextField { (textField) in
            textField.text = myCell.partyAddress
        }
        alertController.addTextField { (textField) in
            textField.text = myCell.partyDescription
        }
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
    }
    @objc
    func verifyTapped(sender: UIButton){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyViewController") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    @objc
    func inviteTapped(sender: UIButton){
        
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
        
        return cell as UITableViewCell;
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
        print("no error")
        print(querySnapshot!.documents)
        for document in querySnapshot!.documents{
            print(document.documentID)
              db.collection("Parties").document(document.documentID).getDocument{ (document,error) in
                let description = document?.data()["Description"] as! String
                let name = document?.data()["Location"] as! String
                let location = document?.data()["Name"] as! String
//                let endTime = document?.data()["endTime"] as! String
//                let startTime = document?.data()["startTime"] as! String
                self.items.append(pCell(partyName: name, partyAddress: location, partyDescription: description,documentID: document?.documentID as! String))
                self.TableView.reloadData()




                
                
            }
            
        }
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
