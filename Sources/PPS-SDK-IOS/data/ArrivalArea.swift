//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class ArrivalArea : NSObject{
    private var arrivalArea : [Point];
    private var connectedID : String;
    
    public init(arrivalArea:[Point],connectedID:String){
        self.arrivalArea=arrivalArea;
        self.connectedID=connectedID;
    }
    
    public func getArrivalArea() -> [Point]{
        return arrivalArea;
    }
    
    public func setArrivalArea(arrivalArea:[Point]){
        self.arrivalArea=arrivalArea;
    }
    
    public func getConnectedID() -> String{
        return connectedID
    }
    
    public func setConnectedID(connectedID:String){
        self.connectedID=connectedID;
    }
}
