//
//  rideDetailsVC.swift
//  ResumeProject
//
//  Created by john fletcher on 6/25/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class rideDetails {
    
    fileprivate var _username:String!
    fileprivate var _key:String!
    fileprivate var _group:String!
    
    
    fileprivate var _destLat: CLLocationDegrees!
    fileprivate var _destLong: CLLocationDegrees!
    fileprivate var _destinationLocation: CLLocation!
    fileprivate var _driverUsername: String!
    fileprivate var _destinationName: String!
    fileprivate var _destinationAddress: String!
    fileprivate var _destinationZIP: String!
    fileprivate var _acceptDate: String!
    fileprivate var _accptTime: String!
    
    
    var username:String {
        
        return _username
        
    }
    
    
    var key:String {
        
        return _key
    }
    
    var group:String {
        
        return _group
    }
    
    
    var destLat:CLLocationDegrees{
        return self._destLat
    }
    
    var destLong:CLLocationDegrees{
        return self._destLong
    }
    
    var destinationLocation:CLLocation{
        return self._destinationLocation
    }
    
    var driverUsername:String{
        return self._driverUsername
    }
    
    
    
    var destinationName:String{
        return self._destinationName
    }
    
    var destinationAddress:String{
        return self._destinationAddress
    }
    
    var destinationZIP:String{
        return self._destinationZIP
    }
    
    var acceptDate:String{
        return self._acceptDate
    }
    
    var acceptTime:String{
        return self._accptTime
    }
    
    init(uid:String, dictionary: Dictionary<String, AnyObject>, tView:UITableView){
        
        self._key  = uid
        if let userName = dictionary["Username"] as? String {
            self._username = userName
            
        }
        
        if let groupName = dictionary["Group"] as? String {
            
            self._group = groupName
        }
        
        if let dLat = dictionary["Destination Latitude"] as? Double{
            self._destLat = dLat
        }
        
        if let dLong = dictionary["Destination Longitude"] as? Double{
            self._destLong = dLong
        }
        
        if let driverUser = dictionary["driverUsername"] as? String{
            self._driverUsername = driverUser
        }
        
        if let destName = dictionary["Destination Place"] as? String{
            self._destinationName = destName
        }
        
        
        if let destAddress = dictionary["Destination Address"] as? String{
            self._destinationAddress = destAddress
        }
        
        if let destZIP = dictionary["Destination ZIP"] as? String{
            self._destinationZIP = destZIP
        }
        
        if let acDate = dictionary["Accept Date"] as? String{
            self._acceptDate = acDate
        }
        
        if let acTime = dictionary["Accept Time"] as? String{
            self._accptTime = acTime
        }
        
        
        let dLocation = CLLocation(latitude: self.destLat, longitude: self.destLong)
        self._destinationLocation = dLocation
        
        
        
        
        tView.reloadData()
        
    }
}
