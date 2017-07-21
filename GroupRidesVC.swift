//
//  GroupRidesVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/25/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import Firebase
import MapKit


class GroupRidesVC: UITableViewController, CLLocationManagerDelegate {
    
    var requests = [rideDetails]()
    var locationManager:CLLocationManager!
    var driverVal: String!
    var driverGroupVal: String!
    var riderGroupVal: String!
    var Lat:CLLocationDegrees!
    var Long:CLLocationDegrees!
    var riderUser: String!
    var currentUsername: String!
    var riderInfo: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Group Rides"
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.requests.count
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if self.requests.count >= 1 {
            
            let drove = "drove"
            let topple = "to"
            
            
            
            
            
            
            
            
            
            let userString = String(format:"%@ %@ %@ %@ %@ %@ %@", self.requests[(indexPath as NSIndexPath).row].driverUsername,drove, self.requests[(indexPath as NSIndexPath).row].username,topple, self.requests[(indexPath as NSIndexPath).row].destinationName,self.requests[(indexPath as NSIndexPath).row].acceptDate,self.requests[(indexPath as NSIndexPath).row].acceptTime)
            
            let characterNum1 = String(self.requests[(indexPath as NSIndexPath).row].driverUsername).characters.count
            let characterNum2 = String(self.requests[(indexPath as NSIndexPath).row].username).characters.count
            
            let myString:NSString = userString as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name:"ChalkboardSE-Bold", size: 11.0)!])
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange(location:0,length:characterNum1))
            
            
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange(location:(characterNum1+7),length:characterNum2))
            
            cell.textLabel?.attributedText = myMutableString
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            
            
        }else{
            
            
            self.requests = []
            self.tableView.reloadData()
            
        }
        
        
        return cell
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userGroup()
        let user = FIRAuth.auth()?.currentUser?.uid
        
        
        
        let uref = FIRDatabase.database().reference().child("PickupNotification")
        uref.observe(.value, with:  { (snapshot) in
            
            
            var exist = snapshot.exists()
            
            if exist {
                
                self.requests = []
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    
                    
                    for snap in snapshots {
                        
                        
                        
                        if let riderVal = (snap.value as? NSDictionary)?["Group"] as? String{
                            self.riderGroupVal = riderVal
                            if let riderUsername = (snap.value as? NSDictionary)?["Username"] as? String{
                                self.riderUser = riderUsername
                                
                                
                                if self.currentUsername != self.riderUser{
                                    
                                    if self.riderGroupVal == self.driverGroupVal{
                                        
                                        
                                        if (snap.value as? NSDictionary)?["driverAccepted"] as? String != nil {
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            if let requestDictionary = snap.value as? Dictionary<String, AnyObject> {
                                                
                                                
                                                
                                                let request = rideDetails(uid: snap.key, dictionary:requestDictionary,  tView: self.tableView)
                                                
                                                self.requests.insert(request, at: 0)
                                                
                                                self.tableView.reloadData()
                                                
                                                
                                            }
                                            
                                            
                                            
                                            
                                            
                                        }else{
                                            
                                            
                                            
                                            
                                            
                                            self.tableView.reloadData()
                                            
                                            
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                
            }else{
                
                self.requests = []
                self.tableView.reloadData()
                self.showAlert("Error with Snapshot Request", message: "No Pickup Request to Retrieve Data")
                
            }
            
            
        })
        
    }
    
    
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "menuPageVC")
        
        self.present(menuVC, animated: true, completion: nil)
    }
    
    
    
    
    func userGroup() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let driGroup = (snapshot.value as? NSDictionary)?["Group"] as! String
                self.driverGroupVal = driGroup
            })
        }
        
    }
    
    func userUsername() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("PickupNotification").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let username = (snapshot.value as? NSDictionary)?["Username"] as! String
                self.currentUsername = username
            })
        }
        
    }
    
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
/*
 let def = NSUserDefaults.standardUserDefaults()
 var key = "ridesArray"
 
 var array1: [NSString] = [NSString]()
 array1.append(self.riderInfo)
 
 //Save riderInfo to Array
 var defaults = NSUserDefaults.standardUserDefaults()
 defaults.setObject(array1, forKey: key)
 defaults.synchronize()
 
 //read ridesArray
 if let ridesArray : AnyObject? = defaults.objectForKey(key){
 var readArray : [NSString] = ridesArray! as! [NSString]
 print(readArray)
 }
 */
