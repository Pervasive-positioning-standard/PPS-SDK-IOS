//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class GridObj : NSObject{
    private var ID : String;
    private var boundary : [Point]
    private var connectedGridID: [String]
    
    public init(ID:String,boundary:[Point],connectedGridID:[String]){
        self.ID = ID;
        self.boundary = boundary;
        self.connectedGridID = connectedGridID;
    
    }
    
    public func getID() -> String {
        return ID;
    }
    public func setID( iD:String) {
        ID = iD;
    }
    
    public func getBoundary()->[Point] {
        return boundary;
    }
    public func setBoundary(boundary:[Point]) {
        self.boundary = boundary;
    }
    
    public func getConnectedGridID() -> [String] {
        return connectedGridID;
    }
    public func setConnectedGridID(connectedGridID:[String]) {
        self.connectedGridID = connectedGridID;
    }
    
}
