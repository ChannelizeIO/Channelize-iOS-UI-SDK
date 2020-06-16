//
//  CHRecentConversationCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/23/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import SDWebImage
import ChannelizeAPI
import ObjectMapper

class CHRecentConversationCell: UITableViewCell {
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.normalSizeMediumFont
        label.backgroundColor = .clear
        return label
    }()
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.mediumSizeRegularFont
        label.backgroundColor = .clear
        return label
    }()
    
    var lastMessageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.smallSizeRegularFont
        label.backgroundColor = .clear
        label.textAlignment = .right
        return label
    }()
    
    var messageStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var unreadMessageCountLabel: UILabel = {
        let label = UILabel()
        label.layer.masksToBounds = true
        label.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        label.textColor = .white
        label.font = CHCustomStyles.smallSizeRegularFont
        label.textAlignment = .center
        return label
    }()
    
    var attachmentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var conversation: CHConversation?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setUpViews() {
        self.addSubview(profileImageView)
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        self.addSubview(lastMessageTimeLabel)
        self.addSubview(messageStatusImageView)
        self.addSubview(unreadMessageCountLabel)
        self.addSubview(attachmentImageView)
    }
    
    func setUpViewsFrames() {
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.center.y = self.frame.height/2
        self.profileImageView.frame.origin.x = 15
        //self.profileImageView.frame.origin = CGPoint(x: 15, y: 12.5)
        self.profileImageView.setViewCircular()
        
        self.titleLabel.frame.origin.y = self.profileImageView.frame.origin.y
        self.titleLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.titleLabel.frame.size.height = 25
        self.titleLabel.frame.size.width = self.frame.width - self.titleLabel.frame.origin.x - 110
        
        self.attachmentImageView.frame.size = CGSize(width: 0, height: 0)
        self.attachmentImageView.frame.origin.y = getViewEndOriginY(view: self.titleLabel) + 2.5
        self.attachmentImageView.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        
        self.messageLabel.frame.origin.y = getViewEndOriginY(view: self.titleLabel)
        self.messageLabel.frame.origin.x = getViewEndOriginX(view: self.attachmentImageView)
        self.messageLabel.frame.size.height = 25
        self.messageLabel.frame.size.width = self.frame.width - self.messageLabel.frame.origin.x - 80
        
        self.lastMessageTimeLabel.frame.size = CGSize(width: 90, height: 25)
        self.lastMessageTimeLabel.center.y = self.titleLabel.center.y
        self.lastMessageTimeLabel.frame.origin.x = self.frame.width - 100
        
        self.messageStatusImageView.frame.size = CGSize(width: 17.5, height: 17.5)
        self.messageStatusImageView.center.y = self.messageLabel.center.y
        //self.messageStatusImageView.center.x = self.lastMessageTimeLabel.center.x
        self.messageStatusImageView.frame.origin.x = self.frame.width - 30
        
        self.unreadMessageCountLabel.frame.size = CGSize(width: 22.5, height: 22.5)
        self.unreadMessageCountLabel.center.y = self.messageLabel.center.y
        self.unreadMessageCountLabel.center.x = self.messageStatusImageView.center.x
        
        self.separatorInset.left = self.titleLabel.frame.origin.x
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
        self.titleLabel.textColor = CHUIConstant.recentConversationTitleColor
        self.messageLabel.textColor = CHUIConstant.recentConversationMessageColor
        self.lastMessageTimeLabel.textColor = CHUIConstant.recentConversationLastUpdatedColor
    }
    
    func assignData() {
        guard let conversationData = self.conversation else {
            return
        }
        let profileImageUrlString = conversationData.isGroup == true ? conversationData.profileImageUrl ?? "" : conversationData.conversationPartner?.profileImageUrl ?? ""
        let conversationTitle = conversationData.isGroup == true ? conversationData.title ?? "" : conversationData.conversationPartner?.displayName?.capitalized ?? ""
        
        self.titleLabel.text = conversationTitle
        self.createMessageAttributedString()
        if let lastUpdatedDate = conversationData.lastMessage?.createdAt {
            let lastUpdatedTimeString = getTimeStamp(lastUpdatedDate)
            self.lastMessageTimeLabel.text = lastUpdatedTimeString
        } else {
            self.lastMessageTimeLabel.text = nil
        }
        
        if let profileImageUrl = URL(string: profileImageUrlString) {
            self.profileImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: conversationTitle, imageSize: self.profileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.profileImageView.image = image
        }
        
        let countWidth = "\(conversationData.unreadMessageCount ?? 0)".widthOfString(usingFont: UIFont(fontStyle: .regular, size: 12.0)!)
        if countWidth + 9 > 22.5 {
            self.unreadMessageCountLabel.frame.size.width = countWidth + 10
        }
        self.unreadMessageCountLabel.layer.cornerRadius = self.unreadMessageCountLabel.frame.height/2
        self.unreadMessageCountLabel.text = "\(conversationData.unreadMessageCount ?? 0)"
        
        
        if conversationData.lastMessage?.ownerId == Channelize.getCurrentUserId() {
            self.getMessageStatus(itemMessageDate: conversationData.lastMessage?.createdAt ?? Date(), completion: {(messageStatus) in
                switch messageStatus {
                case .seen:
                    self.messageStatusImageView.image = getImage("chDoubleTickIcon")
                    self.messageStatusImageView.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
                    break
                default:
                    self.messageStatusImageView.image = getImage("chSingleTickIcon")
                    self.messageStatusImageView.tintColor = CHUIConstant.recentConversationLastUpdatedColor
                    break
                }
                if conversationData.lastMessage?.messageType == .admin {
                    self.messageStatusImageView.isHidden = true
                    self.unreadMessageCountLabel.isHidden = true
                } else {
                    self.messageStatusImageView.isHidden = false
                    self.unreadMessageCountLabel.isHidden = true
                }
            })
        } else {
            self.messageStatusImageView.isHidden = true
            if conversationData.unreadMessageCount != 0 {
                if conversationData.lastMessage == nil {
                    self.unreadMessageCountLabel.isHidden = true
                } else {
                    self.unreadMessageCountLabel.isHidden = false
                }
            } else {
                self.unreadMessageCountLabel.isHidden = true
            }
        }
    }
    
    private func createMessageAttributedString() {
        self.messageLabel.attributedText = nil
        guard self.conversation?.isTyping == false else {
            let typingAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: CHCustomStyles.mediumSizeRegularFont!, NSAttributedString.Key.foregroundColor: CHUIConstant.recentScreenTypingColor]
            var typingString = ""
            if self.conversation?.isGroup == true {
                typingString = String(format: CHLocalized(key: "pmUserTyping"), self.conversation?.typingUserName?.capitalized ?? "")
            } else {
                typingString = CHLocalized(key: "pmTyping")
            }
            self.messageLabel.attributedText = NSAttributedString(string: typingString, attributes: typingAttributes)
            return
        }
        
        guard let lastMessage = self.conversation?.lastMessage else {
            self.messageLabel.attributedText = nil
            return
        }
        
        guard lastMessage.isDeleted == false else {
            let stringAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: CHCustomStyles.mediumSizeRegularFont!, NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationMessageColor]
            self.messageLabel.attributedText = NSAttributedString(string: CHLocalized(key: "pmMessageDeleted"), attributes: stringAttributes)
            return
        }
        
        if let messageString = lastMessage.getMessageAttributedString() {
            //print("Setting Message from Saved String")
            self.messageLabel.attributedText = messageString
        } else {
            //print("Setting Message from Not Saved String")
            if lastMessage.messageType == .admin {
                let attributedString = self.createMetaDataString(lastMessage: lastMessage)
                lastMessage.setMessageAttributedString(attributedString: attributedString)
                self.messageLabel.attributedText = attributedString
                //self.messageLabel.attributedText = self.createMetaDataString(lastMessage: lastMessage)
            } else {
                if (lastMessage.attachments?.first) != nil {
                    let attachmentAttributedString = self.createAttachmentAttributedString(lastMessage: lastMessage)
                    lastMessage.setMessageAttributedString(attributedString: attachmentAttributedString)
                    self.messageLabel.attributedText = attachmentAttributedString
                } else {
                    let normalMessageString = self.createNormalMessageString(lastMessage: lastMessage)
                    lastMessage.setMessageAttributedString(attributedString: normalMessageString)
                    self.messageLabel.attributedText = normalMessageString
                }
            }
        }
    }
    
    
    private func createMetaDataString(lastMessage: CHMessage) -> NSAttributedString {
        var messageString = ""
        if let firstAttachment = lastMessage.attachments?.first {
            guard firstAttachment.type == .metaMessage else  {
                return NSAttributedString(string: messageString)
            }
            guard let messageType = firstAttachment.adminMessageType else {
                return NSAttributedString(string: messageString)
            }
            guard let metaData = firstAttachment.metaData else {
                return NSAttributedString(string: messageString)
            }
            switch messageType {
            case .groupCreate:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                let groupName = metaData.objectValues as? String ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                messageString = String(format: CHLocalized(key: "pmMetaGroupCreate"), arguments: [subjectString,groupName])
                
            case .addMembers:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                var addedUsersName = [String]()
                if let objectUsers = metaData.objectUsers {
                    objectUsers.forEach({
                        addedUsersName.append($0.displayName?.capitalized ?? "")
                    })
                }
                let addedUserString = addedUsersName.joined(separator: ",")
                messageString = String(format: CHLocalized(key: "pmMetaGroupAddMembers"), arguments: [subjectString,addedUserString])
                
            case .groupLeave:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                messageString = String(format: CHLocalized(key: "pmMetaGroupLeave"), subjectString)
                
            case .removeMember:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                var removedUsersName = [String]()
                if let removedMembers = metaData.objectUsers {
                    removedMembers.forEach({
                        removedUsersName.append($0.displayName?.capitalized ?? "")
                    })
                }
                let removedMembersString = removedUsersName.joined(separator: ",")
                messageString = String(format: CHLocalized(key: "pmMetaGroupRemoveMembers"), arguments: [subjectString,removedMembersString])
                
            case .makeGroupAdmin:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                messageString = String(format: CHLocalized(key: "pmMetaGroupMakeAdmin"), subjectString)
                
            case .changeGroupTitle:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                let newGroupName = metaData.objectValues as? String ?? ""
                messageString = String(format: CHLocalized(key: "pmMetaGroupChangeTitle"), arguments: [subjectString,newGroupName])
                
            case .changeGroupPhoto:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
                
                messageString = String(format: CHLocalized(key: "pmMetaGroupChangePhoto"), subjectString)
            case .missedVideoCall:
                messageString = "Missed Video Call"
                //return "Missed Video Call"
    //                if lastMessage.ownerId == ChannelizeAPI.getCurrentUserId() {
    //
    //                    return String(format: CHLocalized(key: "pmUserMissedVideoCall"), self.conversation?.conversationPartner?.displayName?.capitalized ?? "")
    //                } else {
    //                    return String(format: CHLocalized(key: "pmUserMissedVideoCall"), CHLocalized(key: "pmYou"))
    //                }
            case .missedVoiceCall:
                messageString = "Missed Voice Call"
                //return "Missed Voice Call"
    //                if lastMessage.ownerId == ChannelizeAPI.getCurrentUserId() {
    //                    return String(format: CHLocalized(key: "pmUserMissedVoiceCall"), self.conversation?.conversationPartner?.displayName?.capitalized ?? "")
    //                } else {
    //                    return String(format: CHLocalized(key: "pmUserMissedVoiceCall"),CHLocalized(key: "pmYou"))
    //                }
                
            default:
                messageString = ""
            }
        }
        let stringAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationMessageColor, NSAttributedString.Key.font: CHCustomStyles.mediumSizeRegularFont!]
        return NSAttributedString(string: messageString, attributes: stringAttributes)
    }
    
    private func createAttachmentAttributedString(lastMessage: CHMessage) -> NSAttributedString? {
        if let firstAttachment = lastMessage.attachments?.first {
            guard let attachmentType = firstAttachment.type else {
                return nil
            }
            var fullAttachmentAttributedString: NSMutableAttributedString?
            var normalAttachmentAttributedString: NSAttributedString?
            switch attachmentType {
            case .gif:
                normalAttachmentAttributedString = "GIF".with(getImage("chGifIcon"))
            case .sticker:
                normalAttachmentAttributedString = "Sticker".with(getImage("chStickerIcon"))
            case .audio:
                normalAttachmentAttributedString = "Audio".with(getImage("chAudioIcon"))
            case .video:
                normalAttachmentAttributedString = "Video".with(getImage("chVideoCallIcon"))
            case .image:
                normalAttachmentAttributedString = "Photo".with(getImage("chPhotoIcon"))
            case .location:
                normalAttachmentAttributedString = "Location".with(getImage("chLocationIcon"))
            case .doc:
                if let fileExtension = lastMessage.attachments?.first?.attachmentExtension {
                    if let icon = mimeTypeIcon[fileExtension.lowercased()] {
                        normalAttachmentAttributedString = "\(lastMessage.attachments?.first?.name ?? "")".with(getImage("\(icon)"))
                    } else {
                        normalAttachmentAttributedString = "\(lastMessage.attachments?.first?.name ?? "")".with(getImage("chFileIcon"))
                    }
                }
                break
            default:
                break
            }
            if self.conversation?.isGroup == true {
                let messageOwnerName = lastMessage.owner?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : self.initialsFromString(string: lastMessage.owner?.displayName?.capitalized ?? "")
                fullAttachmentAttributedString = NSMutableAttributedString(string: "\(messageOwnerName): ", attributes: [NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationLastUpdatedColor, NSAttributedString.Key.font: CHCustomStyles.mediumSizeRegularFont!])
                fullAttachmentAttributedString?.append(normalAttachmentAttributedString ?? NSAttributedString())
                return fullAttachmentAttributedString
            } else {
                return normalAttachmentAttributedString
            }
        }
        return nil
    }
    
    func getMessageStatus(itemMessageDate: Date, completion: @escaping (BaseMessageStatus) ->()) {
        if let oldestRead = self.conversation?.lastMessageOldestRead {
            if itemMessageDate <= oldestRead {
                completion(.seen)
            } else {
                completion(.sent)
            }
        } else {
            completion(.sent)
        }
        
//        if var lastReadDateInfo = self.conversation?.lastReadDateDictionary {
//            lastReadDateInfo.removeValue(forKey: Channelize.getCurrentUserId())
//            let sortedData = lastReadDateInfo.sorted(by: { $0.value < $1.value })
//            if let oldestReader = sortedData.first {
//                let oldestReadDate = oldestReader.value
//                if itemMessageDate <= oldestReadDate {
//                    completion(.seen)
//                } else {
//                    completion(.sent)
//                }
//            }
//        } else {
//            completion(.sent)
//        }
    }
    
    private func createNormalMessageString(lastMessage: CHMessage) -> NSAttributedString? {
        
        var messageBody = lastMessage.body ?? ""
        var mutabelMessage = messageBody
        mutabelMessage = mutabelMessage.replacingOccurrences(of: "&lt;", with: "<")
        mutabelMessage = mutabelMessage.replacingOccurrences(of: "&gt;", with: ">")
        mutabelMessage = mutabelMessage.replacingOccurrences(of: "&amp;", with: "&")
        mutabelMessage = mutabelMessage.replacingOccurrences(of: "&#39;", with: "'")
        mutabelMessage = mutabelMessage.replacingOccurrences(of: "&quot;", with: "\"")
        messageBody = mutabelMessage
        
        
        let formattedMessageBody = messageBody.replacingOccurrences(of: "%s", with: "%@")
        var mentionedNames = [String]()
        var mentionedUserDictionary = [String:String]()
        
        if let mentionedUsers = lastMessage.mentionedUser {
            mentionedUsers.forEach({
                mentionedNames.append($0.user?.displayName?.capitalized ?? "")
            })
        }
        let taggedBodyString = String(format: formattedMessageBody, arguments: mentionedNames)
        if let mentionedUsers = lastMessage.mentionedUser?.sorted(by: { $0.order! < $1.order! }), mentionedUsers.count > 0 {
            
            mentionedUsers.forEach({
                mentionedUserDictionary.updateValue(
                    $0.user?.displayName?.capitalized ?? "", forKey: $0.user?.id ?? "")
            })
        }
        let newBody = taggedBodyString.replacingOccurrences(of: "```", with: "$")
        let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: CHUIConstant.recentConversationMessageColor, withFont: CHCustomStyles.mediumSizeRegularFont!)
        
        
        var fullAttachmentAttributedString: NSMutableAttributedString?
        var attributedString: NSMutableAttributedString!
        attributedString = markDownMessage
        
        for (_,memberName) in mentionedUserDictionary{
            let allRanges = attributedString.string.ranges(of: memberName)
            if allRanges.count > 0 {
                for range in allRanges {
                    let nsRange = NSRange(range, in: attributedString.string)
                    attributedString.addAttribute(.font, value: UIFont(fontStyle: .medium, size: CHCustomStyles.mediumSizeRegularFont!.pointSize)!, range: nsRange)
                    attributedString.addAttribute(
                        .foregroundColor, value: CHUIConstant.recentConversationMessageColor, range: nsRange)
                }
            }
        }
        
        if self.conversation?.isGroup == true {
            let messageOwnerName = lastMessage.owner?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : self.initialsFromString(string: lastMessage.owner?.displayName?.capitalized ?? "")
            fullAttachmentAttributedString = NSMutableAttributedString(string: "\(messageOwnerName): ", attributes: [NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationLastUpdatedColor, NSAttributedString.Key.font: CHCustomStyles.mediumSizeRegularFont!])
            fullAttachmentAttributedString?.append(attributedString ?? NSMutableAttributedString())
            return fullAttachmentAttributedString
        } else {
            return attributedString
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func initialsFromString(string: String) -> String {
        
        let trimmedString = string.trimmingCharacters(in: .whitespaces)
        return trimmedString.components(separatedBy: " ").first ?? ""
    }
}

