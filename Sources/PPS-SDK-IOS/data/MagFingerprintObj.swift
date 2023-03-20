//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class MagFingerprintObj :SignalObj{
    private var magneticVecList:[Magnetic];
        
    public init( ID:String,  coordinate:Point,  floorID:String,  magneticVecList:[Magnetic]) {
        self.magneticVecList = magneticVecList;
        super.init(ID: ID, coordinate: coordinate, floorID: floorID)
    }

    public func getMagneticVecList()->[Magnetic] {
        return magneticVecList;
    }

    public func setMagneticVecList(magneticVecList:[Magnetic]) {
        self.magneticVecList = magneticVecList;
    }
}
