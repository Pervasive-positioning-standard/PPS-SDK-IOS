//
//  File.swift
//
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class ReceivedBLESignal:BLE{
    private var timestamp: Int64;
    public init(UUID:String,major:String,minor:String,rssi:Int,txPower:Int,timestamp:Int64) {
        self.timestamp = timestamp;
        super.init(UUID: UUID, major: major, minor: minor, rssi: rssi, txPower: txPower);
    }
    public func getTimestamp() -> Int64{
        return timestamp
    }
    public func setTimestamp(timestamp:Int64){
        self.timestamp = timestamp
    }
}
