//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class BuildingLocSetting : NSObject{
    private var ID:String;
    private var boundary:[Point];
    private var operationMode:[String];
    private var siteSignalMode:[String];
    private var cloudLocSignalMode:[String];
    private var relatedGridList:[String];
    private var remoteSignalDownloadURL:URL?;
    private var remoteCloudLocUploadURL:URL?;
    private var remoteCloudLocDownloadURL:URL?;
    private var remoteCloudSignalModeURL:URL?;
    
    public init( ID:String, boundary:[Point], operationMode:[String], siteSignalMode:[String],
                               cloudLocSignalMode:[String],  relatedGridList:[String], remoteSignalDownloadURL:URL?,
                               remoteCloudLocUploadURL:URL?,  remoteCloudLocDownloadURL:URL?, remoteCloudSignalModeURL:URL?) {
            self.ID = ID;
            self.boundary = boundary;
            self.operationMode = operationMode;
            self.siteSignalMode = siteSignalMode;
            self.cloudLocSignalMode = cloudLocSignalMode;
            self.relatedGridList = relatedGridList;
            self.remoteSignalDownloadURL = remoteSignalDownloadURL;
            self.remoteCloudLocUploadURL = remoteCloudLocUploadURL;
            self.remoteCloudLocDownloadURL = remoteCloudLocDownloadURL;
            self.remoteCloudSignalModeURL = remoteCloudSignalModeURL;
        }
    
    
    public func getID() -> String {
        return ID;
    }
    public func setID( iD:String) {
        self.ID = iD;
    }
    
    public func getBoundary() -> [Point]{
        return boundary;
    }
    public func setBoundary( boundary:[Point]) {
        self.boundary = boundary;
    }
    
    public func getOperationMode() -> [String]{
        return operationMode;
    }
    public func setOperationMode(operationMode:[String]) {
        self.operationMode = operationMode;
    }
    
    public func getSiteSignalMode() -> [String] {
        return siteSignalMode;
    }
    public func setSiteSignalMode( siteSignalMode:[String]) {
        self.siteSignalMode = siteSignalMode;
    }
    
    public func getCloudLocSignalMode() -> [String] {
        return cloudLocSignalMode;
    }
    public func setCloudLocSignalMode( cloudLocSignalMode:[String]) {
        self.cloudLocSignalMode = cloudLocSignalMode;
    }
    
    public func getRelatedGridList() ->[String]{
        return relatedGridList;
    }
    public func setRelatedGridList(relatedGridList:[String]) {
        self.relatedGridList = relatedGridList;
    }
    
    public func getRemoteSignalDownloadURL() ->URL? {
        return remoteSignalDownloadURL;
    }
    public func setRemoteSignalDownloadURL( remoteSignalDownloadURL: URL?) {
        self.remoteSignalDownloadURL = remoteSignalDownloadURL;
    }
    
    public func getRemoteCloudLocUploadURL()->URL? {
        return remoteCloudLocUploadURL;
    }
    public func setRemoteCloudLocUploadURL( remoteCloudLocUploadURL:URL?) {
        self.remoteCloudLocUploadURL = remoteCloudLocUploadURL;
    }
    
    public func getRemoteCloudLocDownloadURL()->URL? {
        return remoteCloudLocDownloadURL;
    }
    public func setRemoteCloudLocDownloadURL( remoteCloudLocDownloadURL: URL?) {
        self.remoteCloudLocDownloadURL = remoteCloudLocDownloadURL;
    }

    public func getRemoteCloudSignalModeURL()->URL? {
        return remoteCloudSignalModeURL;
    }

    public func setRemoteCloudSignalModeURL( remoteCloudSignalModeURL:URL) {
        self.remoteCloudSignalModeURL = remoteCloudSignalModeURL;
    }
}
