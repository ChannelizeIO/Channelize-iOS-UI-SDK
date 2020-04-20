//
//  ChannelizeImages.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/12/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

class ChannelizeImages {
    var imageUrl : String?
    var videoUrl : String?
    var ownerName : String?
    var photoDate : Date?
    
    init(imageUrlString: String? = nil , videoUrlString: String? = nil, owner: String? = nil, date: Date? = nil) {
        self.imageUrl = imageUrlString
        self.videoUrl = videoUrlString
        self.ownerName = owner
        self.photoDate = date
    }
}

