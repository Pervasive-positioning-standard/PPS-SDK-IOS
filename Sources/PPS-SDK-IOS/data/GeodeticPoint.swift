//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class GeodeticPoint : Point{
    private var x:Double;
    private var y:Double;
    public init(lat:Double,lon:Double,x:Double,y:Double){
        self.x = x;
        self.y = y;
        super.init(lat: lat, lon: lon)
    }
    public func getX() -> Double{
        return x;
    }
    
    public func setX(x:Double){
        self.x=x;
    }
    public func getY() -> Double{
        return y;
    }
    
    public func setY(y:Double){
        self.y=y;
    }
}
