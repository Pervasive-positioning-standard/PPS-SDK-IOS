//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class SpatialObj : NSObject{
    private var ID:String;
    private var name:String;
    private var mapDataID:[String]?;
    private var connectedList:[Connection];

    public init( ID:String, name:String, mapDataID:[String]?, connectedList:[Connection]){
        self.ID = ID;
        self.name = name;
        self.mapDataID = mapDataID;
        self.connectedList = connectedList;
    }

    public func getID() ->String{
        return ID;
    }

    public func getName() -> String {
        return name;
    }

    public func getMapDataID() -> [String]? {
        return mapDataID;
    }

    public func getConnectedList()  -> [Connection]{
        return connectedList;
    }

    public func setConnectedList(connectedList:[Connection]) {
        self.connectedList = connectedList;
    }

    public func setID( ID:String) {
        self.ID = ID;
    }

    public func setMapDataID(mapDataID:[String]?) {
        self.mapDataID = mapDataID;
    }


    public func setName( name:String) {
        self.name = name;
    }
}
