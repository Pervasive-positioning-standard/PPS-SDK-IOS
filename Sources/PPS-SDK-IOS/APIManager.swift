//
//  File.swift
//  
//
//  Created by mtrec_mbp on 1/8/2022.
//

import Foundation
import SwiftyJSON
import Alamofire
//import UIKit

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

public class APIManager{
    
    enum APIManagerFetchError: Error, LocalizedError {
            case getJson
            case postJson
            
    }
    
    private let zoom20gridlength=0.149291071*256;
    //parameters
    
    static let shared = APIManager()
    
    let queue = DispatchQueue(label: "APIManager")
    private var manager:ServerTrustManager;
    private var session:Session;
    
    private var lookupServerAddr:String?;

    private var currentBuildingID:String?;
    private var currentBuilding:BuildingObj?;
    private var currentBuildingLocSetting:BuildingLocSetting?;
    private var connectedBuildingID:String?;
    private var connectedBuilding:BuildingObj?;
    private var connectedBuildingLocSetting:BuildingLocSetting?;
    private var currentOutdoorSite:OutdoorSiteObj?;
    private var mapObjMap:[String:MapObj] = [:];

    private var currentOutdoorLocSetting:OutdoorLocSetting?;
    private var AppID:String?;
    private var Key:String?;
    private var Token:String?;
    
    
    init(){
        lookupServerAddr = "http://16.162.42.168/api";
        manager = ServerTrustManager(evaluators: ["158.132.186.180:10020": DisabledTrustEvaluator(),"158.132.186.180": DisabledTrustEvaluator()])//only to solve poly cert
        session = Session(serverTrustManager: manager)
    }
    public static func getInstance()-> APIManager{
        return .shared
    }
    
    public func getJson(url:URL,_ completion: @escaping (_ jsonObj: JSON?) -> Void) throws {
//        let request = AF.request(
//            url.absoluteString
//        )
        let request = session.request(
            url.absoluteString
        ).response { (response) in
//            print(response.description)
            let returnObj:JSON? = JSON(response.data!)
            completion(returnObj)
        }
    }
    
    public func postJson(url:URL, json:JSON,_ completion: @escaping (_ jsonObj: JSON?) -> Void) {

        session.request(url.absoluteString, method: .post, parameters: json, encoder: JSONParameterEncoder.default).response{ response in
//            print(JSON(response.data!))
            completion(json)
        }
    }
    
    public func WebAPIForGettingOutdoorSignal(gridID:String,mode:Int,inputSignalMode:String?,_ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var signalMode = "BLELocation";
        if inputSignalMode != nil{
            signalMode = inputSignalMode!
        }
        if (mode != 0 && (currentOutdoorLocSetting != nil || currentOutdoorLocSetting?.getRemoteSignalDownloadURL() == nil)){
            completion(nil)
        }
        var inputURL:String;
        if (mode == 2){
            inputURL = lookupServerAddr!
        }else{
            inputURL = currentOutdoorLocSetting!.getRemoteSignalDownloadURL()!.absoluteString
            inputURL=inputURL+"/grid/"+gridID+"?signalMode="+signalMode;
        }
        print(inputURL)
        var returnObj: JSON? = nil;
        do{
            try  getJson(url: URL(string: inputURL)!){json in
                completion(json)
            }
        }catch{
            print("get json error in WebAPIForGettingOutdoorSignal")
        }
    }
    
    public func WebAPIToGetOutdoorSiteList( latitude:Double, longitude:Double,  accuracy:Double, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var latlon:[Double] = CoverageCalculator.cal_min_max(lat: latitude, lon: longitude, accuracy: accuracy)
        var inputURL = lookupServerAddr! + "/outdoor-siteId-and-boundary/"
        inputURL = inputURL + String(format: "%f",latlon[0]) + "/" + String(format: "%f",latlon[1])
        inputURL = inputURL + "/" + String(format: "%f",latlon[2]) + "/" + String(format: "%f",latlon[3]);
        do{
            try getJson(url: URL(string: inputURL)!){json in
                completion(json)
            }
        }catch{
            print("get json error in WebAPIToGetOutdoorSiteList")
        }
        
    }
    
    public func WebAPIToGetAllBuildingLocInConstraint( latitude:Double,  longitude:Double,  accuracy:Double, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var inputURL:String = lookupServerAddr!+"/buildingId-and-boundary/"
        inputURL = inputURL+String(format: "%f",longitude)+"/"+String(format: "%f",latitude)+"/"+String(format: "%f",accuracy);
        do {
            try  getJson( url: URL(string:inputURL)!){json in
                completion(json);
            };
        } catch {
            // TODO Auto-generated catch block
           print("get json error in WebAPIToGetAllBuildingLocInConstraint")
        }
    }
    
    public func WebAPIToGetBuildingLocSettingByBuildingID( buildingID:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var inputURL:String = lookupServerAddr!+"/building-loc-setting/"+buildingID;
        do {
            try  getJson( url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetAllBuildingLocInConstraint")
        }
    }
//
    public func WebAPIToGetOutdoorSiteSettingByOutdoorSiteID( siteID:String , _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        var inputURL:String = lookupServerAddr!+"/outdoor-loc-setting/"+siteID;
        do {
            try getJson(url:URL(string:inputURL)!){json in
                completion(json)
            };
        } catch  {
            print("get json error in WebAPIToGetOutdoorSiteSettingByOutdoorSiteID")
        }
    }
    public func WebAPIToGetGridIDOfBuilding( mode:Int, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        if(mode == 0) {
            var buildingDownloadURL:String = currentBuildingLocSetting!.getRemoteSignalDownloadURL()!.absoluteString;
           
            var inputURL:String = buildingDownloadURL+"/grid-id?zoomLevel=20";
            
            do {
                try  getJson(url: URL(string:inputURL)!){json in
                    completion(json)
                }
            } catch {
            // TODO Auto-generated catch block
                print("get json error in WebAPIToGetGridIDOfBuilding")
            }
        }
        else if(mode == 2){
            completion(nil);
            return
        }else{
            completion(nil)
            return
        }
    }
    public func  WebAPIToGetGridIDOfBuilding( buildingDownloadURL:String, mode:Int, _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        if(mode == 0) {
            var inputURL:String = buildingDownloadURL+"/grid-id?zoomLevel=20";
            do {
                try  getJson(url: URL(string:inputURL)!){json in
                    completion(json)
                };
            } catch {
                print("get json error in WebAPIToGetGridIDOfBuilding2")
            }
        }
        else if(mode == 2){
            completion(nil)
            return
        }else{
            completion(nil)
            return
        }
        
    }
    public func WebAPIToGetSpatialRepresentationObjByBuildingID( buildingID:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var inputURL:String = lookupServerAddr!+"/building-spatial-representation/"+buildingID;
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetSpatialRepresentationObjByBuildingID")
        }
        
    }
    public func WebAPIToGetSignalMode( _ completion: @escaping (_ jsonObj: JSON?) -> Void)  {
        if(currentBuildingLocSetting==nil||currentBuildingLocSetting!.getRemoteSignalDownloadURL()==nil){
            return;
        }
        var buildingDownloadURL:String = currentBuildingLocSetting!.getRemoteSignalDownloadURL()!.absoluteString;
        var inputURL:String = buildingDownloadURL+"/signal-modes";
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetSignalMode")
        }
        return ;
    }
    public func WebAPIToGetSignalMode( buildingDownloadURL:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void)  {
        var inputURL:String = buildingDownloadURL+"/signal-modes";
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetSignalMode")
        }
    }
    public func WebAPIToGetRemoteCloudSignalMode( RemoteCloudSignalModeURL:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        var inputURL:String = RemoteCloudSignalModeURL;
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetRemoteCloudSignalMode")
        }
    }
    
    public func WebAPIToDownloadSiteSignalWithSignalMode(gridId:String,  signalMode:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        var buildingDownloadURL:String = currentBuildingLocSetting!.getRemoteSignalDownloadURL()!.absoluteString;
        var inputURL:String = buildingDownloadURL + "/grid/" + gridId + "?signalMode=" + signalMode;
        do {
            try  getJson(url: URL(string:inputURL)!){ json in
                completion(json)
            };
        } catch{
            print("get json error in WebAPIToDownloadSiteSignalWithSignalMode")
        }
    }
   

    public func WebAPIToDownloadSiteSignalWithSignalMode( buildingDownloadURL:String, gridId:String, signalMode:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var inputURL:String = buildingDownloadURL + "/grid/" + gridId + "?signalMode=" + signalMode;
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToDownloadSiteSignalWithSignalMode")
        }
    }
    
    public func WebAPIToGetUserLocationFromCloud( buildingDownloadURL:String, userId:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var inputURL:String = buildingDownloadURL+"?userId=" + userId;
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetUserLocationFromCloud")
        }
    }
    public func WebAPIToGenerateToken( usr:String,  pw:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        var inputURL:String = lookupServerAddr!+"/generate-token?username="+usr+"password="+pw;
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGenerateToken")
        }
   }
