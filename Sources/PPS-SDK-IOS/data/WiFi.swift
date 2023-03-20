//
//  WiFi.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class WiFi : NSObject{
    private var mac:String;
    private var rssi:Int;
    private var freq:Int;
    
    public init(mac:String,rssi:Int,freq:Int) {
        self.mac = mac;
        self.rssi = rssi;
        self.freq = freq;
    }
    
    public func getMac() -> String{
        return mac;
    }
    public func setMac(mac:String) {
        self.mac = mac;
    }
    public func getRssi() -> Int{
        return rssi;
    }
    public func setRssi(rssi:Int) {
        self.rssi = rssi;
    }
    
    public func getFreq() -> Int{
        return freq;
    }
    public func setFreq(freq:Int) {
        self.freq = freq;
    }
    
    
}
