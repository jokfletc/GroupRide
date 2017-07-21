//
//  RiderOrDriver.swift
//  ResumeProject
//
//  Created by john fletcher on 6/9/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import Foundation
import Firebase


class RiderOrDriver {
    
    fileprivate var _isRider:String!
    fileprivate var _uid:String!
    
    
    var isRider: String {
        
        return _isRider
    }
    
    var uid:String {
        return _uid
    }
    
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>){
        
        
        self._uid = uid
        
        if let valueOfRiderBool = dictionary["isRider"] as? String {
            
            self._isRider = valueOfRiderBool
        }
        
        
    }
    
    
}
