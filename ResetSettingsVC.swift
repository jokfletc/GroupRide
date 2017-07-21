//
//  ResetSettingsVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/21/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import Firebase

class ResetSettingsVC: UIViewController {
    
    var email:String!
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var groupText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getEmail() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let userEmail = (snapshot.value as? NSDictionary)?["Email"] as! String
                
                self.email = userEmail
            })
            
        }
    }
    
    
    
    
    @IBAction func doneResetSettings(_ sender: UIBarButtonItem) {
    
    
        
        
        let user = FIRAuth.auth()?.currentUser
        
        let usersRef = FIRDatabase.database().reference().child("users")
        
        
        if self.usernameText.text != "" || self.groupText.text != "" || self.emailText.text != "" {
            
            
            if self.usernameText.text != ""{
                
                usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).child("Username").setValue(self.usernameText.text as AnyObject)
                
            }
            
            if self.groupText.text != "" {
                usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).child("Group").setValue(self.groupText.text as AnyObject)
            }
            
            if self.emailText.text != "" {
                
                usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).child("Email").setValue(self.emailText.text as AnyObject)
                
                user?.updateEmail(self.emailText.text!) { error in
                    if error != nil {
                        self.showAlert("Email Reset", message: "There was an error reseting email, make sure entry is typed correctly")
                    }else{
                        print("email reset successful")
                    }
                }
                
            }
            self.showAlert("Settings Reset", message: "Settings have been successfully Reset!")
            
            
            
        }else{
            
            self.showAlert("Reset Error", message: "A text field must be filled to reset settings")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    
    
    @IBAction func passwordReset(_ sender: UIButton) {
        
        let email = self.email
        FIRAuth.auth()?.sendPasswordReset(withEmail: email!) { error in
            if error != nil {
                
                self.showAlert("Password Reset", message: "Error Sending Email For Password Reset")
            }else{
                print("Email sent for Password Reset!")
                self.showAlert("Password Reset", message: "Email has been sent for Password Reset!")
            }
        }
        
        
    }
    
    
    
    @IBAction func deleteAccount(_ sender: UIButton) {
        
        
        let user = FIRAuth.auth()?.currentUser
        
        user?.delete { error in
            if error != nil {
                self.showAlert("Account Deletion Error", message: "There was an error deleting account, try again or contact company at jfletch13@gmail.com")
            }else{
                print("User's Account deleted Successfully!")
            }
        }
        
    }
    
    
    
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
