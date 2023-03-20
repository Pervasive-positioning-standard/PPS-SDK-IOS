//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class SignalObj : NSObject{
    private var ID : String;
    private var coordinate : Point;
    private var floorID: String;
    
    public init(ID:String,coordinate:Point,floorID:String){
        self.ID = ID;
        self.coordinate = coordinate;
        self.floorID = floorID
    }
    
    public func getID() -> String{
        return ID;
    }
    public func setID( iD:String) {
        self.ID = iD;
    }
    
    public func getCoordinate() -> Point {
        return coordinate;
    }
    public func setCoordinate(coordinate:Point) {
        self.coordinate = coordinate;
    }
    
    public func getFloorID() -> String{
        return floorID;
    }
    public func setFloorID( floorID:String) {
        self.floorID = floorID;
    }
}
