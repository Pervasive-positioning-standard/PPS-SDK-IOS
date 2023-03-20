//
//  BLE.swift
//
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class BLE : NSObject{
    private var UUID:String;
    private var major:String;
    private var minor:String;
    private var rssi:Int;
    private var txPower:Int;
    
    public init(UUID:String,major:String,minor:String,rssi:Int,txPower:Int) {
        self.UUID = UUID;
        self.major = major;
        self.minor = minor;
        self.rssi = rssi;
        self.txPower = txPower;
    }
    
    public func getUUID() -> String{
        return UUID;
    }
    public func setUUID(uUID:String) {
        self.UUID = uUID;
    }
    public func getMajor() -> String{
        return major;
    }
    public func setMajor(major:String) {
        self.major = major;
    }
    public func getMinor() -> String{
        return minor;
    }
    public func setMinor(minor:String) {
        self.minor = minor;
    }
    public func getRssi() -> Int{
        return rssi;
    }
    public func setRssi(rssi:Int) {
        self.rssi = rssi;
    }
    
    public func getTxPower() -> Int{
        return txPower;
    }
    public func setTxPower(txPower:Int) {
        self.txPower = txPower;
    }
    
    
}
