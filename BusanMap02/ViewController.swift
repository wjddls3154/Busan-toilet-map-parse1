//
//  ViewController.swift
//  BusanMap02
//
//  Created by 김종현 on 30/10/2018.
//  Copyright © 2018 김종현. All rights reserved.
//  XCode 108.1

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, XMLParserDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var annotation: BusanData?
    var annotations: Array = [BusanData]()
    
    var item:[String:String] = [:]  // item[key] => value
    var items:[[String:String]] = []
    var currentElement = ""
    
    
    var address: String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
    var tn: String?
    var ty: String?
    
    // 1시간 마다 호출위해 타이머 객체 생성
    var timer = Timer()
    var currentTime: String?
    
    // 광복동, 초량동
    let addrs:[String:[String]] = [
        "부산광역시 연제구청" : ["양정2동 중앙대로 993", "35.178463", "129.074502", "노인종합복지관", "개방화장실"],
        "부산광역시 연제구청2" : ["연산동 쌍미천로44번길 17", "35.178289", "129.091026", "동명초등학교", "개방화장실"],
        "부산광역시 연제구청3" : ["거제1동 교대로 3", "35.194962", "129.078271", "이사벨중학교", "개방화장실"],
        "부산광역시 연제구청4" : ["연제구 교대로 24", "35.196127", "129.075091", "부산교육대학교", "개방화장실"],
        "부산광역시 연제구청5" : ["거제1동 교대로24번길 36", "35.197352", "129.076942", "거학초등학교", "개방화장실"],
        // 부산 연제
        "부산광역시 강서구청" : ["송정동 1718", "35.089047", "128.844275", "녹산 공영주차장", "공중화장실"],
        "부산광역시 강서구청2" : ["지사동 478", "35.139185", "128.834024", "녹산 흥국사", "간이화장실"],
        // 부산 강서
        "부산광역시 사상구청" : ["삼락동 삼덕로5번길 85", "35.178498", "128.978115", "사상중앙병원", "개방화장실"],
        "부산광역시 사상구청2" : ["학장동 194-18", "35.140942", "128.989788", "구덕산충전소", "개방화장실"],
        "부산광역시 사상구청3" : ["학장동 629-1", "35.138723", "128.973586", "개인택시사상LPG충전소", "개방화장실"],
        "부산광역시 사상구청4" : ["주례2동 가야대로 326", "35.150348", "129.007799", "좋은삼선병원", "개방화장실"],
        // 부산 사상
        
        // 부산 북구
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산 미세먼지 지도"
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
    
        myMapView.showsUserLocation = true
        myMapView.showsCompass = true
        
        myParse()
        timer = Timer.scheduledTimer(timeInterval: 60*60, target: self, selector: #selector(myParse), userInfo: nil, repeats: true)
        
        // Map
        myMapView.delegate = self
        
        //  초기 맵 region 설정
        zoomToRegion()
        
        for item in items {
            let instName = item["instName"]
            print("instName = \(String(describing: instName))")
            
            // 추가 데이터 처리
            for (key, value) in addrs {
                if key == instName {
                    address = value[0]
                    lat = value[1]
                    long = value[2]
                    tn = value[3]
                    ty = value[4]
                    dLat = Double(lat!)
                    dLong = Double(long!)
                }
            }
            
            // 파싱 데이터 처리
         
          
            let tOpenTime = item["openTime"]
            let toiletName = item["toiletName"]
            
            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: instName!, subtitle: toiletName!, openTime: tOpenTime!, type: ty!, toiletName: tn!)

            annotations.append(annotation!)
        }
        
      
        myMapView.addAnnotations(annotations)

    }
    
    @objc func myParse() {
        // XML Parsing
        let key = "dH7oyxOq53N%2B%2FRde8Bv2BfStdElt4%2BYo8Y2uv0qcVTAEE2JZi3fsxzkkncorSPsCWBb%2Fp4m4l2T6c80hxRzbrA%3D%3D"
        let strURL = "http://opendata.busan.go.kr/openapi/service/PublicToilet/getToiletInfoList?ServiceKey=\(key)&numOfRows=30"
        
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if (parser.parse()) {
                    print("parsing success")
                    
                    // 파싱이 끝난시간 시간 측정
                    let date: Date = Date()
                    let dayTimePeriodFormat = DateFormatter()
                    dayTimePeriodFormat.dateFormat = "YYYY/MM/dd HH시 MM분"
                    currentTime = dayTimePeriodFormat.string(from: date)
                    for item in items {
                        print("item tel = ")
                    }
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
        
    }
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeToOriginLocation(_ sender: Any) {
        
        let currnetLoc: CLLocation = locationManager.location!
        let location = CLLocationCoordinate2D(latitude: currnetLoc.coordinate.latitude, longitude: currnetLoc.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
    }
    

    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Leave default annotation for user location
        if annotation is MKUserLocation {
            return nil
        }

        let reuseID = "MyPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if annotationView == nil {
            let pin = MKPinAnnotationView(annotation: annotation,
                                       reuseIdentifier: reuseID)
//            pin.image = UIImage(named: "marker-30")
            pin.isEnabled = true
            pin.canShowCallout = true
            
            let castBusanData = annotation as! BusanData
      
            

            let label = UILabel(frame: CGRect(x: -2, y: 12, width: 30, height: 30))
            
//            label.text = annotation.id // set text here
            
            //let castBusanData = annotation as! BusanData
            
            label.text = castBusanData.toiletName
            pin.addSubview(label)
            annotationView = pin
            
            
        } else {
            annotationView?.annotation = annotation
        }

        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }
    
    // rightCalloutAccessoryView를 눌렀을때 호출되는 delegate method
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let viewAnno = view.annotation as! BusanData // 데이터 클래스로 형변환(Down Cast)
        //let vPM10 = viewAnno.subtitle
        let vStation = viewAnno.title
        //let vPM10Cai = viewAnno.toiletName
        
       
        
       let tOpenTime = item["openTime"]
        let ac = UIAlertController(title: vStation! + "제공", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "현재시간 : " + currentTime! , style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "오픈시간 : " + tOpenTime! , style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "화장실명 : " + tn!, style: .default, handler: nil))
        //관리기관
        ac.addAction(UIAlertAction(title: "구분 : " + ty!, style: .default, handler: nil))
        //개방시간
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
        
    }
    
   
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        // tag 이름이 elements이거나 item이면 초기화
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //        print("data = \(data)")
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
}

