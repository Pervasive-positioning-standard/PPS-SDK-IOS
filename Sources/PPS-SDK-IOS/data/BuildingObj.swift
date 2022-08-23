//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class BuildingObj: SpatialObj{
    
    private var floorList:[FloorObj];
    private var defaultFloorID:String;

    public init( ID:String,  name:String, mapDataID:[String]?, connectedList:[Connection], floorList:[FloorObj],  defaultFloorID:String){
        
        self.floorList = floorList;
        self.defaultFloorID = defaultFloorID;
        super.init(ID: ID, name: name, mapDataID: mapDataID, connectedList: connectedList)
    }

    public func getFloorList() ->[FloorObj]{
        return floorList;
    }

    public func getDefaultFloorID() -> String {
        return defaultFloorID;
    }

    public func setFloorList(floorList:[FloorObj]){
        self.floorList = floorList;
    }

    public func setDefaultFloorID( defaultFloorID:String) {
        self.defaultFloorID = defaultFloorID;
    }
}
