//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class FloorObj: SpatialObj{
    
    private var floorNo:String;
    private var parentID:String;
    private var regionList:[RegionObj];
    private var defaultRegionID:String;

    public init( ID:String,  name:String, mapDataID:[String]?, connectedList:[Connection], floorNo:String,
                 parentID:String, regionList:[RegionObj], defaultRegionID :String){
        
        self.floorNo = floorNo;
        self.parentID=parentID;
        self.regionList = regionList;
        self.defaultRegionID = defaultRegionID;
        super.init(ID: ID, name: name, mapDataID: mapDataID, connectedList: connectedList)
    }

    public func getFloorNo() ->String{
        return floorNo;
    }

    public func getDefaultRegionID()->String {
        return defaultRegionID;
    }

    public func getRegionList() ->[RegionObj]{
        return regionList;
    }

    public func setDefaultRegionID( defaultRegionID:String) {
        self.defaultRegionID = defaultRegionID;
    }

    public func setRegionList( regionList:[RegionObj]) {
        self.regionList = regionList;
    }

    public func setFloorNo( floorNo:String) {
        self.floorNo = floorNo;
    }

    public func getParentID() ->String{
        return parentID;
    }

    public func setParentID( parentID:String) {
        self.parentID = parentID;
    }
}
