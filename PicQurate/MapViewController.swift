//
//  MapViewController.swift
//  PicQurate
//
//  Created by ShaoweiZhang on 15/8/15.
//  Copyright (c) 2015年 SK8 PTY LTD. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationArray: [AVGeoPoint] = [];
    var locationNameArray: [String]  = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.navigationItem.title = "Chain Map"
        
        var locationPoints:[CLLocationCoordinate2D] = [];
        let latDelta:CLLocationDegrees = 100;
        let lonDelta: CLLocationDegrees = 100;
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta);
//                test polyline
//                var newLocationArray: [CLLocationCoordinate2D] = [];
//                let l1 = CLLocationCoordinate2DMake(-37, 144);
//                let l2 = CLLocationCoordinate2DMake(-35, 149);
//                let l3 = CLLocationCoordinate2DMake(-33, 151);
//        
//                newLocationArray.append(l1);
//                newLocationArray.append(l2);
//                newLocationArray.append(l3);
        for (var i = 0; i < locationNameArray.count; i++){
            NSLog("i: \(i)");
            NSLog("locationArray \(i) : \(locationArray[i])");
            let l = locationArray[i];
            NSLog("\(l.latitude) + \(l.longitude)");
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(l.latitude, l.longitude);
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span);
            mapView.setRegion(region, animated: true);
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = location;
            annotation.title = "\(locationNameArray[i])";
            mapView.addAnnotation(annotation);
            
            locationPoints.append(location);
        }
        
        NSLog("locationPoints: \(locationPoints.count)");
        if locationPoints.count > 1 {
            var geodesic = MKGeodesicPolyline(coordinates: &locationPoints[0], count: locationPoints.count);
            NSLog("geodesic: \(geodesic)");
            self.mapView.addOverlay(geodesic);
            UIView.animateWithDuration(1.5, animations: { () -> Void in
                let region1 = MKCoordinateRegion(center: locationPoints[0], span: span)
                self.mapView.setRegion(region1, animated: true)
            })
        }
        
        for x in locationPoints {
            NSLog("Location in Array : \(x.latitude) ---- \(x.longitude)");
        }


        
//        locationArray = [];
//        locationNameArray = [];
    
        // Do any additional setup after loading the view.
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
