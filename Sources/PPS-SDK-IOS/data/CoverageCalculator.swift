//
//  File.swift
//  
//
//  Created by mtrec_mbp on 29/7/2022.
//

import Foundation

public class CoverageCalculator {
    static var EPS = 1E-8;
    static var halfGridHeight:Double = 0.0;
    static var halfGridWidth:Double = 0.0;
    static var check = false;
    
    
    public static func cal_dis( lat1:Double, lon1:Double, lat2:Double, lon2:Double)->Double{  // generally used geo measurement function
        let R = 6378.137; // Radius of earth in KM
        let dLat = lat2 * Double.pi / 180.0 - lat1 * Double.pi / 180.0;
        let dLon = lon2 * Double.pi / 180.0 - lon1 * Double.pi / 180.0;
        let a = sin(dLat/2.0) * sin(dLat/2.0) +
                cos(lat1 * Double.pi / 180) * cos(lat2 * Double.pi / 180) *
                        sin(dLon/2) * sin(dLon/2);
        let c = 2 * atan2(sqrt(a), sqrt(1-a));
        let d = R * c;
        return d * 1000; // meters
    }
    
    //find out the min max lat lon with given lat lon and accuracy
    public static func cal_min_max( lat:Double,  lon:Double,  accuracy:Double)->[Double]{
        
        let degree = cal_degree(accuracy: accuracy,latitude: lat);
        let minlat = lat - degree;
        let maxlat = lat + degree;
        let minlon = lon - degree;
        let maxlon = lon + degree;
        let n=[minlon, minlat, maxlon,maxlat];
        return n;
    }
    
    //given lat lon, power of the zoom level (2^20), and the zoom level, find out the grid id
    public static func cal_grid_id( lat:Double,  lon:Double, powerZoom:Int, level:Int) -> String{

        let x:Int = Int(Double(powerZoom)*(lon+180.0)/360.0);
//        int y = powerZoom - 1 - (int)(powerZoom*(lat+90)/180);
        let y:Int = Int((1.0-(log(tan(lat*Double.pi/180.0)+(1.0/cos(lat*Double.pi/180.0))))/Double.pi)*Double(powerZoom)/2.0);
        
        var xIndex:String = ""+String( x);
        var yIndex:String = ""+String(y);
        if(xIndex.count<7) {
            let n:Int = 7-xIndex.count;
            for _ in 0..<n{
                xIndex = "0"+xIndex;
            }
        }
        if(yIndex.count<7) {
            let n :Int = 7-yIndex.count;
            for _ in 0..<n{
                yIndex = "0"+yIndex;
            }
        }
        return ""+String(level)+xIndex+yIndex;
    }
    
    //Given lat lon of center and accuracy, return a list of points in a square with centered by the given lat lon
    public static func cal_lat_lon_20z(lat:Double,lon:Double,accuracy:Double)->[Point]{
        
        let twoPowerTwenty = 1048576;
        //degree = accuracy lat lon
//        double degree = (180/6378.137/Double.pi)*accuracy/1000;
        var degree:Double = cal_degree(accuracy: accuracy,latitude: lat);
        var generalUnit:Double = 180.0/Double(twoPowerTwenty);
        
        var returnValue:[Point] = [];
        returnValue.append(Point(lat: lat,lon: lon));
        
        var times:Int = Int((degree/generalUnit)+1);
        for i in 0..<2 {
            if(i == 0) {
                //up
                for j in 1...times {
                    //left or right
                    var currentLat:Double = lat + Double(j)*generalUnit;
                    for n in 1...times{
                        var currentLonRight:Double = lon + Double(j)*generalUnit;
                        var currentLonLeft:Double = lon - Double(j)*generalUnit;
                        returnValue.append(Point(lat: currentLat, lon: currentLonLeft));
                        returnValue.append(Point(lat: currentLat, lon: currentLonRight));
                    }
                }
            }
            else{
                //down
                for j in 1...times{
                    //left or right
                    var currentLat:Double = lat - Double(j)*generalUnit;
                    for n in 1...times{
                        var currentLonRight:Double = lon + Double(j)*generalUnit;
                        var currentLonLeft:Double = lon - Double(j)*generalUnit;
                        returnValue.append( Point(lat: currentLat, lon: currentLonLeft));
                        returnValue.append(Point(lat: currentLat, lon: currentLonRight));
                    }
                    
                }
            }
        }
        return returnValue;
    }
    
