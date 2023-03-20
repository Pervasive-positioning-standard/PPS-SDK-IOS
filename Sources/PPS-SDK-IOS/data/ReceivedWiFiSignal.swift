//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class ReceivedWiFiSignal:WiFi{
    private var timestamp: Int64;
    public init(mac:String,rssi:Int,freq:Int,timestamp:Int64) {
        self.timestamp = timestamp;
        super.init(mac: mac, rssi: rssi, freq: freq);
     
    }
    public func getTimestamp() -> Int64{
        return timestamp
    }
    public func setTimestamp(timestamp:Int64){
        self.timestamp = timestamp
    }
}
