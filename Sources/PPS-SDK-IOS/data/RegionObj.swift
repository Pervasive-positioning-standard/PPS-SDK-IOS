//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation


public class RegionObj : SpatialObj{
    private var parentID:String;
    
    public init(ID:String,  name:String, mapDataID:[String]?, connectedList:[Connection],  parentID:String) {
        self.parentID = parentID;
        super.init(ID: ID, name: name, mapDataID: mapDataID, connectedList: connectedList)
    }

    public func getParentID() ->String{
        return parentID;
    }

    public func setParentID( parentID:String) {
        self.parentID = parentID;
    }
}
