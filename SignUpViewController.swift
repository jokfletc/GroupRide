//
//  SignUpViewController.swift
//  ResumeProject
//
//  Created by john fletcher on 5/31/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var riderDriverControl: UISegmentedControl!
    
    @IBOutlet weak var username2: UITextField!
    @IBOutlet weak var groupEntry: UITextField!
    @IBOutlet weak var reEnterPassword: UITextField!
    
    
    var buttonTitlePressed: String?
    var isSignIn: Bool?
    var isRider: Bool?
    var isRiderVar: String?
    var riderVal: String?

   
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.determineSignInOrRegister()
       
        
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CreateAccount(_ sender: UIBarButtonItem) {
       
            
        if isSignIn == false{
            
            if self.username.text == "" || self.password.text == "" || self.riderDriverControl.selectedSegmentIndex == -1 {
                if self.username.text == ""{
                    self.username.layer.borderColor = UIColor.red.cgColor
                    self.username.layer.borderWidth = 1.0
                    
                }
                if self.password.text == ""{
                    self.password.layer.borderColor = UIColor.red.cgColor
                    self.password.layer.borderWidth = 1.0
                    
                }
                
                if self.riderDriverControl.selectedSegmentIndex == -1 {
                    
                    self.riderDriverControl.layer.borderColor = UIColor.red.cgColor
                    self.riderDriverControl.layer.borderWidth = 1.0
                    self.showAlert("Missing Field Required", message: "Fill in or select missing Field(s) in red")
                    
                }
            }else{
            
            self.RegisterUser()
            }
        
            
        }else{
            
            if self.username.text == "" || self.password.text == ""{
                
                if self.username.text == ""{
                    self.username.layer.borderColor = UIColor.red.cgColor
                    self.username.layer.borderWidth = 1.0
                    
                }
                if self.password.text == ""{
                    self.password.layer.borderColor = UIColor.red.cgColor
                    self.password.layer.borderWidth = 1.0
                    self.showAlert("Missing Field Required", message: "Fill in or select missing Field(s) in red")
                }
        
            }else{
                
                self.login()
            }
        }
    }


    func login(){
        
        
        let ref = FIRDatabase.database().reference()
        FIRAuth.auth()?.signIn(withEmail: self.username.text!, password: self.password.text!, completion: {
            user, error in
            
            if error != nil{
                
                print("Incorrect")
                self.showAlert("Error Logging in", message: "There was an Error accessing this account")
                
            }else{
                
                print("Success login!")
                self.riderValue()
                
                
            }
            
        })
        
        
    }
    
        
    
    func pageDecider(){
        
        
        if self.riderVal == "true" {
            
            self.presentRiderVC()
            
        }else if self.riderVal == "false"{
            
            self.presentDriverVC()
        }
    }
    

        func RegisterUser(){
            if self.password.text == self.reEnterPassword.text{
        FIRAuth.auth()?.createUser(withEmail: self.username.text!, password: self.password.text!, completion: {
            user, error in
            if error != nil{
                
                self.showAlert("Error Registering", message: "There was an error creating this account")
            
            }else{
                let ref = FIRDatabase.database().reference()
                
                let user = ["Username":self.username2.text as! AnyObject,"Group":self.groupEntry.text as! AnyObject,"Email":self.username.text as! AnyObject, "Password":self.password.text as! AnyObject, "isRider": self.isRiderVar as! AnyObject]
                ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(user)
                
                
                
                print("User Created")
                self.login()
            }
                })
            }else{
                self.showAlert("Password Error", message: "Both Passwords Do Not Match!")
            }
    }
    
    @IBAction func Canel(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func determineSignInOrRegister(){
        
        if buttonTitlePressed != nil{
        if buttonTitlePressed == "signIn" {
            isSignIn = true
         
                
        self.navigationController!.topViewController!.title = "Sign In"
            print(isSignIn)
            }
        }else{
        isSignIn = false
        self.navigationController!.topViewController!.title = "Register"
            
        self.riderDriverControl.isHidden = false
        self.username2.isHidden = false
        self.reEnterPassword.isHidden = false
        self.groupEntry.isHidden = false
            
            print(isSignIn)
        }
    }
    
    @IBAction func riderDriver(_ sender: UISegmentedControl) {
        
        if self.riderDriverControl.selectedSegmentIndex == 0 {
            
            self.isRider = true
            self.isRiderVar = "true"
            print("I'm a rider")
            print(isRider)
            
        }else{
            
            self.isRider = false
            self.isRiderVar = "false"
            print(isRider)
            print("I'm a driver")
        }
        
    }
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func presentDriverVC() {
        
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let driverVC = storyboard.instantiateViewController(withIdentifier: "DriverVC")
        
        let navigationController = UINavigationController(rootViewController: driverVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func presentRiderVC() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let riderVC = storyboard.instantiateViewController(withIdentifier: "riderSID")
        let navigationController = UINavigationController(rootViewController: riderVC)
        self.present(navigationController, animated: true, completion: nil)
        //self.present(riderVC, animated: true, completion: nil)
    }
    func riderValue(){
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        print("hey")
        let userPath = ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
            let ridDri = (snapshot.value as? NSDictionary)?["isRider"] as? String?
            print(ridDri as Any)
            self.riderVal = ridDri! as? String
            self.pageDecider()
            
        })
    }
    
    }
