//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class Point:NSObject {
    private var lat : Double;
    private var lon : Double;
    
    public init(lat:Double,lon:Double) {
        self.lat = lat;
        self.lon = lon;
    }
    public func getLat() -> Double{
        return lat;
    }
    
    public func setLat(lat:Double){
        self.lat=lat;
    }
    public func getLon() -> Double{
        return lon;
    }
    
    public func setLon(lon:Double){
        self.lon=lon;
    }
}
