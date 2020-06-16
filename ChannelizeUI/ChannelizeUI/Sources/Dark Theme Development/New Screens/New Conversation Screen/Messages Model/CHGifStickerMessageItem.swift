import Foundation
import UIKit

class GifStickerMessageData: Equatable {
    static func == (lhs: GifStickerMessageData, rhs: GifStickerMessageData) -> Bool {
        return lhs.stillUrl == rhs.stillUrl &&
            lhs.downSampledUrl == rhs.downSampledUrl &&
            lhs.originalUrl == rhs.originalUrl
    }
    
    var stillUrl: String?
    var downSampledUrl: String?
    var originalUrl: String?
    
    init(stillUrl: String?, downSampledUrl: String?, originalUrl: String?) {
        self.stillUrl = stillUrl
        self.downSampledUrl = downSampledUrl
        self.originalUrl = originalUrl
    }
    
}

class GifStickerMessageItem: ChannelizeChatItem {
    var gifStickerData: GifStickerMessageData?
    
    init(baseMessageModel: BaseMessageModel, gifStickerData: GifStickerMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: .gifSticker)
        self.gifStickerData = gifStickerData
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = GifStickerMessageItem(baseMessageModel: self.baseMessageModel, gifStickerData: self.gifStickerData)
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        item.myMessageReactions = self.myMessageReactions
        item.showUnreadMessageLabel = self.showUnreadMessageLabel
        item.reactions = self.reactions
        item.reactionCountsInfo = self.reactionCountsInfo
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let gifStickerSource = source as? GifStickerMessageItem else {
            return false
        }
        let check = gifStickerSource.baseMessageModel == self.baseMessageModel &&
            gifStickerSource.messageType == self.messageType &&
            gifStickerSource.messageStatus == self.messageStatus &&
            gifStickerSource.showSenderName == self.showSenderName &&
            gifStickerSource.showDataSeperator == self.showDataSeperator &&
            gifStickerSource.showMessageStatusView == self.showMessageStatusView &&
            gifStickerSource.isMessageSelectorOn == self.isMessageSelectorOn &&
            gifStickerSource.isMessageSelected == self.isMessageSelected &&
            gifStickerSource.gifStickerData == self.gifStickerData &&
            gifStickerSource.reactions == self.reactions &&
            gifStickerSource.myMessageReactions == self.myMessageReactions &&
            gifStickerSource.reactionCountsInfo == self.reactionCountsInfo &&
            gifStickerSource.showUnreadMessageLabel == self.showUnreadMessageLabel
        return check
    }
}