//
    public func WebAPIToRefreshToken( token:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        var inputURL:String = lookupServerAddr!+"/refresh-token?token="+token;
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch{
            print("get json error in WebAPIToRefreshToken")
        }
    }

    public func WebAPIToGetMapJsonForIndoor( buildingID:String?, floorID:String?, regionID:String?, lat:Double?, lon:Double?, _ completion: @escaping (_ jsonObj: JSON?) -> Void){
        var inputURL:String = lookupServerAddr!  + "/" + "map-metadata?";
        var hostAdr:String = inputURL;

        if(buildingID != nil){
            inputURL = inputURL + "buildingId=" + buildingID!;
        }
        if(floorID != nil){
            if !(inputURL == hostAdr) {inputURL = inputURL + "&";};
            inputURL = inputURL + "floorId=" + floorID!;
        }
        if(regionID != nil){
            if !(inputURL == hostAdr){ inputURL = inputURL + "&";}
            inputURL = inputURL + "regionId=" + regionID!;
        }
        if(lat != 0 && lon != 0){
            if !(inputURL == hostAdr){ inputURL = inputURL + "&";}
            inputURL = inputURL + "lat=" + String(format: "%f", lat!) + "&lon=" + String(format: "%f", lon!) ;
        }
        
        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch  {
            print("get json error in WebAPIToGetMapJsonForIndoor")
        }
    }
    
    public func WebAPIToGetMapFile( mapID:String, _ completion: @escaping (_ jsonObj: JSON?) -> Void) {
        var inputURL:String = lookupServerAddr!  + "/map/" + mapID;

        do {
            try  getJson(url: URL(string:inputURL)!){json in
                completion(json)
            };
        } catch {
            print("get json error in WebAPIToGetMapFile")
        }
    }

    public func analyzeLocSettingJson( locSetting:JSON) ->BuildingLocSetting  {
        var returnObj :BuildingLocSetting = BuildingLocSetting(ID: "", boundary: [], operationMode: [], siteSignalMode: [], cloudLocSignalMode: [], relatedGridList: [], remoteSignalDownloadURL: nil, remoteCloudLocUploadURL: nil, remoteCloudLocDownloadURL: nil, remoteCloudSignalModeURL: nil)
            
            //Get buildingID
        var buildingID :String = locSetting["BuildingID"].stringValue;
        buildingID = buildingID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)

        returnObj.setID(iD: buildingID)
//        print(buildingID);
        
        //Get Boundary
        var boundary = locSetting["Boundary"].arrayValue;
        var returnBoundary:[Point] = [];
        for i in 0..<boundary.count{
            var latLon = boundary[i];
            var lat = latLon[1].doubleValue;
            var lon = latLon[0].doubleValue;
            
//            double lat = Double.parseDouble(latStr);
//            double lon = Double.parseDouble(lonStr);
            
            var newPoint = Point(lat: lat, lon: lon);
            returnBoundary.append(newPoint);
        }
        returnObj.setBoundary(boundary:returnBoundary);
        
        //get whether share site signal
        var shareSiteSignal = locSetting["ShareSiteSignal"].boolValue;
        print("shareSiteSignal " + shareSiteSignal.description);
        
        //Get cloudLocSignalMode
        var cloudLocSignalMode = locSetting["CloudLocSignalMode"].arrayValue;
        var rCSMURL :String;
        var returnCloudLocSignalMode:[String] = []
        if !(cloudLocSignalMode.isEmpty){
            for  i in 0..<cloudLocSignalMode.count {
                var mode = cloudLocSignalMode[i].stringValue;
                mode = mode.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                returnCloudLocSignalMode.append(mode);
            }
            returnObj.setCloudLocSignalMode(cloudLocSignalMode: returnCloudLocSignalMode);
        }
        else if let rCSMURL = locSetting["RemoteCloudSignalModeURL"].string {
            var rCSMURLStr = rCSMURL;
//            System.out.println(rCSMURLStr);
            rCSMURLStr = rCSMURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            if (!(rCSMURLStr.hasPrefix("https://") || (rCSMURLStr.hasPrefix("http://")))){ rCSMURLStr = "http://"+rCSMURLStr;};

            var returnURL:URL? = URL(string:rCSMURLStr) ?? nil;
           
            returnObj.setRemoteCloudSignalModeURL(remoteCloudSignalModeURL: returnURL!);
            
            WebAPIToGetRemoteCloudSignalMode(RemoteCloudSignalModeURL: rCSMURLStr){json in
                var rCSMJsonArray = json!["signalModes"].arrayValue;
                var remoteCloudSignalMode:[String] = [];
                for i in 0..<rCSMJsonArray.count {
                    var mode = rCSMJsonArray[i].stringValue;
                    mode = mode.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                    remoteCloudSignalMode.append(mode);
                }
                //            System.out.println(remoteCloudSignalMode);
                returnObj.setCloudLocSignalMode(cloudLocSignalMode: remoteCloudSignalMode);
                
            }
        }
        
        //Get remoteSignalDownloadURL
        var rSDURL:String = locSetting["RemoteSignalDownloadURL"].stringValue
        if !rSDURL.isEmpty {
            var rSDURLStr = rSDURL;
            rSDURLStr = rSDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            if (!(rSDURLStr.hasPrefix("https://") || (rSDURLStr.hasPrefix("http://")))){ rSDURLStr = "http://"+rSDURLStr;};

            var returnURL:URL = URL(string: rSDURLStr)!;
            
            returnObj.setRemoteSignalDownloadURL(remoteSignalDownloadURL: returnURL);
        }else{
//            print("rSDURL failed")
        }
        
        //Get remoteCloudLocUploadURL
        var rCLUURL:String = locSetting["RemoteCloudLocUploadURL"].stringValue
        if !rCLUURL.isEmpty {
            var rCLUURLStr = rCLUURL;
            rCLUURLStr = rCLUURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            if (!(rCLUURLStr.hasPrefix("https://") || (rCLUURLStr.hasPrefix("http://")))){ rCLUURLStr = "http://"+rCLUURLStr;};


            var returnURL =  URL(string:rCLUURLStr);
            
            returnObj.setRemoteCloudLocUploadURL(remoteCloudLocUploadURL: returnURL);
        }else{
//            print("rCLUURL failed")
        }
        
        //Get remoteLocDownloadURL
        var rCLDURL :String = locSetting["RemoteCloudLocDownloadURL"].stringValue
        if !rCLDURL.isEmpty{
            var rCLDURLStr = rCLDURL;
            rCLDURLStr = rCLDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            if (!(rCLDURLStr.hasPrefix("https://") || (rCLDURLStr.hasPrefix("http://")))){ rCLDURLStr = "http://"+rCLDURLStr;};

//            System.out.println(rCLDURLStr);
            var returnURL = URL(string:rCLDURLStr);
            
            returnObj.setRemoteCloudLocDownloadURL(remoteCloudLocDownloadURL: returnURL);
        }else{
//            print("rCLDURL failed")
        }
        
        
        //Use shareSiteSignal and the existence of urls to determine the operation modes
        if(shareSiteSignal) {
            var a:[String] = [];
            a.append("2");
            a.append("3");
            returnObj.setOperationMode(operationMode: a);
            //Set GridID list
            WebAPIToGetGridIDOfBuilding(mode: 2){json in
//                var gridID:JSON? =  json  ?? nil;
                //Get the relatedGridList
                if(json != nil) {
                    if let gridIDs = json!["gridIds"].array {
                        
                        var grids:[String] = [];
                        for i in 0..<gridIDs.count {
                            var current:String = gridIDs[i].stringValue;
                            current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                            grids.append(current);
                        }
                        returnObj.setRelatedGridList(relatedGridList: grids);
                    }
                }
            }
            
        }
        else {
            var a:[String] = []
            if !(rSDURL.isEmpty) {
                a.append("0");
//                print("should be mode 0")
                
                //Set gridID List
                var rSDURLStr = rSDURL;
                rSDURLStr = rSDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                
                WebAPIToGetGridIDOfBuilding(buildingDownloadURL: rSDURLStr,mode: 0){ json in
                    if let gridIDs = json!["gridIds"].array {
                        var grids:[String] = [];
                        for i in 0..<gridIDs.count {
                            var current:String = gridIDs[i].stringValue;
                            current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                            grids.append(current);
                        }
                        returnObj.setRelatedGridList(relatedGridList: grids);
                    }
                }
            }
//            print("rCLUURL"+(rCLUURL ?? "nil") )
//            print("rCLDURL"+(rCLDURL ?? "nil"))
            if !(rCLUURL.isEmpty && rCLDURL.isEmpty){
                a.append("1");
//                print("should be mode 1")
            }
            returnObj.setOperationMode(operationMode: a);
        }
        
        //Get the siteSignalMode from the server according to the operation mode
        var siteSignalMode:[JSON]=[];

        if(!shareSiteSignal ) {
            if !(rSDURL.isEmpty){
                var rSDURLStr:String = rSDURL;
                rSDURLStr = rSDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                WebAPIToGetSignalMode(buildingDownloadURL: rSDURLStr){json in
                    siteSignalMode = json!["signalModes"].arrayValue;
                }
            }
        }
        else {
            siteSignalMode = locSetting["SiteSignalMode"].arrayValue;
        }
        if(!siteSignalMode.isEmpty){
            var signalMode:[String]=[];
            for i in 0..<siteSignalMode.count{
                var mode = siteSignalMode[i].stringValue;
                mode = mode.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                signalMode.append(mode);
                returnObj.setSiteSignalMode(siteSignalMode: signalMode);
            }
        }
        return returnObj;
    }
