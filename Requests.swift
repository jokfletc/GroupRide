//
//  Requests.swift
//  ResumeProject
//
//  Created by john fletcher on 6/12/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class Requests {
    
    fileprivate var _username:String!
    fileprivate var _key:String!
    fileprivate var _group:String!
    var distanceFromDriver:Double! = 0.0
    fileprivate var _latitude: CLLocationDegrees!
    fileprivate var _longitude:CLLocationDegrees!
    fileprivate var _location:CLLocation!
    fileprivate var _driverLocation:CLLocation!
    fileprivate var _destLat: CLLocationDegrees!
    fileprivate var _destLong: CLLocationDegrees!
    fileprivate var _destinationLocation: CLLocation!
    
    var username:String {
        
        return _username
        
    }
    
    
    var key:String {
        
        return _key
    }
    
    var group:String {
        
        return _group
    }
    
    var latitude:CLLocationDegrees{
        
        return _latitude
        
    }
    
    var longitude:CLLocationDegrees{
        
        return _longitude
    }
    
    var location:CLLocation{
        return self._location
        
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
    
    init(uid:String, dictionary: Dictionary<String, AnyObject>, driverLocation:CLLocation, tView:UITableView){
        
        self._key  = uid
        self._driverLocation = driverLocation
        
        if let lat = dictionary["Latitude"] as? Double {
            
            self._latitude = lat
            
        }
        
        
        if let long = dictionary["Longitude"] as? Double {
            self._longitude = long
            
            
        }
        
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
        
        let dLocation = CLLocation(latitude: self._destLat , longitude: self._destLong)
        self._destinationLocation = dLocation
        
        let riderLocation = CLLocation(latitude: self._latitude, longitude: self._longitude)
        self._location = riderLocation
        
        let distanceInKM = _driverLocation.distance(from: riderLocation)
        
        let miles = (distanceInKM / 1000) * 0.62137
        self.distanceFromDriver = miles
        tView.reloadData()
        
        
    }
    
}
