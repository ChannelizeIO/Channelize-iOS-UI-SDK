//
//  CHGiphImageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/7/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ObjectMapper

class CHGiphImageModel: Mappable {
    
    var originalUrl: String?
    var downSampledUrl: String?
    var stillUrl: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.originalUrl <- map["originalUrl"]
        self.downSampledUrl <- map["downSampledUrl"]
        self.stillUrl <- map["stillUrl"]
    }
}