//
    public func analyzeOutdoorLocSettingJson( locSetting:JSON)  -> OutdoorLocSetting {
            //Create the obj for returning
        var returnObj = OutdoorLocSetting(ID: "", boundary: [], operationMode: [], signalMode: [], relatedGridList: [], remoteSignalDownloadURL: nil);
            //Get the outdoorSiteID
        var siteID = locSetting["OutdoorSiteID"].stringValue;
        siteID=siteID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        returnObj.setID(iD: siteID);
        
        //Get the boundary
        var boundary = locSetting["Boundary"].arrayValue;
        var returnBoundary: [Point] = [];
        for  i in 0..<boundary.count {
            var latLon = boundary[i].arrayValue;
            var lat = latLon[1].doubleValue
            var lon = latLon[0].doubleValue
            
//            double lat = Double.parseDouble(latStr);
//            double lon = Double.parseDouble(lonStr);
            
            var newPoint:Point =  Point(lat: lat, lon: lon);
            returnBoundary.append(newPoint);
        }
        returnObj.setBoundary(boundary: returnBoundary);
        
        //Get whether the site shareSiteSignal
        var shareSiteSignal = locSetting["ShareSiteSignal"].boolValue;
        
        
        //Get remoteSignalDownloadURL
        var rSDURL:String? = nil;
        if let rSDURL = locSetting["RemoteSignalDownloadURL"].string {
            var rSDURLStr:String = rSDURL;
            rSDURLStr = rSDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            if (!(rSDURLStr.hasPrefix("https://") || (rSDURLStr.hasPrefix("http://")))){ rSDURLStr = "http://"+rSDURLStr;};

            var returnURL = URL(string:rSDURLStr)!;
          
            returnObj.setRemoteSignalDownloadURL(remoteSignalDownloadURL: returnURL);
        }
        
        //determine the operation mode according to shareSiteSignal and remoteSignalDownloadURL
        if(shareSiteSignal) {
            var a:[String] = [];
            a.append("2");

            returnObj.setOperationMode(operationMode: a);
            //Set GridID list
            WebAPIToGetGridIDOfBuilding(mode: 2){json in
                //Get the relatedGridIDList
                var gridIDs = json!["gridIds"].arrayValue;
                if(!gridIDs.isEmpty) {
                    var grids:[String] = [];
                    for  i in 0..<gridIDs.count{
                        var current = gridIDs[i].stringValue;
                        current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                        grids.append(current);
                    }
                    returnObj.setRelatedGridList(relatedGridList: grids);
                }
            };
            
        }
        else {
            var a:[String] = [];
            if (rSDURL != nil) {
                a.append("0");
                
                //Set gridID List
                var rSDURLStr = rSDURL!;
                rSDURLStr = rSDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                WebAPIToGetGridIDOfBuilding(buildingDownloadURL: rSDURLStr,mode: 0){json in
                    var gridIDs = json!["gridIds"].arrayValue;
                    if(!gridIDs.isEmpty) {
                        var grids:[String] = [];
                        for i in 0..<gridIDs.count{
                            var current = gridIDs[i].stringValue;
                            current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                            grids.append(current);
                        }
                        returnObj.setRelatedGridList(relatedGridList: grids);
                    }
                };
            }
            returnObj.setOperationMode(operationMode: a);
        }
        
        //Get the siteSignalMode from the server according to the operation mode
        var siteSignalMode:JSON? = nil;
        if(rSDURL != nil) {
            var rSDURLStr = rSDURL!;
            rSDURLStr = rSDURLStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            WebAPIToGetSignalMode(buildingDownloadURL: rSDURLStr){ json in
                siteSignalMode = json!["signalModes"];
            }
        }
        else {
            siteSignalMode = locSetting["SiteSignalMode"];
        }
        var signalMode:[String] = [];
        for i in 0..<siteSignalMode!.count {
            var mode:String = siteSignalMode![i].stringValue;
            mode = mode.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            signalMode.append(mode);
        }
        returnObj.setSignalMode(signalMode: signalMode);
        return returnObj;
    }
//
    public func analyzeSpatialRepresentationToBuildingObj( spatial:JSON)->BuildingObj{
        var returnObj =  BuildingObj(ID: "", name: "", mapDataID: nil, connectedList: [], floorList: [], defaultFloorID: "")
        
        //Get the buildingID
        var buildingJson:JSON = spatial["building"];
        
        var buildingID:String = buildingJson["BuildingID"].stringValue;
        buildingID = buildingID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setID(ID: buildingID);
        
        //Get the name of the building
        var buildingName = buildingJson["Name"].stringValue;
        buildingName = buildingName.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setName(name: buildingName);
        
        //get the mapDataID
        var buildingMapDataID:[String] = [];
        var buildingMapDataIDJson = buildingJson["MapDataID"].arrayValue;
        if(!buildingMapDataIDJson.isEmpty) {
            for i in 0..<buildingMapDataIDJson.count{
                var current = buildingMapDataIDJson[i].stringValue;
                current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                buildingMapDataID.append(current);
            }
            returnObj.setMapDataID(mapDataID: buildingMapDataID);
        }
        
        //Get the defaultFoorID
        var defaultFloorID = buildingJson["DefaultFloorNo"].stringValue;
        defaultFloorID = defaultFloorID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setDefaultFloorID(defaultFloorID: buildingID+defaultFloorID);
        
        //Create the region objs
        var allRegions:[RegionObj] = [];
        var allRegionsJson = spatial["regions"].arrayValue;
        for i in 0..<allRegionsJson.count {
            var currentRegionJson:JSON = allRegionsJson[i]["region"];
            var currentRegion:RegionObj = analyzeRegionJson(regionJson: currentRegionJson);
            allRegions.append(currentRegion);
        }
        
        
        //Create the Floor Objs using the region objs and the floor.jsons returned
        var allFloor:[FloorObj] = [];
        var allFloorJson = spatial["floors"].arrayValue;
        for i in 0..<allFloorJson.count {
            var currentFloorJson:JSON = allFloorJson[i]["floor"];
            var currentFloor:FloorObj = creatingFloorObj(floorJson: currentFloorJson, regions: allRegions);
            allFloor.append(currentFloor);
        }
        
        //Get the floorList of the building
        var possibleFloors:[String] = [];
        var floorsJson = buildingJson["FloorList"].arrayValue;
        for  i in 0..<floorsJson.count {
            var current = floorsJson[i].stringValue;
            current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            possibleFloors.append(current);
        }
        
        //Add the floorObjs to the floorList of the buildingObj if it is in the possibleFloors of the building
        var currentID = returnObj.getID();
        var floorList:[FloorObj] = [];
        for  i in 0..<possibleFloors.count{
            var currentFloorID = currentID + possibleFloors[i];
            for j in 0..<allFloor.count {
                var currentFloor:FloorObj = allFloor[i];
                if(currentFloor.getID()==currentFloorID) {
                    floorList.append(currentFloor);
                    break;
                }
            }
        }
        returnObj.setFloorList(floorList: floorList);
        
        return returnObj;
    }
////    
    public func  creatingFloorObj( floorJson :JSON , regions:[RegionObj]) ->FloorObj{
        var returnObj = FloorObj(ID: "", name: "", mapDataID: nil, connectedList: [], floorNo: "", parentID: "", regionList: [], defaultRegionID: "");
        
        //Get the floorNo and the parentID
        var floorNo = floorJson["FloorNo"].stringValue;
        floorNo = floorNo.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        var parentID = floorJson["ParentID"].stringValue;
        parentID = parentID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setID(ID: parentID+floorNo);
        returnObj.setParentID(parentID: parentID);
        returnObj.setFloorNo(floorNo: floorNo);
        
        //Get the name of the floor
        var floorName = floorJson["Name"].stringValue;
        floorName = floorName.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setName(name: floorName);
        
        //Get the defaultRegionID of the floor
        var defaultNo = floorJson["DefaultRegionNo"].stringValue
        defaultNo = defaultNo.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setDefaultRegionID(defaultRegionID: parentID+floorNo+defaultNo);
        
        //get the mapDataID of the floor
        var floorMapDataID:[String] = [];
        var floorMapDataIDJson = floorJson["MapDataID"].arrayValue
        if(!floorMapDataIDJson.isEmpty) {
            for i in 0..<floorMapDataIDJson.count {
                var current = floorMapDataIDJson[i].stringValue;
                current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                floorMapDataID.append(current);
            }
            returnObj.setMapDataID(mapDataID: floorMapDataID);
        }
        //get the ID of the floor
        var currentID = parentID + floorNo;
        //get the list of regions in the floor
        var possibleRegions:[String] = [];
        var regionsJson:[JSON] = floorJson["RegionList"].arrayValue;
        for  i in 0..<regionsJson.count{
            var current = regionsJson[i].stringValue;
            current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
            possibleRegions.append(current);
        }
        
        //add the regionObj to the regionList of the floorObj if the id of it is in the RegionList
        var regionList:[RegionObj] = [];
        for i in 0..<possibleRegions.count {
            var currentRegionID = currentID + possibleRegions[i];
            for j in 0..<regions.count {
                var currentRegion:RegionObj = regions[i];
                if(currentRegion.getID()==currentRegionID) {
                    regionList.append(currentRegion);
                    break;
                }
            }
        }
        returnObj.setRegionList(regionList: regionList);
        
        return returnObj;
    }
    
    public func analyzeRegionJson( regionJson:JSON)-> RegionObj  {
        var returnObj = RegionObj(ID: "", name: "", mapDataID: nil, connectedList: [], parentID: "");
        
        //Get the RegionNo and parentID of the region, and set the ID and parentID of the region
        var regionNo = regionJson["RegionNo"].stringValue;
        regionNo = regionNo.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        var parentID = regionJson["ParentID"].stringValue;
        parentID = parentID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setID(ID: parentID+regionNo);
        returnObj.setParentID(parentID: parentID);
        
        //Get the name of the region
        var regionName = regionJson["Name"].stringValue;
        regionName = regionName.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
        returnObj.setName(name: regionName);
        
        //Get the mapDataID of the region
        var regionMapDataID:[String] = [];
        var regionMapDataIDJson = regionJson["MapDataID"].arrayValue;
        if(!regionMapDataIDJson.isEmpty) {
            for i in 0..<regionMapDataIDJson.count {
                var current = regionMapDataIDJson[i].stringValue;
                current = current.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                regionMapDataID.append(current);
            }
            returnObj.setMapDataID(mapDataID: regionMapDataID);
        }
        
        //Get the connectedList of the region
        var connectedList:[Connection]=[];
        var connectedListJson:[JSON] = regionJson["ConnectedRegions"].arrayValue;
        for i in 0..<connectedListJson.count {
            var current:JSON = connectedListJson[i];
            var transitionArea:[Point] = [];
            var arrivalAreaList:[ArrivalArea] = []


            //transition area
            var transitionAreaJson = current["TransitionArea"].arrayValue;
            for j in 0..<transitionAreaJson.count {
//                System.out.println(transitionAreaJson.size());
                var latLon = transitionAreaJson[j].arrayValue;
                var lat = latLon[1].doubleValue
                var lon = latLon[0].doubleValue
                
//                double lat = Double.parseDouble(latStr);
//                double lon = Double.parseDouble(lonStr);
                
                var newPoint:Point = Point(lat: lat, lon: lon);
                transitionArea.append(newPoint);
            }
            
            var arrivalAreaJson:[JSON] = current["ArrivalArea"].arrayValue;
            for  k in 0..<arrivalAreaJson.count{
                var arrivalAreaObj:JSON = arrivalAreaJson[k];
                var connectedID = arrivalAreaObj["RegionID"].stringValue
                connectedID = connectedID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);//???

                var area :[Point] = [];
                var areaJson:[JSON] = arrivalAreaObj["Area"].arrayValue;
                for l in 0..<areaJson.count {
                    var latLon:[JSON] = areaJson[l].arrayValue;
                    var lat = latLon[1].doubleValue;
                    var lon = latLon[0].doubleValue;

//                    double lat = Double.parseDouble(latStr);
//                    double lon = Double.parseDouble(lonStr);

                    var newPoint = Point(lat: lat, lon: lon);
                    area.append(newPoint);
                }

                var arrivalArea = ArrivalArea(arrivalArea: area,connectedID: connectedID);
                arrivalAreaList.append(arrivalArea);
            }

            var newConnection =  Connection(transitionArea: transitionArea,arrivalAreaList: arrivalAreaList);
            connectedList.append(newConnection);
            
        }
        returnObj.setConnectedList(connectedList: connectedList);
        
        return returnObj;
    }
