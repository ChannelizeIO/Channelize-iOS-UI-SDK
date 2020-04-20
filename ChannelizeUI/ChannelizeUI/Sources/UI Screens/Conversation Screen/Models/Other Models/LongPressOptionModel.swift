//
//  LongPressOptionModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/16/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

enum LongPressOptionActionType: String {
    case reply = "chReply"
    case delete = "chDeleteButton"
    case forward = "chForwardButton"
    case more = "chMoreIcon"
    case deleteAll = "chDeleteAll"
    case forwardAll = "chForwardAll"
    case undefined = ""
}

class LongPressOptionModel {
    var label: String?
    var actionType: LongPressOptionActionType?
    
    init(label: String?, action: LongPressOptionActionType?) {
        self.label = label
        self.actionType = action
    }
    
}

