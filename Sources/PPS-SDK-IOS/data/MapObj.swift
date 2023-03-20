//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation


public class MapObj :NSObject{
    private var ID:String;
    private var mapType:String;
    private var geodetic:[GeodeticPoint];
    private var boundary:[Point];
    private var filename:String;
    private var attachedPrimalSpaceID:String;
    private var fileContent:Data;

    public init( ID:String, mapType:String, geodetic:[GeodeticPoint], boundary:[Point],fileContent:Data, filename:String, attachedPrimalSpaceID:String){
        self.ID = ID;
        self.mapType = mapType;
        self.geodetic = geodetic;
        self.boundary = boundary;
        self.fileContent = fileContent;
        self.filename = filename;
        self.attachedPrimalSpaceID = attachedPrimalSpaceID;
    }

    public func getID() ->String{
        return ID;
    }

    public func getMapType() ->String{
        return mapType;
    }

    public func getFileContent() -> Data{
        return fileContent;
    }

    public func getBoundary() ->[Point]{
        return boundary;
    }

    public func getGeodetic() ->[GeodeticPoint]{
        return geodetic;
    }

    public func getAttachedPrimalSpaceID() ->String{
        return attachedPrimalSpaceID;
    }

    public func getFilename() ->String{
        return filename;
    }

    public func setID( ID:String) {
        self.ID = ID;
    }

    public func setFileContent( fileContent:Data) {
        self.fileContent = fileContent;
    }

    public func setGeodetic( geodetic:[GeodeticPoint]) {
        self.geodetic = geodetic;
    }

    public func setMapType( mapType:String) {
        self.mapType = mapType;
    }
    
    public func setBoundary(boundary:[Point]) {
        self.boundary = boundary;
    }

    public func setAttachedPrimalSpaceID( attachedPrimalSpaceID:String) {
        self.attachedPrimalSpaceID = attachedPrimalSpaceID;
    }

    public func setFilename( filename:String) {
        self.filename = filename;
    }
}
