//
//  RiderVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/4/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import Firebase
import MapKit


class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickMeUp: UIButton!
    
    var locationManager:CLLocationManager!
    var latitude:CLLocationDegrees = 0
    var longitude:CLLocationDegrees = 0
    
    
    
    var pickupNotificationOn = false
    
    var driverLatitude: CLLocationDegrees = 0.0
    var driverLongitude: CLLocationDegrees = 0.0
    var tracker = 0
    
    var riderUsername: String?
    var riderGroup: String!
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async{
            
            let ref = FIRDatabase.database().reference()
            let userID = FIRAuth.auth()?.currentUser?.uid
            ref.child("PickupNotification").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                
                if (snapshot.value as? NSDictionary)?["Destination Place"] as? String != nil || (snapshot.value as? NSDictionary)?["Latitude"] as? Double == nil || (snapshot.value as? NSDictionary)?["Latitude"] as? Double != nil {
                    if (snapshot.value as? NSDictionary)?["Destination Place"] as? String != nil{
                        
                        
                        self.pickupNotificationOn = true
                        self.pickMeUp.setTitle("Cancel", for: UIControlState())
                    }
                    if (snapshot.value as? NSDictionary)?["Latitude"] as? Double == nil{
                        
                        self.showAlert("Ride Request", message: "First: Press 'Pick Me Up'\nThen:Choose Destination with Search Button")
                    }
                    if (snapshot.value as? NSDictionary)?["Latitude"] as? Double != nil{
                        self.pickupNotificationOn = true
                        self.pickMeUp.setTitle("Cancel", for: UIControlState())
                    }
                }
            })
        }
        print(self.pickupNotificationOn)
        self.riderEntryGroup()
        self.grabUsername()
        self.displayUserLocation()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RiderVC" {
            
            
            try! FIRAuth.auth()!.signOut()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
           
            print("User has been logged Out")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func displayUserLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var locationValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        self.latitude = locationValue.latitude
        self.longitude = locationValue.longitude
        
        print("Latitude: \(locationValue.latitude) Longitude: \(locationValue.longitude)")
        
        if FIRAuth.auth()?.currentUser != nil {
            
            
            let newRef = FIRDatabase.database().reference().child("PickupNotification").child((FIRAuth.auth()?.currentUser?.uid)!)
            
            newRef.observe(.value, with: { snapshot in
                
                
                if (snapshot.value as? NSDictionary)?["driverAccepted"] as? String != nil{
                    
                    
                    
                    let driverRef = FIRDatabase.database().reference().child("DriverLocation").child((FIRAuth.auth()?.currentUser?.uid)!)
                    
                    driverRef.observe(.value, with: { driverSnapshot in
                        
                        if let snapshots = driverSnapshot.children.allObjects as? [FIRDataSnapshot] {
                            
                            
                            for snap in snapshots {
                                
                                if let dLat = (snap.value as? NSDictionary)?["driverLat"] as? Double {
                                    
                                    self.driverLatitude = dLat
                                }
                                if let dLong = (snap.value as? NSDictionary)?["driverLong"] as? Double {
                                    
                                    self.driverLongitude = dLong
                                }
                                
                                
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                
                                var riderPin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
                                var riderAnnotation = MKPointAnnotation()
                                riderAnnotation.coordinate = riderPin
                                riderAnnotation.title = "Rider's Location"
                                self.mapView.addAnnotation(riderAnnotation)
                                
                                var driverPin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.driverLatitude, self.driverLongitude)
                                var driverAnnotation = MKPointAnnotation()
                                driverAnnotation.coordinate = driverPin
                                driverAnnotation.title = "Driver's Location"
                                self.mapView.addAnnotation(driverAnnotation)
                                
                                let annotations = [riderAnnotation, driverAnnotation]
                                
                                self.mapView.showsUserLocation = true
                                
                                
                                let driverLocation = CLLocation(latitude: self.driverLatitude, longitude: self.driverLongitude)
                                let riderLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
                                
                                
                                let distanceInKM = driverLocation.distance(from: riderLocation)
                                let miles = (distanceInKM / 1000) * 0.62137
                                
                                
                                
                                self.pickMeUp.setTitle(String(format: "Driver is %.01f miles away\n \nPress To Cancel Ride", miles), for: UIControlState())
                                
                                
                                
                                if self.tracker < 1 {
                                    self.mapView.showAnnotations(annotations, animated: true)
                                }
                                self.tracker = 1
                                
                                
                                
                                
                            }
                            
                        }
                    })
                }else{
                    
                    let centerOfMap = CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude)
                    let region = MKCoordinateRegion(center: centerOfMap, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    self.mapView.setRegion(region, animated: true)
                    
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    var locationOfPin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = locationOfPin
                    annotation.title = "Rider's Location"
                    self.mapView.addAnnotation(annotation)
                    
                    self.tracker = 0
                    
                }
                
            })
        }
        
        
        
        
    }
    
    
    
    
    
    
    @IBAction func pickMeUpButton(_ sender: UIButton) {
        
        
        if self.pickMeUp.currentTitle == "Pick Me Up" || self.pickMeUp.currentTitle == "Cancel"{
            
            if self.pickMeUp.currentTitle == "Pick Me Up"{
                
                self.pickupNotificationOn = false
            }
            
            if self.pickMeUp.currentTitle == "Cancel"{
                self.pickupNotificationOn = true
            }
            
        }else{
            self.pickupNotificationOn = true
        }
        
        
        
        if pickupNotificationOn == false {
            let locationRef = FIRDatabase.database().reference()
            
            
            let locationForRider: [String: AnyObject] = ["Username":self.riderUsername! as AnyObject, "Group":self.riderGroup as AnyObject,"Latitude":self.latitude as AnyObject, "Longitude":self.longitude as AnyObject]
            
            
            
            locationRef.child("PickupNotification").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(locationForRider, withCompletionBlock: { (error, result) in
                if error != nil{
                    
                    self.showAlert("Saving location to Firebase", message: "We have an error")
                    
                    
                }else{
                    
                    print("PickupNotification saved successfully!")
                    
                    
                    
                    
                    
                    //Data has been saved to Firebase
                    if self.pickMeUp.currentTitle == "Pick Me Up"{
                        self.pickMeUp.setTitle("Cancel", for: UIControlState())
                    }
                    
                    
                }
                
                
            })
            
            
            
            
            self.pickupNotificationOn = true
            
            
        }else if self.pickupNotificationOn == true{
            let ref = FIRDatabase.database().reference()
            
            
            self.pickupNotificationOn = false
            
            
            ref.child("PickupNotification").child((FIRAuth.auth()?.currentUser?.uid)!).removeValue()
            ref.child("Destination Location").child((FIRAuth.auth()?.currentUser?.uid)!).removeValue()
            
            self.pickMeUp.setTitle("Pick Me Up", for: UIControlState())
            
            
            
            
            
            
            
        }
        
        
    }
    
    
    
    
    
    func grabUsername() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
            let userName = (snapshot.value as? NSDictionary)?["Username"] as! String
            print(userName)
            self.riderUsername = userName
        })
    }
    
    func riderEntryGroup() {
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
            let ridGroup = (snapshot.value as? NSDictionary)?["Group"] as! String
            self.riderGroup = ridGroup
        })
    }
    
    
    
    
}
