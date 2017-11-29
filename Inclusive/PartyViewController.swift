//
//  PartyViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/25/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
struct pCell{
    var partyName: String;
    var partyAddress: String;
    var partyDescription: String;
    
}

class PartyViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var PartyBar: UIToolbar!
      var items: [pCell] = [ pCell(partyName: "shit", partyAddress: "Fuck", partyDescription: "stuff")]
    @IBOutlet weak var TableView: UITableView!
    
    @IBAction func AddPartyButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Party Info", message: "Please give us some info about your party:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if (alertController.textFields![0] as? UITextField) != nil {
                // store your data
                let name = alertController.textFields![0].text
                let address = alertController.textFields![1].text
                let theme = alertController.textFields![2].text
                let newCell: pCell = pCell(partyName: name!, partyAddress: address!, partyDescription: theme!)
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
                let newCell: pCell = pCell(partyName: name!, partyAddress: address!, partyDescription: theme!)
                self.items.remove(at: row)
                self.items.insert(newCell, at: 0)
                
                self.TableView.reloadData()
                
                //store dis shit
                
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