//
    public func getOutputMapArr( inputMapArr:[JSON])->[JSON]{
        var outputMapArr:[JSON] = [];
        if(!inputMapArr.isEmpty){
            for je in inputMapArr {
                var map:JSON = JSON.init();
                var mapId:String = je["MapID"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                var mapType = je["MapFormat"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                var attachedPrimalSpaceID = je["AttachedPrimalSpaceID"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                var filename = je["Filename"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                map["mapid"].string = mapId;
                map["maptype"].string = mapType;
                var mapObj:MapObj =  MapObj(ID: mapId, mapType: mapType, geodetic: [], boundary: [], fileContent: Data(), filename: filename, attachedPrimalSpaceID: attachedPrimalSpaceID );
//                System.out.println(mapId+" "+mapObj);
                mapObjMap[mapId] = mapObj;
                outputMapArr.append(map);
            }
        }
        return outputMapArr;
    }
////
////    /*
////     * Initialize handshaking
////     */
    public func discoverBuilding( latitude:Double,  longitude:Double,  accuracy:Double, _ completion: @escaping (_ avaliableApproach: String?) -> Void) {
        
        //Get the json object from the server
        
        WebAPIToGetAllBuildingLocInConstraint(latitude: latitude, longitude: longitude, accuracy: accuracy){json in
            var settings:JSON? = json
            var buildingInfos:[JSON] = settings!["data"].arrayValue;
            var buildingIDs:[String] = [];
            var shapes:[[Point]] = [];
            // how about using Map<String,List<Point>>, key is buildingID, value is the boundary
            
            
            //Store the shape of the buildings and their IDs
            for i in 0..<buildingInfos.count {
                var currentObj:JSON = buildingInfos[i];
                var buildingId = currentObj["buildingId"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                buildingIDs.append(buildingId);//??
                var points:[JSON] = currentObj["boundary"].arrayValue;
                var newPoints:[Point] = [];
                for j in 0..<points.count {
                    var latLon:[JSON] = points[j].arrayValue;
                    var lon = latLon[0].doubleValue;
                    var lat = latLon[1].doubleValue;
                    
                    var newPoint = Point(lat:lat, lon:lon);
                    newPoints.append(newPoint);
                }
                shapes.append(newPoints);
            }
            
            //find out the building with the highest coverage
            var currentHighestCoverage:Double = -1.0;
            var currentHighestBuildingID:String? = nil;
            
            var center = Point(lat:latitude, lon:longitude);
            for i in 0..<buildingIDs.count {
                var points:[Point] = shapes[i];
                if(points.isEmpty) {
                    continue;
                }
                //first change the points to coordinate Points in meter, and the find out the coverage area
                var coordinatePoints:[CoordinatePoint] = CoverageCalculator.pointsToCoordinatePoints(center: center, Points: points);
                var coverageArea:Double = CoverageCalculator.calculateCoverageArea(points: coordinatePoints,accuracy: accuracy);
                if(coverageArea > currentHighestCoverage) {
                    currentHighestCoverage = coverageArea;
                    currentHighestBuildingID = buildingIDs[i];
                }
                
            }
            
            self.currentBuildingID = currentHighestBuildingID;
            if(self.currentBuildingID == nil) {
                completion(nil)
                return
            }
            
            
            //request for the LocSetting of the building with highest coverage
            
            self.WebAPIToGetBuildingLocSettingByBuildingID(buildingID: self.currentBuildingID!){
                json in
                    settings=json
                    var buildingSetting:JSON = settings!["data"]["BuildingLocSetting"];
                    //Analyze the LocSetting with return of a BuildingLocSetting Obj
            //        System.out.println(buildingSetting);
                self.currentBuildingLocSetting =  self.analyzeLocSettingJson(locSetting: buildingSetting);
                    
                    //request for the Building.json and analyze the json obj to form a buildingObj
                    var Spatial:JSON?=nil;
                self.WebAPIToGetSpatialRepresentationObjByBuildingID(buildingID: currentHighestBuildingID!){ json in
                        Spatial = json!["data"]
                    var currentBuildingObj:BuildingObj =  self.analyzeSpatialRepresentationToBuildingObj(spatial: Spatial!);
                        self.currentBuilding = currentBuildingObj;
                            
                            //Identify which modes are available (edge, cloud, or both)
                        var currentModes:[String] = self.currentBuildingLocSetting!.getOperationMode();
                            if(currentModes.contains("2")){
                                 completion("all_available");return
                            }
                            else if(currentModes.contains("0")) {
                                if(currentModes.contains("1")){
                                    completion("all_Available");
                                    return
                                }
                                completion("edge")
                                return
                            }
                            else if(currentModes.contains("1")) {
                                if(currentModes.contains("0")){
                                    completion("all_Available");
                                    return
                                }
                                completion("cloud");
                                return
                            }
                        completion(nil);
                            return ;
                        };
                    }
                
            };
            
        
    }
    
    public func discoverBuilding( connectedID:String,_ completion:@escaping (String?)->Void){
        //request for and analyze the LocSetting of the building according to the connected building ID
            WebAPIToGetBuildingLocSettingByBuildingID(buildingID: connectedID){json in
                print("return json in discover2")
                var settings = json!
                var buildingSetting = settings["data"]["BuildingLocSetting"];
                self.connectedBuildingLocSetting =  self.analyzeLocSettingJson(locSetting: buildingSetting);
                //Identify which modes are available (edge, cloud, or both)
                var currentModes:[String] = self.connectedBuildingLocSetting!.getOperationMode();
                if(currentModes.contains("2")){
                    completion( "all_available");return
                }
                else if(currentModes.contains("0")) {
                    if(currentModes.contains("1")){
                        completion ("all_available");return
                    }
                    completion("edge");return
                }
                else if(currentModes.contains("1")) {
                    if(currentModes.contains("0")){
                        completion ("all_available");return
                    }

                    completion( "cloud");return
                }
                completion(nil);return
            };
    }

////    
    public func switchToConnectBuilding(_ completion:@escaping (Bool)->Void) {
        //request for the Building.json of the connected building and analyze the json obj to form a buildingObj
        connectedBuildingID = connectedBuildingLocSetting?.getID();
        WebAPIToGetSpatialRepresentationObjByBuildingID(buildingID: connectedBuildingID!){ [self]
            result in
            if(result == nil)||(!result!["data"].exists()){
                completion( false);return
            }
            var Spatial = result!["data"]
                
            var currentBuildingObj:BuildingObj =  analyzeSpatialRepresentationToBuildingObj(spatial: Spatial);
            
            //swap the connectedBuilding and currentBuilding's reference
            var temp:BuildingObj? = currentBuilding;
            if(temp == nil){
                completion( false);return
            }
                
            currentBuilding = currentBuildingObj;
            connectedBuilding = temp;
            
            //swap the currentBuildingLocSetting and connectedBuildingLocSetting's reference
            var tmp:BuildingLocSetting? = currentBuildingLocSetting;
            if(tmp == nil || connectedBuildingLocSetting == nil){
                completion( false);return
            }
            currentBuildingLocSetting = connectedBuildingLocSetting;
            connectedBuildingLocSetting = tmp;
            
            //swap the currentBuildingID and connected BuildingID's reference
            var tempID:String = currentBuildingID!;
            currentBuildingID = connectedBuildingID;
            connectedBuildingID = tempID;
            
            completion( true);return
        };
        
    }
////    
////    
//////    public boolean generateToken(String appID, String key) {
//////        JsonObject returnObj =(JsonObject) WebAPIToGenerateToken(appID, key).get("data");
//////        boolean success = g.fromJson(returnObj.get("success"),boolean.class);
//////        if(success) {
//////            JsonElement tokenJ = returnObj.get("token");
//////            String token = tokenJ.toString();
//////            token = token.substring(1,token.length()-1);
//////            Token = token;
//////            AppID = appID;
//////            Key = key;
//////
//////            Timer timer = new Timer();
//////            timer.schedule(new TimerTask(){
//////                public void run() {
//////                    synchronized(Token) {
//////                        JsonObject returnObj1 = null;
//////                        if(Token == null) {
//////                            if(AppID == null && Key == null)
//////                                returnObj1=(JsonObject) WebAPIToGenerateToken(appID, key).get("data");
//////                            else
//////                                returnObj1=(JsonObject) WebAPIToGenerateToken(AppID, Key).get("data");
//////                        }
//////                        else {
//////                            String[] splitedToken = Token.split(".");
//////                            if(splitedToken.length != 3) {
//////                                if(AppID == null && Key == null)
//////                                    returnObj1=(JsonObject) WebAPIToGenerateToken(appID, key).get("data");
//////                                else
//////                                    returnObj1=(JsonObject) WebAPIToGenerateToken(AppID, Key).get("data");
//////                            }
//////                            else {
//////                                String plainText = splitedToken[0]+"."+splitedToken[1];
//////                                boolean verified = JWTAnalyzer.RS256Verify(plainText,splitedToken[2]);
//////
//////                                if(verified) {
//////                                    String payloadStr = JWTAnalyzer.base64URLDecode(splitedToken[1]);
//////
//////                                    JsonElement element = g.fromJson (payloadStr, JsonElement.class);
//////                                    if(!element.isJsonObject()) {
//////                                        if(AppID == null && Key == null)
//////                                            returnObj1=(JsonObject) WebAPIToGenerateToken(appID, key).get("data");
//////                                        else
//////                                            returnObj1=(JsonObject) WebAPIToGenerateToken(AppID, Key).get("data");
//////                                    }
//////                                    else {
//////                                        JsonObject payload = element.getAsJsonObject();
//////                                        String expStr = payload.get("exp").toString();
//////                                        int exp = Integer.parseInt(expStr);
//////
//////
//////                                        //find current time
//////                                        int currentTime = 0;
//////                                        Date date = new Date();
//////                                        String timeStamp = String.valueOf(date.getTime());
//////                                        int length = timeStamp.length();
//////                                        if(length>3) {
//////                                            currentTime = Integer.valueOf(timeStamp.substring(0,length-3));
//////                                        }
//////                                        if(currentTime > exp)
//////                                            returnObj1 =(JsonObject) WebAPIToRefreshToken(Token).get("data");
//////                                        else
//////                                            return;
//////                                    }
//////                                }
//////                                else {
//////                                    if(AppID == null && Key == null)
//////                                        returnObj1=(JsonObject) WebAPIToGenerateToken(appID, key).get("data");
//////                                    else
//////                                        returnObj1=(JsonObject) WebAPIToGenerateToken(AppID, Key).get("data");
//////                                }
//////                            }
//////                        }
//////                        boolean success1 = g.fromJson(returnObj1.get("success"),boolean.class);
//////
//////                        if(success1) {
//////                            JsonElement tokenJ1 = returnObj.get("token");
//////                            String token1 = tokenJ1.toString();
//////                            token1 = token1.substring(1,token1.length()-1);
//////                            Token = token1;
//////                            AppID = appID;
//////                            Key = key;
//////                            return;
//////                        }
//////                    }
//////
//////                }
//////            }
//////            ,300000);
//////
//////            return true;
//////        }
//////        Token=null;
//////        AppID=null;
//////        Key=null;
//////        return false;
//////    }
////
////    
    public func GridIsInBuilding( gridId:String,  buildingId:String)->Bool{
        var I1 = gridId.index(gridId.startIndex, offsetBy: 16)
        var I2 = gridId.index(gridId.startIndex, offsetBy: 35)
//        var x:Int = Int(gridID[I1..<I2]) ?? 0 ;
        var gridBuildingId:String = String(gridId[I1..<I2]);
//        print("grid building id: " + gridBuildingId);
        return (gridBuildingId == buildingId);
    }
//
//
    public func GridsInBuildingInCoverage( IDList:[JSON],  buildingId:String,  latitude:Double,  longitude:Double, radius:Double)->[String]{
        let zoomLevel = 20;
        var twoToPower = pow(2.0, Double(zoomLevel));
        var gridIds:[String] = [];

        for i in 0..<IDList.count {
//            print(IDList[i].stringValue)
            var currentGridId:String = IDList[i].stringValue;
            //check if grid is in the building
            if(!GridIsInBuilding(gridId: currentGridId, buildingId: buildingId)){
                continue;
            }

            //get index x and index y
            var I1 = currentGridId.index(currentGridId.startIndex, offsetBy: 2)
            var I2 = currentGridId.index(currentGridId.startIndex, offsetBy: 9)
            var I3 = currentGridId.index(currentGridId.startIndex, offsetBy: 16)
    //        var x:Int = Int(gridID[I1..<I2]) ?? 0 ;
            var x = Double(currentGridId[I1..<I2]) ?? 0.0;
            var y = Double(currentGridId[I2..<I3]) ?? 0.0;
//            print("currnet "+currentGridId+" x:"+String(x)+" y:"+String(y))
            //calculate lon/lat of current grid
            var gridLon:Double = 360.0*x/twoToPower - 180.0;
            var gridLat:Double = 180.0 / Double.pi * (2.0 * atan(exp((1.0-Double(2.0*y/twoToPower))*Double.pi)) - Double.pi/2);
//            print(String(gridLon) + " " + String(gridLat))
            var distance:Double = CoverageCalculator.cal_dis(lat1: latitude, lon1: longitude, lat2: gridLat, lon2: gridLon);
            //System.out.println("distance: "+ distance);
            if (distance <= radius) {
                gridIds.append(currentGridId);
            }
        }
        return gridIds;
    }

    public func getGridIDListForEdgeLoc( connected:Bool,  latitude:Double,  longitude:Double,  radius:Double, _ completion:@escaping ([String])->Void){
        var gridIds:[String] = [];

        //if not connected
        if(!connected){
            print("connected false")
            WebAPIToGetGridIDOfBuilding(mode: 0){ [self]
                json in
                var IDListObj:JSON =  json!
                var IDList:[JSON] =  IDListObj["gridIds"].arrayValue;
                print(currentBuildingID!)
                gridIds =  GridsInBuildingInCoverage(IDList: IDList, buildingId: currentBuildingID!, latitude: latitude, longitude: longitude, radius: radius);
                print(gridIds)
                completion(gridIds);return
    //            System.out.println(gridIds);
            };
        }

        // if connected
        if(connected && connectedBuildingLocSetting != nil){
            var buildingId:String = connectedBuilding!.getID();
            var downloadURL:String = connectedBuildingLocSetting!.getRemoteSignalDownloadURL()!.absoluteString;

            WebAPIToGetGridIDOfBuilding (buildingDownloadURL: downloadURL, mode: 0){ [self]
                json in
                var IDListObj:JSON =  json!
                var IDList:[JSON] = IDListObj["gridIds"].arrayValue

                gridIds = GridsInBuildingInCoverage(IDList: IDList, buildingId: buildingId, latitude: latitude, longitude: longitude, radius: radius);
                
                completion( gridIds);return
            };
           
        }

    }
//    
    public func getGridIDListForEdgeLoc( connected:Bool,  location:Location, _ completion : @escaping ([String])->Void){
        // set zoomLevel = 20
        var zoomLevel:Int = 20;
        var twoToPower:Double = pow(2,Double( zoomLevel));
        var latitude:Double = location.getLat();
        var longitude:Double = location.getLon();
        var x = Int(twoToPower*(longitude + 180.0) / 360.0);
        var y = Int((1-(log(tan(latitude * Double.pi / 180.0) + 1/(cos(latitude * Double.pi / 180.0))))/Double.pi) * twoToPower/2);

        // convert the indices to 7-digit format
        let formatter = NumberFormatter();
        formatter.minimumIntegerDigits=7;
//        formatter.setGroupingUsed(false);
        var xIndex:String = formatter.string(from: x as NSNumber)!
        var yIndex:String = formatter.string(from: y as NSNumber)!
        
        var currentGridId:String = String(zoomLevel) + xIndex + yIndex
        currentGridId = currentGridId + location.getFloorID();
//        + currentBuildingID!
        var gridIds:[String] = [];
        gridIds.append(currentGridId);

        //retrieve connected gridIds
        // if not connected
        if(!connected){
            WebAPIToDownloadSiteSignalWithSignalMode(gridId: currentGridId, signalMode: "WiFiFingerprint"){
                json in
                var siteSignalObj:JSON =  json!
                var connectedGridIds:[JSON] =  siteSignalObj["connectedGridIds"].arrayValue;
                if(!connectedGridIds.isEmpty){
                    for je in connectedGridIds{
                        gridIds.append(je.stringValue);
                    }
                }
                completion(gridIds);return
            };
           
        }
        //if connected
        if(connected){
            if(currentBuildingLocSetting != nil) {
                var downloadURL = connectedBuildingLocSetting!.getRemoteSignalDownloadURL()!.absoluteString;
                WebAPIToDownloadSiteSignalWithSignalMode(buildingDownloadURL: downloadURL, gridId: currentGridId, signalMode: "WiFiFingerprint"){
                    json in
                    var siteSignalObj:JSON =  json!
                    var connectedGridIds:[JSON]=siteSignalObj["connectedGridIds"].arrayValue;
                    if(!connectedGridIds.isEmpty){
                        for je in connectedGridIds{
                            gridIds.append(je.stringValue);
                        }
                    }
                    completion(gridIds);return
                };
            }
        }
    }
    
    public func getGridIDListForEdgeLoc(buildingID:String,_ completion:@escaping ([String])->Void){
        WebAPIToGetGridIDOfBuilding(mode: 0){ [self]
            json in
            var IDListObj:JSON =  json!
            var IDList:[JSON] = IDListObj["gridIds"].arrayValue;
            var gridIds:[String] = [];

            // add to list if gridId is in building
            for i in 0..<IDList.count {
                if(GridIsInBuilding(gridId: IDList[i].stringValue, buildingId: buildingID)){
                    gridIds.append(IDList[i].stringValue);
                }
            }
            completion (gridIds);return
        };
        
    }
//    
//    public func downloadSiteSignals( connected:Bool,  siteSignalMode:String,  gridIDList:[String])->[JSON] {
//
//        var siteSignalArr:[JSON] = [];
//
//            if(!connected) {
//                for i in 0..<gridIDList.count {
//                    var siteSignalObj:JSON =  WebAPIToDownloadSiteSignalWithSignalMode(gridId: gridIDList[i], signalMode: siteSignalMode)!;
//                    var gridSignalArr:[JSON] = siteSignalObj["fingerprints"].arrayValue;
//                    siteSignalArr.append(contentsOf: gridSignalArr)
////                    addAll(gridSignalArr);
//                }
//            }
//
//            if(connected && connectedBuildingLocSetting != nil){
//                var downloadURL:String = connectedBuildingLocSetting!.getRemoteSignalDownloadURL()!.absoluteString;
//                for i in 0..<gridIDList.count {
//                    var siteSignalObj:JSON =  WebAPIToDownloadSiteSignalWithSignalMode(buildingDownloadURL: downloadURL, gridId: gridIDList[i], signalMode: siteSignalMode)!;
//                    var gridSignalArr:[JSON] = siteSignalObj["fingerprints"].arrayValue;
//                    siteSignalArr.append(contentsOf: gridSignalArr)
//                }
//            }
//
//            //parse each item in gridSignalArr to a SiteSignalObject, then serialize to JsonArray
//        var wifiFingerprintObjArr:[JSON] = []
//            for wifiJson in siteSignalArr {
//                var floorId:String = wifiJson["floorId"].stringValue
//                floorId = floorId.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
//                var lat = wifiJson["latitude"].doubleValue
//                var lon = wifiJson["longitude"].doubleValue;
//                var rpId:String = wifiJson["rpId"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
//
//                var coordinate:JSON = JSON();
//                coordinate["lat"].double = lat;
//                coordinate["lon"].double = lon;
//                var wifiRssObj:JSON = JSON();
//                wifiRssObj["ID"].string = rpId;
//                wifiRssObj["coordinate"] = coordinate;
//                wifiRssObj["floorId"].string = floorId;
//
//                var wifiRssiJsonArr:[JSON] = wifiJson["wifiRssVector"].arrayValue;
//                var rssiVecList:[JSON] = [];
//                for  wifiRssiJsonElement in wifiRssiJsonArr {
//                    var tempstr = wifiRssiJsonElement.stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
//                    var wifiRssInfo:[String] = tempstr.components(separatedBy: ":");
//                    var mac = wifiRssInfo[0];
//                    var rssi:Double = Double(wifiRssInfo[1])!;
//                    var freq:Int = -1;
//                    var wifiRssi:JSON = JSON();
//                    wifiRssi["mac"].string = mac;
//                    wifiRssi["rssi"].double = rssi;
//                    wifiRssi["freq"].int = 0;
//                    rssiVecList.append(wifiRssi);
//                }
//                wifiRssObj["rssiVecList"].arrayObject = rssiVecList;
//                wifiFingerprintObjArr.append(wifiRssObj);
//            }
//            return wifiFingerprintObjArr;
//        }
//        
//        /*
//         * Indoor cloud localization
//         */
//    public func getSignalTypeForCloudLoc( connected:Bool)->[String]{
//        var signalModes:[String] = [];
//        var returnList:[String] = [];
//            if(connected == false){
//                signalModes = currentBuildingLocSetting!.getCloudLocSignalMode();
//            }
//
//            if(connected){
//                if(connectedBuildingLocSetting == nil){
//                    return signalModes;
//                }
//                signalModes = connectedBuildingLocSetting!.getCloudLocSignalMode();
//            }
//    //        System.out.println(signalModes);
//            for  signalMode in signalModes {
//
//                if (signalMode.contains("WiFi")){
//                    returnList.append("WiFi");
//                }else if (signalMode.contains("BLE")){
//                    returnList.append("BLE");
//                }else if (signalMode.contains("Mag")){
//                    returnList.append("Magnetic");
//                }
//            }
//
//            return returnList;
//        }
//        
//    public func uploadSignalToCloud( connected:Bool, userID:String,  userSignal:JSON) {
//        var requestBody:JSON = userSignal;
//        requestBody["userId"].string = userID;
//
//        // append user signal
////        for (Map.Entry<String, JsonElement> entry : userSignal.entrySet()) {
////            requestBody.add(entry.getKey(), entry.getValue());
////        }
//
//        if(!connected){
//            var uploadURL:URL = currentBuildingLocSetting!.getRemoteCloudLocUploadURL()!;
////            System.out.println(uploadURL);
//             postJson(url: uploadURL, json: requestBody);
//        }
//
//        if(connected && connectedBuildingLocSetting != nil){
//            var uploadURL:URL = connectedBuildingLocSetting!.getRemoteCloudLocUploadURL()!;
//             postJson(url: uploadURL, json: requestBody);
//        }
//
//    }
//    
//    public func getCloudLocResult( connected:Bool, userID:String) -> Location? {
//        var cloudLocDownloadURL:String;
//
//        if(!connected){
//            cloudLocDownloadURL = currentBuildingLocSetting!.getRemoteCloudLocDownloadURL()!.absoluteString
//        }
//
//        else{
//            if (connectedBuildingLocSetting == nil){ return nil};
//            cloudLocDownloadURL = connectedBuildingLocSetting!.getRemoteCloudLocDownloadURL()!.absoluteString;
//        }
//
//        var locationJson:JSON =  WebAPIToGetUserLocationFromCloud(buildingDownloadURL: cloudLocDownloadURL, userId: userID)!;
//
//        var inBuilding:Bool = locationJson["inBuilding"].boolValue;
//        if(!inBuilding){ return nil;}
//
//        var latitude = locationJson["latitude"].doubleValue;
//        var longitude = locationJson["longitude"].doubleValue;
//        var floorID = locationJson["floorId"].stringValue;
//        return Location(lat: latitude, lon: longitude, floorID: floorID);
//    }
//
//
//
    public func discoverOutdoorSite( latitude:Double, longitude:Double, accuracy:Double, _ completion: @escaping (Bool)->Void){
        //call web api to get all outdoor site covered by (lat,lon,radius)
        
        WebAPIToGetOutdoorSiteList(latitude: latitude, longitude: longitude, accuracy: accuracy){json in
            var settings:JSON = json ?? JSON.null
            var siteInfos:[JSON] = settings["data"].arrayValue;
            var siteIDs:[String] = [];
            var shapes:[[Point]] = [];
            
            
           //store the boundary and siteIDs of the sites
           for  i in 0..<siteInfos.count {
               let currentObj:JSON = siteInfos[i];
               let siteId = currentObj["siteId"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
               siteIDs.append(siteId);
               let points:[JSON] = currentObj["boundary"].arrayValue;
               var newPoints:[Point] = [];
               for  j in 0..<points.count {
                   let latLon:[JSON] = points[j].arrayValue;
                   let lat = latLon[1].doubleValue;
                   let lon = latLon[0].doubleValue;
                   
                   let newPoint:Point =  Point(lat: lat, lon: lon);
                   newPoints.append(newPoint);
               }
               shapes.append(newPoints);
           }
            
            // find site with largest coverage
            var currentHighestCoverage = -1.0;
            var currentHighestSiteID:String? = nil;
            
            var center =  Point(lat:latitude, lon:longitude);
            for i in 0..<siteIDs.count {
                var points:[Point] = shapes[i];
                if(points == nil) {
                    continue;
                }
                var coordinatePoints:[CoordinatePoint] = CoverageCalculator.pointsToCoordinatePoints(center: center, Points: points);
                var coverageArea:Double = CoverageCalculator.calculateCoverageArea(points: coordinatePoints,accuracy: accuracy);
                if(coverageArea > currentHighestCoverage) {
                    currentHighestCoverage = coverageArea;
                    currentHighestSiteID = siteIDs[i];
                }
            }
            
            //return false if no result
            if(currentHighestCoverage <= 0 || currentHighestSiteID == nil) {
                completion( false);return
            }
            //
            self.WebAPIToGetOutdoorSiteSettingByOutdoorSiteID(siteID: currentHighestSiteID!){json in
                settings = json ?? JSON.null
                //return false if no result
                if(settings == JSON.null){
                    completion( false);return
                }
//                print(json)
                //store outdoorSetting in API Manager
        //        JsonObject outdoorSetting = settings.getAsJsonObject("data").getAsJsonObject("LocSetting");
                var outdoorSetting:JSON = settings["data"]["OutdoorLocSetting"];
                self.currentOutdoorLocSetting = self.analyzeOutdoorLocSettingJson(locSetting: outdoorSetting);
//                print("outdoorsetting "+outdoorSetting.debugDescription)
//                print("outdoor related gridlist "+(self.currentOutdoorLocSetting!.getRelatedGridList().debugDescription))
                
                completion( true);return
            };
            
        };
        
    }
    
    public func getOutdoorSignal( latitude:Double, longitude:Double, radius:Double, signalMode:String?,_ completion : @escaping ([JSON]?) ->Void) {
        //determine the operation mode and url
        
        var SignalMode:String = signalMode ?? "BLELocation";
//        if (signalMode == nil){SignalMode = "BLELocation";};
        var mode = 2;
        if(currentOutdoorLocSetting == nil){
            completion(nil);return ;
        }
        if(currentOutdoorLocSetting!.getRemoteSignalDownloadURL() != nil){
            mode = 0;
        }
        
        //find the grid ids within the range
        var twoPowerTwenty = 1048576;
        var points:[Point] = CoverageCalculator.cal_lat_lon_20z(lat: latitude, lon: longitude, accuracy: radius);
        var gridIDs:[String] = [];
        for i in 0..<points.count {
            var newGrid = CoverageCalculator.cal_grid_id(lat: points[i].getLat(), lon: points[i].getLon(), powerZoom: twoPowerTwenty, level: 20);
//            if(gridIDs.contains(newGrid))
//                continue;
            if((!gridIDs.contains(newGrid))&&CoverageCalculator.grid_is_covered(lat: latitude, lon: longitude,gridID: newGrid,radius: radius)){
                gridIDs.append(newGrid);
//                print("add "+newGrid)
            }
                
        }
//        print("test "+gridIDs.debugDescription)
        //find the grid ids within the range and within the site, remove the grids ids not in the relatedGridList
        var relatedGridList:[String] = currentOutdoorLocSetting!.getRelatedGridList();
//        for i in 0..<gridIDs {
//            if(!relatedGridList.contains(gridIDs[i])) {
//                gridIDs.remove(i);
//                i-=1;
//            }
//        }
        
//        print("test "+gridIDs.debugDescription)
//        print("test "+relatedGridList.debugDescription)
//        gridIDs.removeAll(where: {!relatedGridList.contains($0)})
//        gridIDs.removeAll{ (gridID)->Bool in
//            let isRemove = (!relatedGridList.contains(gridID))
//            return isRemove
//        }
        
        let group = DispatchGroup()
        var returnObj:[JSON] = [];
        DispatchQueue.global(qos: .default).async {
            for  i in 0..<gridIDs.count {
                group.enter()
                self.WebAPIForGettingOutdoorSignal(gridID: gridIDs[i], mode: mode, inputSignalMode: SignalMode){ json in
//                    print("in get outdoorsignal after web call")
//                    print(json)
//                    print("in get outdoorsignal after web call2")
                    var settings = json
                    //Not sure what is the return value, should be changed
                    if(settings == nil){
                        completion(nil);return;
                    }
                    
                    var signals:[JSON] = [];
                    if(SignalMode == "BLELocation") {
                        signals = settings!["beaconLocations"].arrayValue;
                        var ble:[BLELocationObj] = [];
                        for j in 0..<signals.count {
                            var currentJsonObj = signals[j];
                            var uuid = currentJsonObj["uuid"].stringValue;
                            uuid = uuid.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                            
                            var major = currentJsonObj["major"].stringValue;
                            
                            var minor = currentJsonObj["minor"].stringValue;
                            
                            var outdoorSiteID = currentJsonObj["OutdoorSiteID"].stringValue;
                            outdoorSiteID = outdoorSiteID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                            
                            var lat = currentJsonObj["lat"].doubleValue;
        //                    double lat = Double.parseDouble(latStr);
                            
                            var lon = currentJsonObj["lon"].doubleValue;
        //                    double lon = Double.parseDouble(lonStr);
                            
                            var txPower = 0;
                            var txPowerJson = currentJsonObj["txPower"];
                            if(txPowerJson.exists()) {
        //                        var txPowerStr = txPowerJson.stringValue;
        //                        txPower = Integer.parseInt(txPowerStr);
                                txPower = txPowerJson.intValue
                            }
                            
                            var newObj = BLELocationObj(ID: uuid+major+minor, coordinate: Point(lat:lat,lon:lon), floorID: outdoorSiteID, UUID: uuid,major: major,minor: minor,texPower: txPower);
//                            print(newObj.getCoordinate().description)
                            ble.append(newObj);
                        }
                        
                        var returnArray:[JSON] = [];
                        for j in 0..<ble.count {
                            var current:BLELocationObj = ble[j];
        //                    var currentStr = g.toJson(current);
        //                    var coorJson = JSON()
        //                    coorJson["lat"].double = current.getCoordinate().getLat()
        //                    coorJson["lon"].double = current.getCoordinate().getLon()
                            var currentJson = JSON()
                            currentJson["UUID"].string = current.getUUID()
                            currentJson["major"].string = current.getMajor()
                            currentJson["minor"].string = current.getMinor()
                            currentJson["txPower"].int = current.getTexPower()
                            currentJson["ID"].string = current.getID()
                            currentJson["floorID"].string = current.getFloorID()
        //                    currentJson["coordinate"] = coorJson
                            currentJson["coordinate"].dictionaryObject = ["lat":current.getCoordinate().getLat(),"lon":current.getCoordinate().getLon()]
//                            currentJson["coordinate"]["lat"].double = current.getCoordinate().getLat()
//                            currentJson["coordinate"]["lon"].double = current.getCoordinate().getLon()
                            returnArray.append(currentJson);
                        }
                        returnObj.append(contentsOf: returnArray)
                        group.leave()
        //                returnObj.addAll(returnArray);
                        
                    }
                    else if(SignalMode == "WiFiFingerprint" || SignalMode == "BleFingerprint" || SignalMode == "MagFingerprint") {
                        signals = settings!["fingerprints"].arrayValue;
                        
                        if(SignalMode == "WiFiFingerprint") {
                            var ble:[WiFiFingerprintObj] = [];
                            for j in 0..<signals.count {
                                var currentJsonObj:JSON = signals[j];
                                var rpid:String = currentJsonObj["rpId"].stringValue;
                                rpid = rpid.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                
                                var outdoorSiteID = currentJsonObj["OutdoorSiteID"].stringValue;
                                outdoorSiteID = outdoorSiteID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                
                                var lat = currentJsonObj["lat"].doubleValue;
        //                        double lat = Double.parseDouble(latStr);
                                
                                var lon = currentJsonObj["lon"].doubleValue;
        //                        double lon = Double.parseDouble(lonStr);
                                
                                var rssVector:[JSON] = currentJsonObj["wifiRssVector"].arrayValue;
                                var rssiVecList:[WiFi] = [];
                                for entry in rssVector {
                                    var tempstr = entry.stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                    var wifiRssInfo:[String] = tempstr.components(separatedBy: ":");
                                    var mac:String = wifiRssInfo[0];
                                    var rssi:Int = Int(wifiRssInfo[1])!;
                                    rssiVecList.append( WiFi(mac: mac, rssi: rssi, freq: 0));
                                }
                                
                                var newObj:WiFiFingerprintObj =  WiFiFingerprintObj(ID: rpid,  coordinate: Point(lat:lat,lon:lon), floorID: outdoorSiteID, rssiVecList: rssiVecList);
                                
                                ble.append(newObj);
                            }
                            
                            var returnArray:[JSON] = [];
                            for j in 0..<ble.count {
                                var current:WiFiFingerprintObj = ble[j];
        //                        String currentStr = g.toJson(current);
        //                        JsonObject currentJson = g.fromJson(currentStr, JsonObject.class);
                                var wifiJsonArray:[JSON] = []
                                for wifiObj in current.getRssiVecList(){
                                    var wifijson = JSON()
                                    wifijson["mac"].string = wifiObj.getMac()
                                    wifijson["freq"].int = wifiObj.getFreq()
                                    wifijson["rssi"].int = wifiObj.getRssi()
                                    wifiJsonArray.append(wifijson)
                                }
                                var currentJson = JSON()
                                currentJson["ID"].string = current.getID()
                                currentJson["floorID"].string = current.getFloorID()
                                currentJson["coordinate"]["lat"].double = current.getCoordinate().getLat()
                                currentJson["coordinate"]["lon"].double = current.getCoordinate().getLon()
                                currentJson["rssiVecList"].arrayObject = wifiJsonArray
                                returnArray.append(currentJson);
                            }
                            returnObj.append(contentsOf: returnArray);
                            group.leave()
                            
                        }
                        else if(SignalMode == "BleFingerprint") {
                            var ble:[WiFiFingerprintObj] = [];
                            for j in 0..<signals.count {
                                var currentJsonObj:JSON = signals[j];
                                var rpid = currentJsonObj["rpId"].stringValue;
                                rpid = rpid.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                
                                var outdoorSiteID = currentJsonObj["OutdoorSiteID"].stringValue;
                                outdoorSiteID = outdoorSiteID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                
                                var lat = currentJsonObj["lat"].doubleValue;
        //                        double lat = Double.parseDouble(latStr);
                                
                                var lon = currentJsonObj["lon"].doubleValue;
        //                        double lon = Double.parseDouble(lonStr);
                                
                                var rssVector:[JSON] =  currentJsonObj["bleRssVector"].arrayValue;
                                var rssiVecList:[WiFi] = [];
                                for  entry in rssVector {
                                    var entryStr = entry.stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                    var wifiRssInfo:[String] = entryStr.components(separatedBy: ":");
                                    var mac:String = wifiRssInfo[0];
                                    var rssi:Int = Int(wifiRssInfo[1])!;
                                    rssiVecList.append( WiFi(mac: mac, rssi: rssi, freq: 0));
                                }
                                
                                var newObj =  WiFiFingerprintObj(ID: rpid, coordinate: Point(lat:lat,lon:lon), floorID: outdoorSiteID, rssiVecList: rssiVecList);
                                
                                ble.append(newObj);
                            }
                            
                            var returnArray:[JSON] = [];
                            for j in 0..<ble.count {
                                var current = ble[j];
        //                        String currentStr = g.toJson(current);
        //                        JsonObject currentJson = g.fromJson(currentStr, JsonObject.class);
                                var wifiJsonArray:[JSON] = []
                                for wifiObj in current.getRssiVecList(){
                                    var wifijson = JSON()
                                    wifijson["mac"].string = wifiObj.getMac()
                                    wifijson["freq"].int = wifiObj.getFreq()
                                    wifijson["rssi"].int = wifiObj.getRssi()
                                    wifiJsonArray.append(wifijson)
                                }
                                var currentJson = JSON()
                                currentJson["ID"].string = current.getID()
                                currentJson["floorID"].string = current.getFloorID()
                                currentJson["coordinate"]["lat"].double = current.getCoordinate().getLat()
                                currentJson["coordinate"]["lon"].double = current.getCoordinate().getLon()
                                currentJson["rssiVecList"].arrayObject = wifiJsonArray
                                returnArray.append(currentJson);
                            }
                            returnObj.append(contentsOf: returnArray);
                            group.leave()
                        }
                        else {
                            var ble:[MagFingerprintObj] = [];
                            for j in 0..<signals.count {
                                var currentJsonObj:JSON = signals[j];
                                var rpid = currentJsonObj["rpId"].stringValue;
                                rpid = rpid.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                
                                var outdoorSiteID = currentJsonObj["OutdoorSiteID"].stringValue;
                                outdoorSiteID = outdoorSiteID.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
                                
                                var lat = currentJsonObj["lat"].doubleValue;
        //                        double lat = Double.parseDouble(latStr);
                                
                                var lon = currentJsonObj["lon"].doubleValue;
        //                        double lon = Double.parseDouble(lonStr);
                                
                                var magneticSignals = currentJsonObj["magneticSignal"].arrayValue;
                                var mac =  Magnetic(mag_x: magneticSignals[0].doubleValue,
                                                    mag_y: magneticSignals[1].doubleValue,mag_z: magneticSignals[2].doubleValue);
                                var ma:[Magnetic] = [];
                                ma.append(mac);
                                var newObj = MagFingerprintObj(ID: rpid, coordinate: Point(lat:lat,lon:lon), floorID: outdoorSiteID, magneticVecList: ma);
                                
                                ble.append(newObj);
                            }
                            
                            var returnArray:[JSON] = [];
                            for j in 0..<ble.count {
                                var current:MagFingerprintObj = ble[j];
        //                        String currentStr = g.toJson(current);
                                
                                var magJsonArray:[JSON] = []
                                for magObj in current.getMagneticVecList(){
                                    var magjson = JSON()
                                    magjson["mag_x"].double = magObj.getMag_x()
                                    magjson["mag_y"].double = magObj.getMag_y()
                                    magjson["mag_z"].double = magObj.getMag_z()
                                    magJsonArray.append(magjson)
                                }
                                
                                var currentJson = JSON()
                                currentJson["ID"].string = current.getID()
                                currentJson["floorID"].string = current.getFloorID()
                                currentJson["coordinate"]["lat"].double = current.getCoordinate().getLat()
                                currentJson["coordinate"]["lon"].double = current.getCoordinate().getLon()
                                currentJson["magneticVecList"].arrayObject = magJsonArray
        //                        g.fromJson(currentStr, JsonObject.class);
                                returnArray.append(currentJson);
                            }
                            returnObj.append(contentsOf: returnArray);
                            group.leave()
                        }
                    }
                }
                
                
            }
            group.notify(queue: .main){
                completion(returnObj)
                return
            }
        }
        
        //request for the outdoor signal according to the mode and the signal type
        
//        completion( returnObj);return
    }
////
//    public func getMapData( FloorID:String?)->JSON {
//        // building
//        var buildingMap:JSON =  WebAPIToGetMapJsonForIndoor(buildingID: currentBuildingID, floorID: nil, regionID: nil, lat: 0, lon: 0)!;
//        var inputBuildingMapArr:[JSON] = buildingMap["data"]["mapJson"].arrayValue;
//        var outputBuildingMapArr:[JSON] = []
//        if (!inputBuildingMapArr.isEmpty){
//            outputBuildingMapArr=getOutputMapArr(inputMapArr: inputBuildingMapArr)
//        }
//        // floor
//        var floorMap:JSON =  WebAPIToGetMapJsonForIndoor(buildingID: nil, floorID: FloorID, regionID: nil, lat: 0, lon: 0)!;
//        var inputFloorMapArr:[JSON] =  floorMap["data"]["mapJson"].arrayValue;
//        var outputFloorMapArr:[JSON] = []
//        if(!inputFloorMapArr.isEmpty){
//            outputFloorMapArr=getOutputMapArr(inputMapArr: inputFloorMapArr)
//        }
//
//        // region
//        var outputRegionMapArr:[JSON] = []
//        for fo in currentBuilding!.getFloorList(){
//            if(fo.getFloorNo() == FloorID){
//                for ro in fo.getRegionList(){
//                    var regionMap:JSON =  WebAPIToGetMapJsonForIndoor(buildingID: nil, floorID: nil, regionID: ro.getID(), lat: 0, lon: 0)!;
//                    var inputRegionMapArr:[JSON] = regionMap["data"]["mapJson"].arrayValue;
//                    if (!inputRegionMapArr .isEmpty){
//                        outputRegionMapArr.append(contentsOf: getOutputMapArr(inputMapArr: inputRegionMapArr));
//                    }
//                }
//            }
//        }
//
//        // concatenate
//        var mapData = JSON();
//        mapData["building"].arrayObject = outputBuildingMapArr;
//        mapData["floor"].arrayObject = outputFloorMapArr;
//        mapData["region"].arrayObject = outputRegionMapArr;
//
//        return mapData;
//    }
//    
//    public func getMapData( location:Location)->JSON {
//        // building
//        var buildingID = location.getFloorID().prefix(19); //(0,19);
//        var floorID = location.getFloorID();
////        JsonObject buildingMap = WebAPIToGetMapJsonForIndoor(buildingID, null, null, 0, 0);
////        JsonArray inputBuildingMapArr = buildingMap.getAsJsonObject("data").getAsJsonArray("mapJson");
////        JsonArray outputBuildingMapArr =  (inputBuildingMapArr!=null)?getOutputMapArr(inputBuildingMapArr):new JsonArray();
////
////        // floor
////        JsonObject floorMap = WebAPIToGetMapJsonForIndoor(null, location.getFloorID(), null, 0, 0);
////        JsonArray inputFloorMapArr = floorMap.getAsJsonObject("data").getAsJsonArray("mapJson");
////        JsonArray outputFloorMapArr = (inputFloorMapArr!=null)?getOutputMapArr(inputFloorMapArr):new JsonArray();
//
//        // lat & lon
//        var latLonMap:JSON =  WebAPIToGetMapJsonForIndoor(buildingID: nil, floorID: nil, regionID: nil, lat: location.getLat(), lon: location.getLon())!;
//        var inputLatLonMapArr:[JSON] = latLonMap["data"]["mapJson"].arrayValue;
//        var outputRegionMapArr:[JSON]  = [];
//        var outputFloorMapArr :[JSON] = [];
//        var outputBuildingMapArr:[JSON]  = [];
//        if(!inputLatLonMapArr.isEmpty){
//            for je in inputLatLonMapArr{
//
//                var attachedPrimalSpaceID:String =  je["AttachedPrimalSpaceID"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
////                attachedPrimalSpaceID=attachedPrimalSpaceID.substring(1,attachedPrimalSpaceID.length()-1);
//                print(attachedPrimalSpaceID + " "+buildingID + " " + floorID);
//                
//                    var map = JSON();
//                    var mapId = je["MapID"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
//                    var mapType = je["MapFormat"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
//                    var filename = je["Filename"].stringValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil);
//                    map["mapid"].string = mapId;
//                    map["maptype"].string = mapType;
//                    var mapObj = MapObj.init(ID: mapId, mapType: mapType, geodetic: [], boundary: [], fileContent: Data(), filename: filename, attachedPrimalSpaceID: attachedPrimalSpaceID)
//                    
////                    System.out.println(mapId+" "+mapObj);
//                    mapObjMap[mapId] = mapObj;
//                if (attachedPrimalSpaceID == buildingID){
//                    outputBuildingMapArr.append(map);
//                }else if (attachedPrimalSpaceID == floorID){
//                    outputFloorMapArr.append(map);
//                }else if (attachedPrimalSpaceID.count > 21){
//                    outputRegionMapArr.append(map);
//                }
//            }
//        }
//
//
//        // concatenate
//        var mapData = JSON();
//        mapData["building"].arrayObject = outputBuildingMapArr;
//        mapData["floor"].arrayObject = outputFloorMapArr;
//        mapData["region"].arrayObject = outputRegionMapArr;
//
//        return mapData;
//    }
//
//    public func getMapObj(mapID:String)->MapObj?{
//        return mapObjMap[mapID] ?? nil;
//    }
// 
//    public func getMapFile( fileType:String,  mapID:String)  -> Data?{
//        var mapObj:MapObj = getMapObj(mapID: mapID)!;
//        print("filetype "+mapObj.getMapType()+" "+fileType);
//        if(!(mapObj.getMapType() == fileType)){ return nil;}
//
//        var mapFile:JSON =  WebAPIToGetMapFile(mapID: mapID)!;
////        System.out.println(mapFile);
//        var mapFileString = mapFile["data"]["mapData"].stringValue;
////        mapFileString=mapFileString.substring(1,mapFileString.length()-1);
////                .replace("\"","");
////        System.out.println(mapFileString);
//        var data = Data(base64Encoded: mapFileString, options: .ignoreUnknownCharacters)!
//        var target:MapObj = mapObjMap[mapID]!;
//        target.setFileContent(fileContent: data);
//        mapObjMap.updateValue(target, forKey: mapID)
//
//
////        var result:Data = data
////        Base64.getDecoder().decode(mapFileString.getBytes(StandardCharsets.UTF_8));
//        return data;
//    }
    
    /*
     * Get building information
     */
    
    
    public func getSignalMode( connected:Bool)-> [String]? {
        if(connected) {
            if(connectedBuildingLocSetting != nil){
                return connectedBuildingLocSetting!.getSiteSignalMode();
            }
                
        }
        else {
            if(currentBuildingLocSetting != nil){
                return currentBuildingLocSetting!.getSiteSignalMode();
                
            }
        }
        return nil;
    }
    public func getBuildingID()->String? {
        return currentBuildingID;
    }

    public func getCurrentBuilding() -> BuildingObj? {
        return currentBuilding;
    }
    
    public func getCurrentBuildingLocSetting() -> BuildingLocSetting? {
        return currentBuildingLocSetting;
    }

    public func getOutdoorSiteID() -> String? {
        if(currentOutdoorLocSetting != nil){
            return currentOutdoorLocSetting!.getID();
        }
        return nil;
    }
    public func getCurrentOutdoorSite() -> OutdoorSiteObj? {
        return currentOutdoorSite;
    }
    public func getCurrentOutdoorLocSetting() -> OutdoorLocSetting? {
        return currentOutdoorLocSetting;
    }
}
