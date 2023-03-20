//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class Location : Point{
    private var floorID:String;
    public init(lat:Double,lon:Double,floorID:String){
        self.floorID = floorID;
        super.init(lat: lat, lon: lon)
    }
    public func getFloorID() -> String{
        return floorID;
    }
    
    public func setFloorID(floorID:String){
        self.floorID = floorID;
    }
}
