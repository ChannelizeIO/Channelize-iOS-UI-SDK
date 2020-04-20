//
//  AttachmentModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

enum AttachmentType {
    case image
    case video
    case audio
    case location
    case gif
    case sticker
    case undefined
}

class AttachmentModel {
    var type: AttachmentType?
    var label: String?
    var icon: String?
    
    init(type: AttachmentType?, label: String?, icon: String?) {
        self.type = type
        self.label = label
        self.icon = icon
    }
}

