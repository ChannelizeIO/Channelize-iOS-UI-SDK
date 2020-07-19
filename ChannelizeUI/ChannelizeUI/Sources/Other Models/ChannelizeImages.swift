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
    var ownerId: String?
    var isEncrypted: Bool?
    var messageId: String
    
    init(messageId: String, imageUrlString: String? = nil , videoUrlString: String? = nil, owner: String? = nil, date: Date? = nil, ownerId: String?, isEncrypted: Bool? = false) {
        self.imageUrl = imageUrlString
        self.videoUrl = videoUrlString
        self.ownerName = owner
        self.photoDate = date
        self.ownerId = ownerId
        self.isEncrypted = isEncrypted
        self.messageId = messageId
    }
}


