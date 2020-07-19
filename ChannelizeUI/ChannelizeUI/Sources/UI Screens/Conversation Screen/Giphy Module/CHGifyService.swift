//
//  CHGifyService.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/7/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

class CHGifyService {
    
    static var giphyKey: String?
    
    static var instance: CHGifyService = {
        let instance = CHGifyService()
        return instance
    }()
    
    static func configureGiphy(with key: String) {
        self.giphyKey = key
    }
    
    static func getGiphyKey() -> String {
        return giphyKey ?? ""
    }
}


