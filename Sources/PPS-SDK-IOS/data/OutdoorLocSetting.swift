//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class OutdoorLocSetting :NSObject{
    private var ID:String;
    private var boundary:[Point];
    private var operationMode:[String];
    private var signalMode:[String];
    private var relatedGridList:[String];
    private var remoteSignalDownloadURL:URL?;
    
    public init(
        ID:String, boundary:[Point], operationMode:[String], signalMode:[String],
                                    relatedGridList:[String], remoteSignalDownloadURL:URL?) {
        self.ID = ID;
        self.boundary = boundary;
        self.operationMode = operationMode;
        self.signalMode = signalMode;
        self.relatedGridList = relatedGridList;
        self.remoteSignalDownloadURL = remoteSignalDownloadURL;
    }
    
    public func getID()->String {
        return ID;
    }
    public func setID( iD:String) {
        self.ID = iD;
    }
    
    public func getBoundary()->[Point] {
        return boundary;
    }
    public func setBoundary( boundary:[Point]) {
        self.boundary = boundary;
    }
    
    public func getOperationMode() ->[String]{
        return operationMode;
    }
    public func setOperationMode( operationMode:[String]) {
        self.operationMode = operationMode;
    }
    
    public func getSignalMode() ->[String]{
        return signalMode;
    }
    public func setSignalMode(signalMode:[String]) {
        self.signalMode = signalMode;
    }
    
    public func getRelatedGridList() ->[String]{
        return relatedGridList;
    }
    public func setRelatedGridList( relatedGridList:[String]) {
        self.relatedGridList = relatedGridList;
    }
    
    public func getRemoteSignalDownloadURL() ->URL?{
        return remoteSignalDownloadURL;
    }
    public func setRemoteSignalDownloadURL( remoteSignalDownloadURL:URL) {
        self.remoteSignalDownloadURL = remoteSignalDownloadURL;
    }
    
}