    //Convert from meter to lat lon degree, not sure if is right, for example, cos(latitude)*(180/R/Double.pi)*accuracy/1000 is conversion from meter to degree of longitude?
    public static func cal_degree(  accuracy:Double, latitude:Double)->Double{
        let R = 6378.137;
        let degree = accuracy/(2*Double.pi*6378137*cos(latitude/180*Double.pi)/360);
        return degree;
    }
    
    //Determine whether the grid is covered
    public static func grid_is_covered( lat:Double, lon:Double, gridID:String, radius :Double) -> Bool{
        var distanceToGrid:Double = radius + 1;
        var I1 = gridID.index(gridID.startIndex, offsetBy: 2)
        var I2 = gridID.index(gridID.startIndex, offsetBy: 9)
        var x:Int = Int(gridID[I1..<I2]) ?? 0 ;
        
        I1 = gridID.index(gridID.startIndex, offsetBy: 9)
        I2 = gridID.index(gridID.startIndex, offsetBy: 16)
        var y:Int = Int(gridID[I1..<I2]) ?? 0 ;
        print("grid_is_coverd "+gridID+" x:"+String(x)+" y:"+String(y))
        var twoToPower:Double = 1048576.0;
        //calculate lon/lat of current grid
        
        var minLon:Double = Double((360 * x)) / twoToPower - 180.0;
        var maxLon:Double = Double((360 * x+360)) / twoToPower - 180.0;
        
        var minLat:Double = 180/Double.pi*(2*atan(exp(Double.pi*(1.0-2.0*Double(y+1)/twoToPower)))-Double.pi/2);
        var maxLat:Double = 180/Double.pi*(2*atan(exp(Double.pi*(1-2.0*Double(y)/twoToPower)))-Double.pi/2);
        
        var gridLon:Double = Double(360 * x+180)/twoToPower - 180.0;
        var gridLat:Double = (maxLat+minLat)/2;
        
        if(!check) {
            halfGridWidth = cal_dis(lat1: gridLat,lon1: (gridLon + 180.0 / twoToPower), lat2: gridLat, lon2: gridLon);
            halfGridHeight = cal_dis(lat1: maxLat, lon1: gridLon, lat2: gridLat, lon2: gridLon);
            check = true;
        }
//
        var gridCenter:CoordinatePoint = pointToCoordinatePoint(center: Point(lat:lat,lon:lon),point: Point(lat:gridLat,lon:gridLon));
        var X:Double = gridCenter.getX();
        var Y:Double = gridCenter.getY();
        
        
        
        if(X>halfGridWidth && Y>halfGridHeight) {
            distanceToGrid = cal_dis(lat1: lat,lon1: lon,lat2: minLat, lon2: minLon);
        }
        else if(X > halfGridWidth && Y < -halfGridHeight) {
            distanceToGrid = cal_dis(lat1: lat,lon1: lon,lat2: maxLat, lon2: minLon);
        }
        else if(X < -halfGridWidth && Y > halfGridHeight) {
            distanceToGrid = cal_dis(lat1: lat,lon1: lon,lat2: minLat, lon2: maxLon);
        }
        else if(X < -halfGridWidth && Y < -halfGridHeight) {
            distanceToGrid = cal_dis(lat1: lat,lon1: lon,lat2: maxLat, lon2: maxLon);
        }
        
        
        if(X <= halfGridWidth && X >= -halfGridWidth) {
            if(Y>=0) {
                if(Y>halfGridHeight){
                    distanceToGrid = Y-halfGridHeight;
                }else{
                    distanceToGrid = Y;
                }
            }
            else {
                if((-Y)>halfGridHeight){
                    distanceToGrid = -Y-halfGridHeight;
                }else{
                    distanceToGrid = -Y;
                }
                   
            }
        }
        else if(Y<=halfGridHeight && Y >= -halfGridHeight) {
            if(X>=0) {
                if(X>halfGridWidth){
                    distanceToGrid = X-halfGridWidth;
                }else{
                    distanceToGrid = X;
                }
                    
            }
            else {
                if((-X)>halfGridWidth){
                    distanceToGrid = -X-halfGridWidth;
                }else{
                    distanceToGrid = -X;
                }
                    
            }
        }
        
        return distanceToGrid <= radius;
    }
    
