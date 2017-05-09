//
//  ViewController.swift
//  LocationNDirection
//
//  Created by sagar on 07/05/17.
//  Copyright © 2017 Sagar. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController,CLLocationManagerDelegate,UISearchBarDelegate,GMSAutocompleteViewControllerDelegate,GMSMapViewDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    var locationManager:CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var locality = ""
    var administrativeArea = ""
    var isLocationbool : Bool!
    @IBOutlet var mapView : GMSMapView!
    var marker : GMSMarker!
    var destinationMarker: GMSMarker!
    var latitudeStr = ""
    var longitudeStr = ""
    var isGoogleSearch : Bool!
    var strDestinationLatLong: String = String()
    var strLat:Double = Double()
    var strLong:Double = Double()
    var destinationLocation: CLLocation!
    var sourceLocation: CLLocation!
    
    @IBOutlet var pinImgview: UIImageView!
    
    @IBOutlet var labelDistNTime: UILabel!
    var totalDistanceInMeters: UInt = 0
    var totalDistance: String!
    var totalDurationInSeconds: UInt = 0
    var totalDuration: String!
    var APIKEY : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        APIKEY = "AIzaSyCaA4sR9aiFmldaqBDZ9dL6_yG4501T2bI"
        
        isGoogleSearch = false
        isLocationbool = false
        navigationItem.titleView = UIImageView(image: UIImage(named: "homelogo.png"))
        
        self.mapView.delegate = self
        marker = GMSMarker()
        
        marker.title = "\(locality)" //"Sydney"
        marker.snippet = "\(self.administrativeArea)" //"Australia"
        marker.map = mapView
        
        marker.map = nil //To hide the marker
        mapView.settings.myLocationButton = false
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        Search()
         DispatchQueue.main.async(execute: {() -> Void in
            let alert = UIAlertController(title: "Alert", message: "Please enter in searchbar as destination and then click on GetDirection button", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            })
        
    }
    
    func Search()
    {
        searchBar.delegate = self
        
        //Searchbar text color
        for subView in self.searchBar.subviews
        {
            for subView in subView.subviews
            {
                if let textField = subView as? UITextField
                {
                    textField.textColor = UIColor.white
                    textField.backgroundColor = UIColor(red: 28.0/255.0, green: 61.0/255.0, blue: 106.0/255.0, alpha: 1.0)
                    // to clear cross mark
                    textField.clearButtonMode = .never
                }
            }
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        if isLocationbool == false
        {
            isLocationbool = true
            let latestLocation: AnyObject = locations[locations.count - 1]
            
            if startLocation == nil
            {
                startLocation = latestLocation as! CLLocation
            }
            
            let position = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
            mapView.camera=GMSCameraPosition.camera(withTarget: position, zoom: 18)
            marker.position=position
            mapView.settings.myLocationButton = false // adds a button to the map, when tapped, centers the map on the user’s location
            
        }
//          manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Failed to find user's location: \(error.localizedDescription)")
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                
                print("No access")
                
            case .authorizedAlways, .authorizedWhenInUse:
                
                print("Access")
                
            }
            
        } else {
            
            print("Location services are not enabled")
            
        }
        
        print("Error while updating location " + error.localizedDescription)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
    {
        DispatchQueue.main.async(execute: {() -> Void in
        self.isLocationbool = false
        
        self.dismiss(animated: true, completion: nil)
        self.searchBar.resignFirstResponder()
        self.searchBar.text = "\(place.formattedAddress!)" //"\(place.name)" +
        
        let position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        self.mapView.camera = GMSCameraPosition.camera(withTarget: position, zoom: 18)
        
        let latiStr: String = String(format: "%.8f", place.coordinate.latitude)
        let longStr: String = String(format: "%.8f", place.coordinate.longitude)
        
        self.latitudeStr = latiStr
        self.longitudeStr = longStr
        
        self.strLat = place.coordinate.latitude
        self.strLong = place.coordinate.longitude
        self.strDestinationLatLong = String(format: "%f,%f", self.strLat,self.strLong)
        print(self.strDestinationLatLong)
        
        UserDefaults.standard.set(true, forKey: "AddressFromSearchBar")
        UserDefaults.standard.set(self.searchBar.text, forKey: "SetAddress")
        UserDefaults.standard.set(self.strDestinationLatLong, forKey: "DestinationLatLong")
        
        self.isGoogleSearch = true
        
       
            
            self.marker.position = position
            CATransaction.commit()
        })
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        //        let location = CLLocationCoordinate2D(latitude:(locationManager.location?.coordinate.latitude)!,longitude:(locationManager.location?.coordinate.longitude)!)
        isLocationbool = false
        
        destinationLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        
        print(position.target.latitude)
        print(position.target.longitude)
        
        strLat = position.target.latitude
        strLong = position.target.longitude
        //        var geocoder: CLGeocoder = CLGeocoder()
        
        //--- CLGeocode to get address of current location ---//
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(strLat),\(strLong)&key=AIzaSyCaA4sR9aiFmldaqBDZ9dL6_yG4501T2bI"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    OperationQueue.main.addOperation({
//
                        let  placemarkData = json["results"] as! NSArray
                        print(placemarkData)
                        let place = placemarkData[0] as! NSDictionary
                    let placefull = place.object(forKey:"formatted_address") as! NSString
                    print(placefull)
                        self.searchBar.text = placefull as String
                        self.strDestinationLatLong = "\(self.latitudeStr)"+","+"\(self.longitudeStr)"
                        self.strDestinationLatLong = String(format: "%f,%f", self.strLat,self.strLong)
                        print(self.strDestinationLatLong)
                        UserDefaults.standard.set(true, forKey: "AddressFromSearchBar")
                        UserDefaults.standard.set(self.searchBar.text, forKey: "SetAddress")
                        UserDefaults.standard.set(self.strDestinationLatLong, forKey: "DestinationLatLong")
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
        
    }
    
    func GoogleMapsMethod()
    {
    }
    
    @IBAction func SaveAction(_ sender: AnyObject)
    {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func BackAction(_ sender: AnyObject)
    {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func GetDistance(_ sender: Any)
    {
        
        self.drawPath()
        labelDistNTime.text = "Total Distance: "+String(describing: distanceBetweenTwoLocations(source: startLocation, destination: destinationLocation))+" KM"
//        print(labelDistNTime.text)
    }
    
    func distanceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double{
        
        let distanceMeters = source.distance(from: destination)
        let distanceKM = distanceMeters / 1000
//        let roundedTwoDigit = distanceKM.roundedTwoDigit
        return distanceKM
        
    }
    
    func drawPath()
    {
        self.pinImgview.isHidden = true
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"
        print("origin: \(origin)")
        print("destination: \(destination)")
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(APIKEY)&alternatives=true"
        print("urlString: \(urlString)")
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    self.mapView.clear()
                    
                    OperationQueue.main.addOperation({
                        var i = 1
                        for route in routes
                        {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            
                            if i == 1
                            {
                                polyline.strokeColor = UIColor.green
                            }else if i == 2
                            {
                                polyline.strokeColor = UIColor.blue
                            }else
                            {
                                polyline.strokeColor = UIColor.red
                            }
                            
                            i = i+1
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            
                            polyline.map = self.mapView
                            
                        }
                        self.marker = GMSMarker(position: self.startLocation.coordinate)
                        self.marker.map = self.mapView
                        self.marker.icon = GMSMarker.markerImage(with: UIColor.green)
                        self.destinationMarker = GMSMarker(position: self.destinationLocation.coordinate)
                        self.destinationMarker.map = self.mapView
                        self.destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
}

