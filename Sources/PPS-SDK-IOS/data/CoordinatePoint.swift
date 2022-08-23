//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation


public class CoordinatePoint {
    var x:Double = 0.0;
    var y:Double = 0.0;
    
    public init( x:Double,  y:Double) {
        
        self.x = x;
        self.y = y;
    }

    public func getX() ->Double{
        return x;
    }

    public func setX( x:Double) {
        self.x = x;
    }

    public func getY() ->Double{
        return y;
    }

    public func setY( y:Double) {
        self.y = y;
    }
    
    
    
    
}
