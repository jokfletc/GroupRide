//
//  DriverVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/9/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class DriverVC: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var requests = [Requests]()
    var locationManager:CLLocationManager!
    var driverVal: String!
    var driverGroupVal: String!
    var riderGroupVal: String!
    var message: String! = "No"
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
            
            self.requests.sort(by: {$0.distanceFromDriver < $1.distanceFromDriver})
            
            cell.textLabel?.text = String(format: "%.01f mi \(self.requests[(indexPath as NSIndexPath).row].username)", self.requests[(indexPath as NSIndexPath).row].distanceFromDriver)
        }else{
            
            
            self.requests = []
            self.tableView.reloadData()
            
        }
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DriverLogout" {
            
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
            try! FIRAuth.auth()!.signOut()
            
            print("User has been logged Out")
            
            
        }else if segue.identifier == "detailRequest"{
            
            if let destinationVC = segue.destination as? RequestDetailVC {
                
                destinationVC.latitude = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].latitude
                destinationVC.longitude = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].longitude
                destinationVC.username = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].username
                destinationVC.key = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].key
                destinationVC.riderLocation = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].location
                destinationVC.group = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].group
                destinationVC.distanceFromDriver = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].distanceFromDriver
                destinationVC.destLat = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].destLat
                destinationVC.destLong = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].destLong
                destinationVC.destinationLocation = self.requests[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row].destinationLocation
                
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if FIRAuth.auth()?.currentUser != nil{
            self.driverGroup()
            let user = FIRAuth.auth()?.currentUser?.uid
            
            var loc = locations.last
            if FIRAuth.auth()?.currentUser != nil {
                let uref = FIRDatabase.database().reference().child("PickupNotification")
                uref.observe(.value, with:  { (snapshot) in
                    
                    
                    var exist = snapshot.exists()
                    
                    if exist {
                        
                        self.requests = []
                        
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            
                            
                            for snap in snapshots {
                                
                                if let riderVal = (snap.value as? NSDictionary)?["Group"] as? String{
                                    self.riderGroupVal = riderVal
                                    
                                    if self.riderGroupVal == self.driverGroupVal{
                                        
                                        
                                        if (snap.value as? NSDictionary)?["driverAccepted"] as? String == nil {
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            if let requestDictionary = snap.value as? Dictionary<String, AnyObject> {
                                                
                                                let currentLocation = CLLocation(latitude: loc!.coordinate.latitude, longitude: loc!.coordinate.longitude)
                                                
                                                let request = Requests(uid: snap.key, dictionary:requestDictionary, driverLocation: currentLocation, tView: self.tableView)
                                                
                                                self.requests.insert(request, at: 0)
                                                
                                                self.tableView.reloadData()
                                                
                                                
                                            }
                                            
                                            
                                            
                                            
                                            
                                        }else{
                                            
                                            
                                            
                                            self.driverEmailValue()
                                            
                                            
                                            if let accepted = (snap.value as? NSDictionary)?["driverAccepted"] as? String{
                                                
                                                if let driverEmail = self.driverVal {
                                                    
                                                    if accepted == driverEmail {
                                                        if snap.key != user {
                                                            
                                                            
                                                            
                                                            let reference = FIRDatabase.database().reference().child("DriverLocation")
                                                            reference.child(snap.key).child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["driverLat": loc!.coordinate.latitude, "driverLong": loc!.coordinate.longitude])
                                                            
                                                            self.tableView.reloadData()
                                                        }
                                                    }
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
                        
                        if self.message != "Yes"{
                            
                            var riderDataAlert = UIAlertController(title: "Error with Snapshot Request", message: "No Pickup Request to Retrieve Data \n LogOut and Try Again, Thank You!", preferredStyle: UIAlertControllerStyle.alert)
                            riderDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                
                                self.message = "Yes"
                            }))
                            self.present(riderDataAlert, animated: true, completion: nil)
                        }
                    }
                    
                })
            }
        }
    }
    
    func driverEmailValue(){
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil {
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let driEmail = (snapshot.value as? NSDictionary)?["Email"] as! String
                self.driverVal = driEmail
            })
        }
    }
    func driverGroup() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let driGroup = (snapshot.value as? NSDictionary)?["Group"] as! String
                self.driverGroupVal = driGroup
            })
        }
        
    }
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