    /*
     * Transfer from lat lon to Cartesian coordinate system in meters to meet the need of calculating coverage area
     */
    public static func pointToCoordinatePoint( center:Point,  point:Point) -> CoordinatePoint {
        var lat2:Double = center.getLat();
        var lat1:Double = point.getLat();
        var lon2:Double = center.getLon();
        var lon1:Double = point.getLon();
        
        var x:Double = lat1 - lat2;
        var y:Double = lon1 - lon2;
        
        var dislon:Double = cal_dis(lat1: lat2,lon1: lon1 , lat2: lat2, lon2: lon2);
        var dislat:Double = cal_dis(lat1: lat1, lon1: lon2, lat2: lat2, lon2: lon2);
        if (y == 0 && x > 0) {
            //North
            dislon = 0;
        }
        else if (y == 0 && x < 0) {
            //South
            dislon = 0;
            dislat = -dislat;
        }
        else if (x == 0 && y > 0) {
            //East
            dislat = 0;
        }
        else if (x == 0 && y < 0) {
            //West
            dislat = 0;
            dislon = -dislon;
            
        }
        else {
            if (x > 0 && y > 0) {
//                dislat = dislat;
//                dislon = dislon;
            }
            else if (x < 0 && y > 0) {
                dislat = -dislat;
            }
            else if (x < 0 && y < 0) {
                dislat = -dislat;
                dislon = -dislon;
            }
            else if (x > 0 && y < 0) {
                dislon = -dislon;
            }
            else if(x == 0 && y == 0) {
                dislat = 0;
                dislon = 0;
            }
        }
        let coordinatePoint:CoordinatePoint = CoordinatePoint(x: dislon, y: dislat);
        
        return coordinatePoint;
    }
    
    public static func pointsToCoordinatePoints( center:Point,Points:[Point])->[CoordinatePoint]{
        var coordinates:[CoordinatePoint] = [];
        for i in 0..<Points.count{
            let newPoint:CoordinatePoint = pointToCoordinatePoint(center: center, point: Points[i]);
            coordinates.append(newPoint);
        }
        return coordinates;
    }
    
    /*
     * For calculating coverage, the following codes may have problem because of different function call for C++ and java
     */
    
    private static func sign( x:Double)->Int{
        if(x>EPS){
            return 1;
        }
        return (x < -EPS) ? -1 : 0;
    }
    
    private static func myasin( x:Double)->Double{
        var temp_x = x;
        if(x > 1.0) {
            temp_x = 1.0;
        }
        if(x < -1.0) {
            temp_x = -1.0;
        }
            
        return asin(temp_x);
    }
    
    private static func root( a:Double, b:Double, c:Double, x1:ReferenceDouble, x2:ReferenceDouble)->Int{
        var delta:Double = b*b-4.0*a*c;
        var tmp:Int = sign(x: delta);

        if(tmp<0){ return 0;};

        if(0==tmp){
            x1.value = -b / ( a + a );
            x2.value = -b / ( a + a );
            return 1;
        }

        delta = sqrt(delta);
        x1.value = ( -b - (delta) ) / ( a + a );
        x2.value = ( -b + (delta) ) / ( a + a );
        return 2;
    }
    
    /*
     * Cross product
     */
    
    public static func cross( O:CoordinatePoint, A:CoordinatePoint, B:CoordinatePoint)->Double{
        let xoa = A.x - O.x;
        let yoa = A.y - O.y;
        let xob = B.x - O.x;
        let yob = B.y - O.y;
        return xoa * yob - xob * yoa;
    }
    public static func dot( O:CoordinatePoint, A:CoordinatePoint, B:CoordinatePoint)->Double{
        let xoa = A.x - O.x;
        let yoa = A.y - O.y;
        let xob = B.x - O.x;
        let yob = B.y - O.y;
        return xoa * xob + yob * yoa;
    }
    public static func dist2( A:CoordinatePoint, B:CoordinatePoint)->Double{
        let x = A.x - B.x;
        let y = A.y - B.y;
        return x*x+y*y;
    }
    
