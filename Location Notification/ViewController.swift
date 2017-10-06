//
//  ViewController.swift
//  Location Notification
//
//  Created by Urmila on 06/10/17.
//  Copyright © 2017 Urmila. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet var MapViewGMS: GMSMapView!
    
    var locationManager = CLLocationManager()
    
    var addressList: [String] = ["Best Buy,529 5th Ave, New York, NY 10017, USA", "Best Buy,52 E 14th St #64, New York, NY 10003, USA", "Best Buy,622 Broadway, New York, NY 10012, USA", "Best Buy,1880 Broadway, New York, NY 10023, USA",
                                 "Best Buy,1280 Lexington Ave, New York, NY 10028, USA", "Best Buy,60 W 23rd St, New York, NY 10010, USA", "Best Buy,8801 Queens Blvd, Forest Hills, NY 11373, USA", "Best Buy,610 Exterior Street, Bronx, NY 10451, USA"]
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
               let location = locations.last
        
                     let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
                     MapViewGMS.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
        //search for the address of stores in the input
        for index in 0..<addressList.count {
            let add1 = addressList[index]
            print(add1)
            findStores(locationcur: location!, locationstor: add1)
        }

    }
    
    func findStores(locationcur: CLLocation, locationstor:String)
    {
        
        let addrs = locationstor
        CLGeocoder().geocodeAddressString(locationstor) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let searchlocation = placemarks?.first?.location {
                    print("The address and location in longitude and latitude")
                    print(searchlocation.coordinate.latitude)
                    print(searchlocation.coordinate.longitude)
                    
                    let position = CLLocationCoordinate2D(latitude: searchlocation.coordinate.latitude, longitude: searchlocation.coordinate.longitude)
                    let marker = GMSMarker(position: position)
                    marker.title = addrs
                    marker.map = self.MapViewGMS
                    
                    //start
                    let origin = "\(locationcur.coordinate.latitude),\(locationcur.coordinate.longitude)"
                    let destination = "\(searchlocation.coordinate.latitude),\(searchlocation.coordinate.longitude)"
                    print(origin)
                    
                    print(destination)
                    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCMXXMjfDFRee3P-2LKX0njDTC8r6E1kQQ"
                    
                    let url = URL(string: urlString)
                    URLSession.shared.dataTask(with: url!, completionHandler: {
                        (data, response, error) in
                        if(error != nil){
                            print("error")
                        }else{
                            do{
                                let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                                print(json)
                                let routes = json["routes"] as! NSArray
                               // self.mapView.clear()
                                
                                OperationQueue.main.addOperation({
                                    for route in routes
                                    {
                                        let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                        let points = routeOverviewPolyline.object(forKey: "points")
                                        let path = GMSPath.init(fromEncodedPath: points! as! String)
                                        let polyline = GMSPolyline.init(path: path)
                                        polyline.strokeWidth = 3
                                        
                                        let bounds = GMSCoordinateBounds(path: path!)
                                        self.MapViewGMS!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                                        
                                        polyline.map = self.MapViewGMS
                                        
                                    }
                                })
                            }catch let error as NSError{
                                print("error:\(error)")
                            }
                        }
                    }).resume()
                    
                    //end
                    
                }
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Find Current Location
        
        MapViewGMS.isMyLocationEnabled = true
        MapViewGMS.delegate = self
        
        //Location Manager code to fetch current location
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}





