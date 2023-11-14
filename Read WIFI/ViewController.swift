//
//  ViewController.swift
//  Read WIFI
//
//  Created by alifu on 14/11/23.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation

// all code from https://stackoverflow.com/a/64852900

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    
    let ssidLabel:UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let bssidLabel:UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(ssidLabel)
        view.addSubview(bssidLabel)
        NSLayoutConstraint.activate([
            ssidLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ssidLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bssidLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            bssidLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
        ])
        
        if #available(iOS 13.0, *) {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedWhenInUse {
                updateWiFi()
            } else {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            updateWiFi()
        }
    }
    
    func updateWiFi() {
        print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
        
        if let ssid = currentNetworkInfos?.first?.ssid {
            ssidLabel.text = "SSID: \(ssid)"
        }
        
        if let bssid = currentNetworkInfos?.first?.bssid {
            bssidLabel.text = "BSSID: \(bssid)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            updateWiFi()
        }
    }
}

public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false,
                                              ssid: nil,
                                              bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }
}

struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}
