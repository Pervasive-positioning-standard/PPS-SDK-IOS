//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class Magnetic :NSObject{
    private var mag_x:Double;
    private var mag_y:Double;
    private var mag_z:Double;
    
    public init(mag_x:Double,mag_y:Double,mag_z:Double){
        self.mag_x = mag_x;
        self.mag_y = mag_y;
        self.mag_z = mag_z;
    }
    
    public func getMag_x() -> Double{
        return mag_x;
    }
    
    public func setMag_x(mag_x:Double){
        self.mag_x=mag_x;
    }
    public func getMag_y() -> Double{
        return mag_y;
    }
    
    public func setMag_y(mag_y:Double){
        self.mag_y=mag_y;
    }
    public func getMag_z() -> Double{
        return mag_z;
    }
    
    public func setMag_z(mag_z:Double){
        self.mag_z=mag_z;
    }
    
}
