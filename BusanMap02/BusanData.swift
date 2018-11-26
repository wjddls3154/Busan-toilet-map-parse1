//
//  BusanData.swift
//  BusanMap02
//
//  Created by 김종현 on 30/10/2018.
//  Copyright © 2018 김종현. All rights reserved.
//

import Foundation
import MapKit

class BusanData: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var openTime: String?
    var type: String?
    var toiletName: String?
   
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, openTime: String, type: String, toiletName: String ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.toiletName = toiletName
        self.openTime = openTime
        self.type = type
        
    }
}
