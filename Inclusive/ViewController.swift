//
//  ViewController.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/17/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore







class ViewController: UIViewController, FBSDKLoginButtonDelegate{

    

    override func viewDidLoad() {
        super.viewDidLoad()

        if(FBSDKAccessToken.current() != nil){
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    // ...

                    print("my error/n/n/n/n/")
                    return
                }
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PartyViewController") as UIViewController
                self.present(nextViewController, animated:true, completion:nil)
                print("should present new view controller")
                print("signed in/n/n/n/n/n")
            }

            }
        else{
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
       }
        
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("shit")
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error != nil)
        {
            print("that dank tit tho")
            print(error.localizedDescription)
            return
        }
        if let token:FBSDKAccessToken = result.token
        {
            print(token.tokenString)
            ///credentials provider manager
            //
            print("shit")
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            print("trying to auth/n/n/n/n")
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    // ...
                    
                    print("my error/n/n/n/n/")
                    return
                }
                var name = Auth.auth().currentUser!.uid         
                
                print("signed in/n/n/n/n/n")
                    }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PartyViewController") as UIViewController
            self.present(nextViewController, animated:true, completion:nil)

            //transition view 
        }
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

