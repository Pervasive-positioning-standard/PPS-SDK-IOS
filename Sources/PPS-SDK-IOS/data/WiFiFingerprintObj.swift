//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class WiFiFingerprintObj :SignalObj{
    private var rssiVecList:[WiFi];
        
    public init( ID:String,  coordinate:Point,  floorID:String,  rssiVecList:[WiFi]) {
        self.rssiVecList = rssiVecList;
        super.init(ID: ID, coordinate: coordinate, floorID: floorID)
    }

    public func getRssiVecList()->[WiFi] {
        return rssiVecList;
    }

    public func setRssiVecList(rssiVecList:[WiFi]) {
        self.rssiVecList = rssiVecList;
    }
}
