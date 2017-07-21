//
//  DestinationMapVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/28/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import MapKit
import Firebase



protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}
class DestinationMapVC: UIViewController, UITextFieldDelegate {
    var selectedPin:MKPlacemark? = nil
    
    
    var locationManager = CLLocationManager()
    var latitude:CLLocationDegrees = 0
    var longitude:CLLocationDegrees = 0
    
    
    var pickupNotificationOn = false
    
    
    var driverLatitude: CLLocationDegrees = 0.0
    var driverLongitude: CLLocationDegrees = 0.0
    var tracker = 0
    
    var riderUsername: String?
    var riderGroup: String!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickMeUp: UIButton!
    
    
    var resultSearchController:UISearchController? = nil
    
    
    var destinationLat: Double!
    var destinationLong: Double!
    var destinationName: String!
    var destinationAddress: String!
    var destinationZIP: String!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.pickupNotificationOn)
        self.riderEntryGroup()
        self.grabUsername()
        self.displayUserLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    
    
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    
    //RiderVC
    
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
                    
                    self.showAlert("Error occured saving location to Firebase", message: "We have an error")
                    
                    
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
    
    func displayUserLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RiderVC" {
            
            
            try! FIRAuth.auth()!.signOut()
            self.navigationController?.isNavigationBarHidden = true
            
            print("User has been logged Out")
        }
        if segue.identifier == "MapToMenu"{
            navigationController?.topViewController?.title = "Back"
            navigationController?.isNavigationBarHidden = false
        }
        
    }
    
    
    
    //End
    
}






extension DestinationMapVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        self.latitude = locationValue.latitude
        self.longitude = locationValue.longitude
        
        
        
        print("Latitude: \(locationValue.latitude) Longitude: \(locationValue.longitude)")
        
        if FIRAuth.auth()?.currentUser != nil {
            
            let newRef = FIRDatabase.database().reference().child("PickupNotification").child((FIRAuth.auth()?.currentUser?.uid)!)
            
            newRef.observe(.value, with: { snapshot in
                
                
                if (snapshot.value as? NSDictionary)?["driverAccepted"] as? String != nil{
                    print("one")
                    
                    
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
                                
                                
                                //self.mapView.removeAnnotations(self.mapView.annotations)
                                
                                /*var riderPin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
                                 var riderAnnotation = MKPointAnnotation()
                                 riderAnnotation.coordinate = riderPin
                                 riderAnnotation.title = "Rider's Location"
                                 self.mapView.addAnnotation(riderAnnotation)
                                 */
                                let driverPin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.driverLatitude, self.driverLongitude)
                                let driverAnnotation = MKPointAnnotation()
                                driverAnnotation.coordinate = driverPin
                                driverAnnotation.title = "Driver's Location"
                                self.mapView.addAnnotation(driverAnnotation)
                                
                                //let annotations = [riderAnnotation, driverAnnotation]
                                
                                self.mapView.showsUserLocation = true
                                
                                
                                
                                let centerOfMap = CLLocationCoordinate2D(latitude: ((locationValue.latitude + self.driverLatitude)/2), longitude: ((locationValue.longitude + self.driverLongitude)/2))
                                let region = MKCoordinateRegion(center: centerOfMap, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                                self.mapView.setRegion(region, animated: true)
                                
                                
                                let driverLocation = CLLocation(latitude: self.driverLatitude, longitude: self.driverLongitude)
                                let riderLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
                                
                                
                                let distanceInKM = driverLocation.distance(from: riderLocation)
                                let miles = (distanceInKM / 1000) * 0.62137
                                
                                
                                
                                self.pickMeUp.setTitle(String(format: "Driver is %.01f miles away\n \nPress To Cancel Ride", miles), for: UIControlState())
                                
                                
                                
                                if self.tracker < 1 {
                                    //self.mapView.showAnnotations(annotations, animated: true)
                                }
                                self.tracker = 1
                                
                                
                                
                                
                            }
                            
                        }
                    })
                    
                }else{
                    
                    
                    print("Hello!")
                    let centerOfMap = CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude)
                    let region = MKCoordinateRegion(center: centerOfMap, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    self.mapView.setRegion(region, animated: true)
                    
                    
                    
                    self.tracker = 0
                    
                }
                
            })
        }
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}


extension DestinationMapVC: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        
        
        self.destinationName = placemark.name
        
        self.destinationAddress = placemark.thoroughfare
        self.destinationZIP = placemark.postalCode
        
        
        
        
        self.destinationLat = annotation.coordinate.latitude
        self.destinationLong = annotation.coordinate.longitude
        
        
        let locationForRider: [String: AnyObject] = ["Destination Latitude":self.destinationLat as AnyObject, "Destination Longitude":self.destinationLong as AnyObject,"Destination Place":self.destinationName as AnyObject, "Destination Address":self.destinationAddress as AnyObject,"Destination ZIP":self.destinationZIP as AnyObject]
        
        let destinationLocation = ["Destination Latitude":self.destinationLat, "Destination Longitude":self.destinationLong,"Destination Place":self.destinationName, "Destination Address":self.destinationAddress,"Destination ZIP":self.destinationZIP] as [String : Any]
        
        let destRef = FIRDatabase.database().reference()
        
        destRef.child("PickupNotification").child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(locationForRider)
        
        destRef.child("Destination Location").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(destinationLocation, withCompletionBlock: { (error, result) in
            if error != nil{
                self.showAlert("Destination Location", message: "Error Saving Location")
            }else{
                print("Destination Location saved successfully!")
            }
        })
        
        
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension DestinationMapVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.blue
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
        button.addTarget(self, action: #selector(DestinationMapVC.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
