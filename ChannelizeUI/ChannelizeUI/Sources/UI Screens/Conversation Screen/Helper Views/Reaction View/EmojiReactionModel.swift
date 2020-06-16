//
//  EmojiReactionModel.swift
//  ChannelizeUI
//
//  Created by bigstep on 5/3/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

class EmojiReactionModel {
    var emojiCode: String?
    var isSelected: Bool?
    var emojiKey: String?
    
    init() {
        
    }
}

class ReactionModel: Equatable {
    
    static func == (lhs: ReactionModel, rhs: ReactionModel) -> Bool {
        return true
    }
    
    var unicode: String?
    var counts: Int?
    
    init() {
        
    }
}
