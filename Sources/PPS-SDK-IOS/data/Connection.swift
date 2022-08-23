//
//  File.swift
//  
//
//  Created by mtrec_mbp on 28/7/2022.
//

import Foundation

public class Connection : NSObject{
    private var transitionArea: [Point];
    private var arrivalAreaList: [ArrivalArea];
    
    public init(transitionArea:[Point],arrivalAreaList:[ArrivalArea]) {
        self.transitionArea = transitionArea;
        self.arrivalAreaList = arrivalAreaList;
    }
    
    public func getTransitionArea() -> [Point] {
        return transitionArea;
    }

    public func setTransitionArea(transitionArea:[Point]) {
        self.transitionArea = transitionArea;
    }

    public func getArrivalAreaList() -> [ArrivalArea] {
        return arrivalAreaList;
    }

    public func setArrivalAreaList(arrivalAreaList:[ArrivalArea]) {
        self.arrivalAreaList = arrivalAreaList;
    }
}
