//
//  settingsVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/16/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import Firebase

class settingsVC: UIViewController {
    
    var textField = UITextField()
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    
    var username: String?
    var group: String!
    var email: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.getUsername()
        self.getGroup()
        self.getEmail()
        
        
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getUsername() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let userName = (snapshot.value as? NSDictionary)?["Username"] as! String
                self.username = userName
                print(self.username)
                var usernameLabel = UILabel()
                usernameLabel.text = self.username
                usernameLabel.frame = CGRect(x: 107, y: 94, width: 198, height: 21)
                usernameLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 15.0)
                usernameLabel.backgroundColor = UIColor.clear
                usernameLabel.textColor = UIColor.blue
                
                usernameLabel.textAlignment = NSTextAlignment.left
                self.view.addSubview(usernameLabel)
                
            })
        }
        
        
    }
    
    func getGroup() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let userGroup = (snapshot.value as? NSDictionary)?["Group"] as! String
                self.group = userGroup
                print(self.group)
                
                
                var groupLabel = UILabel()
                groupLabel.text = self.group
                groupLabel.frame = CGRect(x: 107, y: 123, width: 198, height: 21)
                groupLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 15.0)
                groupLabel.backgroundColor = UIColor.clear
                groupLabel.textColor = UIColor.blue
                
                groupLabel.textAlignment = NSTextAlignment.left
                self.view.addSubview(groupLabel)
                
            })
        }
        
        
    }
    
    
    func getEmail() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let userEmail = (snapshot.value as? NSDictionary)?["Email"] as! String
                
                self.email = userEmail
                print(self.email)
                
                var emailLabel = UILabel()
                emailLabel.text = self.email
                emailLabel.frame = CGRect(x: 107, y: 152, width: 198, height: 21)
                emailLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 15.0)
                emailLabel.backgroundColor = UIColor.clear
                emailLabel.textColor = UIColor.blue
                
                emailLabel.textAlignment = NSTextAlignment.left
                self.view.addSubview(emailLabel)
                
                
            })
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
