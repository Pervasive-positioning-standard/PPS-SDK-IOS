//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class BLELocationObj :SignalObj{
    private var UUID:String;
    private var major:String;
    private var minor:String;
    private var txPower:Int;
        
    public init( ID:String,  coordinate:Point,  floorID:String,  UUID:String,  major:String,  minor:String,
                 texPower:Int){
        self.UUID = UUID;
        self.major = major;
        self.minor = minor;
        self.txPower = texPower;
        super.init(ID: ID, coordinate: coordinate, floorID: floorID)
    }

    public func getUUID() -> String{
        return UUID;
    }
    public func setUUID( uUID:String) {
        UUID = uUID;
    }
    
    public func getMajor() -> String {
        return major;
    }
    public func setMajor( major:String) {
        self.major = major;
    }
    
    public func getMinor() -> String {
        return minor;
    }
    public func setMinor( minor:String) {
        self.minor = minor;
    }
    
    public func getTexPower()->Int {
        return txPower;
    }
    public func setTexPower( texPower:Int) {
        self.txPower = texPower;
    }
}
