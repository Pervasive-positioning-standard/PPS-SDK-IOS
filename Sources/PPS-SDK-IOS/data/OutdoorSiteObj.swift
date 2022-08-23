//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation


public class OutdoorSiteObj :NSObject{
    private var ID:String;
    private var name:String;
    private var Boundary:[[Double]];

    public init( ID:String,  name:String, Boundary:[[Double]]){
        self.ID=ID;
        self.name=name;
        self.Boundary = Boundary;
    }

    public func getID() ->String{
        return ID;
    }
    public func setID( ID:String) {
        self.ID = ID;
    }

    public func getName()->String {
        return name;
    }

    public func setName(String name:String) {
        self.name = name;
    }

    
    public func getBoundary()->[[Double]] {
        return Boundary;
    }

    
    public func setBoundary(Boundary:[[Double]]) {
        self.Boundary = Boundary;
    }

}
