//
//  NetworkState.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/14/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import Alamofire

class NetworkState {
    
    var manager: NetworkReachabilityManager?
    var onNotReachable: (() -> Void)?
    var onReachable: (() -> Void)?
    //var onApiLoaded: ((_ cell: [CHUser]) -> Void)?
    static var instance: NetworkState = {
        let instance = NetworkState()
        return instance
    }()
    
    init() {
        self.manager = NetworkReachabilityManager()
        self.manager?.listener = { status in
            switch status {
            case .notReachable:
                self.onNotReachable?()
                break
            case .reachable(.ethernetOrWiFi):
                self.onReachable?()
                break
            case .reachable(.wwan):
                self.onReachable?()
                break
            case .unknown:
                break
            }
        }
        self.manager?.startListening()
    }
}



