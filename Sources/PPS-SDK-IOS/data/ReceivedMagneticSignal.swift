//
//  File.swift
//
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class ReceivedMagneticSignal:Magnetic{
    private var timestamp: Int64;
    public init(mag_x:Double,mag_y:Double,mag_z:Double,timestamp:Int64) {
        self.timestamp = timestamp;
        super.init(mag_x: mag_x, mag_y: mag_y, mag_z: mag_z)
     
    }
    public func getTimestamp() -> Int64{
        return timestamp
    }
    public func setTimestamp(timestamp:Int64){
        self.timestamp = timestamp
    }
}
