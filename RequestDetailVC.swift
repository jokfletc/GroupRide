//
//  RequestDetailVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/14/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class RequestDetailVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    
    var latitude:CLLocationDegrees!
    var longitude:CLLocationDegrees!
    var username:String!
    var key:String!
    var group:String!
    var riderLocation:CLLocation!
    var driverVal:String!
    var distanceFromDriver: Double!
    var destLat:CLLocationDegrees!
    var destLong:CLLocationDegrees!
    var destinationLocation:CLLocation!
    var driverUsername: String!
    var acceptTime: String!
    var acceptDate: String!
    var destName: String!
    var pickupLocation: String!
    var pickupZIP: String!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.driverEmailValue()
        self.driverUser()
        
        
        print("We're in Requests DetailVC")
        
        
        let centerOfMap = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let region = MKCoordinateRegion(center: centerOfMap, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let locationOfPin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationOfPin
        annotation.title = self.username
        self.mapView.addAnnotation(annotation)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func acceptRequest(_ sender: UIButton) {
        self.destinationName()
        let currentDate = Date()
        
        
        self.acceptTime = currentDate.toShortTimeString()
        self.acceptDate = currentDate.toMediumDateString()
        
        let ref = FIRDatabase.database().reference()
        if let email = self.driverVal {
            
            let accepted = ["driverAccepted":email,"driverUsername": self.driverUsername, "Accept Date": self.acceptDate, "Accept Time":self.acceptTime]
            
            ref.child("PickupNotification").child(self.key!).updateChildValues(accepted)
            ref.child("Destination Location").child(self.key!).updateChildValues(accepted)
            
            
            CLGeocoder().reverseGeocodeLocation(self.riderLocation, completionHandler: { (placemarks, error ) in
                
                
                if error != nil {
                    
                    
                    print(error!)
                    self.showAlert("GeoCoder Error", message: "Error grabbing Rider's Location")
                    
                }else{
                    
                    
                    if placemarks!.count > 0 {
                        
                        
                        let placemark = placemarks![0] as? CLPlacemark
                        let mkPlacemark = MKPlacemark(placemark: placemark!)
                        self.pickupLocation = mkPlacemark.thoroughfare! ?? ""
                        self.pickupZIP = mkPlacemark.postalCode!
                        
                        let ref = FIRDatabase.database().reference()
                        let rideInfo = ["driverAccepted":email,"Rider":self.username,"Group":self.group,"Driver Username":self.driverUsername,"Date":self.acceptDate,"Time":self.acceptTime,"Pickup Address":self.pickupLocation,"Pickup ZIP": self.pickupZIP ,"Destination Location": self.destName]
                        print(rideInfo)
                        ref.child("RideInformation").child(self.key!).updateChildValues(rideInfo)
                        
                        let mapItem = MKMapItem(placemark: mkPlacemark)
                        mapItem.name = self.username
                        let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: options)
                        
                        
                    }else{
                        
                        self.showAlert("GeoCode Error", message: "Problem with data from GeoCoder")
                        
                    }
                    
                    
                    
                    
                }
                
                
            })
            
            
            
        }
        
        
        
    }
    
    
    func showAlert(_ title: String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func driverEmailValue(){
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
            let driEmail = (snapshot.value as? NSDictionary)?["Email"] as! String
            self.driverVal = driEmail
        })
    }
    
    
    @IBAction func riderDestination(_ sender: UIButton) {
        
        let ref = FIRDatabase.database().reference()
        
        CLGeocoder().reverseGeocodeLocation(self.destinationLocation, completionHandler: { (placemarks, error ) in
            if error != nil {
                
                
                print(error!)
                self.showAlert("GeoCoder Error", message: "Error grabbing Rider's Location")
                
            }else{
                
                
                if placemarks!.count > 0 {
                    
                    
                    let placemark = placemarks![0] as? CLPlacemark
                    let mkPlacemark = MKPlacemark(placemark: placemark!)
                    
                    
                    let mapItem = MKMapItem(placemark: mkPlacemark)
                    mapItem.name = self.username
                    let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                    
                    
                }else{
                    
                    self.showAlert("GeoCode Error", message: "Problem with data from GeoCoder for Rider Destination")
                    
                }
                
                
                
                
            }
            
            
        })
        
    }
    
    func driverUser() {
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let name = (snapshot.value as? NSDictionary)?["Username"] as! String
                self.driverUsername = name
            })
        }
        
    }
    func destinationName() {
        
        let ref = FIRDatabase.database().reference()
        
        if FIRAuth.auth()?.currentUser != nil{
            ref.child("PickupNotification").child(self.key!).observeSingleEvent(of: .value, with:  { (snapshot) in
                let name = (snapshot.value as? NSDictionary)?["Destination Place"] as! String
                self.destName = name
            })
        }
        
    }
    
    
}


extension Date
{
    func hour() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        //Return Hour
        return hour!
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        //Return Minute
        return minute!
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
    
    func day() -> Int{
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let day = components.day
        return day!
    }
    
    
    func month() -> Int{
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.month, from: self)
        let month = components.month
        return month!
    }
    
    func year() -> Int{
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.year, from: self)
        let year = components.year
        
        return year!
    }
    func toMediumDateString() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: self)
        return dateString
    }
    
}