    public static func getAngle( O:CoordinatePoint, A:CoordinatePoint, B:CoordinatePoint)->Double{
        var area:Double = cross(O: O,A: A,B: B)*0.5;
        var ddot:Double = dot(O: O,A: A,B: B);
        if(0 == sign(x: area)){
            if(sign(x: ddot)>0){ return 0.0;};
            return Double.pi;
        }

        var OA :Double = sqrt(dist2(A: O,B: A));
        var OB :Double = sqrt(dist2(A: O,B: B));

        
        var theta:Double = myasin(x: area*2.0/(OA*OB));
        if(sign(x: ddot)>=0){
            return theta;
        }
        if(sign(x: area)>0){
            return Double.pi-theta;
        }
        return -theta - Double.pi;
    }
    
    public static func triangleAndCircleArea( O:CoordinatePoint, A:CoordinatePoint, B:CoordinatePoint, radius:Double)->Double{
        var area:Double = cross(O: O,A: A,B: B)*0.5;
        var s:Int = sign(x: area);
        if(0==s){ return 0.0;};

        let a = (B.x-A.x)*(B.x-A.x) + (B.y-A.y)*(B.y-A.y);
        let b = 2.0*( (B.x-A.x)*(A.x-O.x)+(B.y-A.y)*(A.y-O.y) );
        let c = (A.x-O.x)*(A.x-O.x)+(A.y-O.y)*(A.y-O.y)-radius*radius;

        var xone:ReferenceDouble =  ReferenceDouble(value:0);
        var xtwo:ReferenceDouble =  ReferenceDouble(value:0);
        var cnt:Int = root(a: a,b: b,c: c,x1: xone,x2: xtwo);
        var x1:Double = xone.value;
        var x2:Double = xtwo.value;
        
        var OA = sqrt(dist2(A: O,B: A));
        var OB = sqrt(dist2(A: O,B: B));
        var AB = sqrt(dist2(A: A,B: B));
        
        if(0==cnt||1==cnt){
            let theta = getAngle(O: O,A: A,B: B);
            return 0.5*radius*radius*theta;
        }

        if( sign(x: x2) < 0 || sign(x: x1-1.0) > 0 ){
            let theta = myasin(x: area*2.0/(OA*OB));
            return 0.5*radius*radius*theta;
        }

        if( sign(x: x1) < 0 && sign(x: x2-1.0) > 0 ){
            return area;
        }
        
        if( sign(x: x1) < 0 && sign(x: x2) >= 0 && sign(x: x2-1.0) <= 0 ){
            let theta = myasin(x: area*(1.0-x2)*2.0/(radius*OB));
            return area*x2 + 0.5*radius*radius*theta;
        }

        if( sign(x: x1) >= 0 && sign(x: x1-1.0) <= 0 && sign(x: x2-1.0) > 0 ){
            let theta = myasin(x: area*x1*2.0/(radius*OA));
            return area * (1.0-x1) + 0.5 * radius * radius * theta;
        }

        var theta1 = myasin(x: area*x1*2.0/(radius*OA));
        var theta2 = myasin(x: area*(1.0-x2)*2.0/(radius*OB));
        return area*(x2-x1) + 0.5*radius*radius*(theta1+theta2);
    }
    
    public static func calculateCoverageArea( points:[CoordinatePoint], accuracy:Double)->Double {
        var center = CoordinatePoint(x: 0,y: 0);
        var ans:Double = 0.0;
        for i in 0..<points.count-1 {
            ans += triangleAndCircleArea(O: center,A: points[i],B: points[i+1],radius: accuracy);
        }
        
        return abs(ans);
    }
    
}

class ReferenceDouble{
    var value = 0.0;
    init( value:Double){
        self.value = value;
    }
}
