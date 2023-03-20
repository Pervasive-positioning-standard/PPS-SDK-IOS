//
//  File.swift
//  
//
//  Created by Mac on 20/3/2023.
//

import Foundation
import SwiftyJSON
import Alamofire

public class ZoneDetector:NSObject{
//    private let specialPolygon_8w:[Point] = [
//             Point(  22.4266186031382,114.211507861226),
//             Point(22.4261436915761,114.212297808714),
//             Point( 22.4256646163258,114.211844134484),
//             Point( 22.4258839880039,114.211550168544),
//             Point(22.4254990168295,114.211241115409),
//             Point(22.425790427132,114.210834514125),
//             Point( 22.4266186031382,114.211507861226)
//      ];
    private let specialPolygon:[Point] = [
        Point(lat: 22.4269262845963,lon: 114.209347706282),
        Point(lat: 22.4267242105168,lon: 114.209229481775),
        Point(lat: 22.427048833880093,lon: 114.2086963123424),
        Point(lat: 22.42696399988175,lon: 114.20860453703955),
        Point(lat: 22.4264921321627,lon: 114.209245303348),
        Point(lat: 22.426725682856,lon: 114.209474349964),
        Point(lat: 22.426944281474,lon: 114.20949779429),
        Point(lat: 22.4269262845963, lon: 114.209347706282),
    ]
//    private var apiManager:APIManager;
    
    public override init() {
        
    }
    
    public func isInSpecialSwitchZone(lat:Double,lon:Double)->Bool{
        if (ZoneDetector.pointInPolygon(lat: lat,lon: lon,polygon: specialPolygon)){
            return true;
        }
        
        return false;
    }
    
    public static func pointInPolygon( lat:Double, lon:Double, polygon:[Point])->Bool {
        //A point is in a polygon if a line from the point to infinity crosses the polygon an odd number of times
        var odd = false;
        // int totalCrosses = 0; // this is just used for debugging
        //For each edge (In this case for each point of the polygon and the previous one)
        var i:Int = 0;
        var j:Int = polygon.count - 1;
        while (i < polygon.count) {
                // Starting with the edge from the last to the first node
                //If a line from the point into infinity crosses this edge
            if ((polygon[i].getLat() > lat ) != (polygon[j].getLat()>lat // One point needs to be above, one below our y coordinate and the edge doesn't cross our Y corrdinate before our x coordinate (but between our x coordinate and infinity)
                && lon < (polygon[j].getLon() - polygon[i].getLon()) * (lat - polygon[i].getLat()) / (polygon[j].getLat() - polygon[i].getLat()) + polygon[i].getLon())
            ) {
                // Invert odd
                // System.out.println("Point crosses edge " + (j + 1));
                // totalCrosses++;
                odd = !odd;
            }
                //else {System.out.println("Point does not cross edge " + (j + 1));}
            j = i;
            i+=1;
        }
        // System.out.println("Total number of crossings: " + totalCrosses);
        //If the number of crossings was odd, the point is in the polygon
        return odd;
    }
    
    public func detectIndoorEnvironment(apiManager:APIManager, latitude:Double, longitude:Double, accuracy:Double,_ completion:@escaping (String)->Void){
            //get boundary by web api
        apiManager.WebAPIToGetAllBuildingLocInConstraint(latitude: latitude, longitude: longitude, accuracy: accuracy){
            response in
            var jsonArray:[JSON] = response!["data"].arrayValue
            for json in jsonArray {
                var buildingId:String = json["buildingId"].stringValue;
                var boundary:[JSON] = json["boundary"].arrayValue;
                var newPoints:[Point] = [];

                for j in 0..<boundary.count{
                    var latLon:[JSON] = boundary[j].arrayValue;
                    var lon:Double = latLon[0].doubleValue
                    var lat:Double = latLon[1].doubleValue
                    var newPoint =  Point(lat:lat, lon:lon);
                    newPoints.append(newPoint);
                }

                var pointIn:Bool = ZoneDetector.pointInPolygon(lat: latitude,lon: longitude,polygon: newPoints);
                if (ZoneDetector.pointInPolygon(lat: latitude,lon: longitude,polygon: newPoints)){
                    completion (buildingId);return
                }
            }
            completion("Outdoor");return
        }
    
    }

    public func detectSwitchCondition(apiManager:APIManager, currentLoc:Location )->String?{//,_ completion:@escaping (String)->Void
        var buildingObj:BuildingObj = apiManager.getCurrentBuilding()!;
        var floors:[FloorObj] = buildingObj.getFloorList();
        var targetRegions:[RegionObj] = [];
        for floor in floors{
            var floorx=floor.getID();
            if (floor.getID() ==  currentLoc.getFloorID()){
                targetRegions = floor.getRegionList();
                break;
            }
        };

        var targetConnectionZones:[Connection] = []
        for region in targetRegions {
            for conn in region.getConnectedList() {
                for area in conn.getArrivalAreaList(){
                    if (!area.getConnectedID().contains(buildingObj.getID())){
                        targetConnectionZones.append(conn);
                    }
                };
            }
        }

        var possibleSwitchID:String="";
        for conn in targetConnectionZones{

            if (ZoneDetector.pointInPolygon(lat: currentLoc.getLat(),lon: currentLoc.getLon(),polygon: conn.getTransitionArea())){
                possibleSwitchID=conn.getArrivalAreaList()[0].getConnectedID();
            }
        }

        if (possibleSwitchID.contains("O")){
            return possibleSwitchID;
        }else if (possibleSwitchID.count >= 19){
            let index = possibleSwitchID.index(possibleSwitchID.startIndex, offsetBy: 19)
            return String(possibleSwitchID.prefix(upTo: index));
        }
        print("detectSwitchCondition: "+possibleSwitchID);
        return nil;
    }
    
}
