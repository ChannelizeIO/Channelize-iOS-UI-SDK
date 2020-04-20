//
//  UIRecentConversationCell2.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/23/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import Alamofire

class UIRecentConversationCell: UITableViewCell {
    
    private var conversationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = CHUIConstants.conversationTitleFont
        label.textColor = CHUIConstants.conversationTitleColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        return label
    }()
    
    private var conversationMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.conversationMessageColor
        label.textAlignment = .left
        label.font = CHUIConstants.conversationMessageFont
        return label
    }()
    
    private var conversationTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.conversationUpdatedTimeColor
        label.textAlignment = .right
        label.font = CHUIConstants.conversationUpdatedTimeFont
        return label
    }()
    
    private var messageStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var messageCountLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = CHUIConstants.appDefaultColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.textColor = UIColor.white
        label.font = UIFont(fontStyle: .robotoRegular, size: 12.0)
        label.textAlignment = .center
        return label
    }()
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(hex: "#f8f8f8")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var onlineStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = CHUIConstants.onlineStatusColor
        view.layer.borderWidth = 2.0
        return view
    }()
    
    private var messageCountLabelWidthConstraint: NSLayoutConstraint!
    
    var conversation: CHConversation? {
        didSet {
            self.assignData()
        }
    }
    
    var onLongPressedBubble: ((_ cell: UIRecentConversationCell) -> Void)?
    var longPressTapGesture: UILongPressGestureRecognizer!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(conversationTitleLabel)
        self.contentView.addSubview(conversationMessageLabel)
        self.contentView.addSubview(conversationTimeLabel)
        self.contentView.addSubview(messageStatusImageView)
        self.contentView.addSubview(messageCountLabel)
        self.contentView.addSubview(onlineStatusView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBubble(longPressGesture:)))
        self.contentView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    private func setUpViewsFrames() {
        
        self.profileImageView.setViewAsCircle(circleWidth: 50)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 12.5)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        
        self.conversationTitleLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 12.5)
        self.conversationTitleLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -105)
        self.conversationTitleLabel.setBottomAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.conversationTitleLabel.setHeightAnchor(constant: 25)
        
        self.conversationMessageLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 12.5)
        self.conversationMessageLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -50)
        self.conversationMessageLabel.setTopAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.conversationMessageLabel.setHeightAnchor(constant: 25)
        
        self.conversationTimeLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -10)
        self.conversationTimeLabel.setHeightAnchor(constant: 20)
        self.conversationTimeLabel.setCenterYAnchor(relatedConstraint: self.conversationTitleLabel.centerYAnchor, constant: 0)
        self.conversationTimeLabel.setWidthAnchor(constant: 90)
        
        self.messageStatusImageView.setViewsAsSquare(squareWidth: 15)
        self.messageStatusImageView.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -10)
        self.messageStatusImageView.setCenterYAnchor(relatedConstraint: self.conversationMessageLabel.centerYAnchor, constant: 0)
        
        self.messageCountLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -10)
        self.messageCountLabel.setCenterYAnchor(relatedConstraint: self.conversationMessageLabel.centerYAnchor, constant: 0)
        self.messageCountLabel.setHeightAnchor(constant: 25)
        self.messageCountLabel.layer.cornerRadius = getDeviceWiseAspectedHeight(constant: 25)/2
        self.messageCountLabelWidthConstraint = NSLayoutConstraint(item: self.messageCountLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: getDeviceWiseAspectedHeight(constant: 25))
        self.messageCountLabelWidthConstraint.isActive = true
        self.addConstraint(self.messageCountLabelWidthConstraint)
        
        self.onlineStatusView.setViewAsCircle(circleWidth: 15)
        self.onlineStatusView.setRightAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 0)
        self.onlineStatusView.setBottomAnchor(relatedConstraint: self.profileImageView.bottomAnchor, constant: -2.5)
        
        
        self.separatorInset.left = 75
    }
    
    private func assignData() {
        guard let conversationData = self.conversation else {
            return
        }
        
        if conversationData.isGroup == true {
            self.onlineStatusView.isHidden = true
        } else {
            if conversationData.conversationPartner?.isOnline == true {
                self.onlineStatusView.isHidden = false
            } else {
                self.onlineStatusView.isHidden = true
            }
        }
        
        let profileImageUrl = conversationData.isGroup == true ? conversationData.profileImageUrl : conversationData.conversationPartner?.profileImageUrl
        let conversationTitle = conversationData.isGroup == true ? conversationData.title : conversationData.conversationPartner?.displayName?.capitalized
        
        self.conversationTitleLabel.text = conversationTitle
        
        if let lastUpdatedDate = self.conversation?.lastMessage?.createdAt {
            let lastUpdatedTimeString = getTimeStamp(lastUpdatedDate)
            self.conversationTimeLabel.text = lastUpdatedTimeString
        } else {
            self.conversationTimeLabel.text = nil
        }
        
        if conversationData.lastMessage?.ownerId == ChannelizeAPI.getCurrentUserId() {
            if conversationData.lastMessage?.messageType == .admin {
                self.messageStatusImageView.isHidden = true
                self.messageCountLabel.isHidden = true
            } else {
                self.messageStatusImageView.isHidden = false
                self.messageCountLabel.isHidden = true
            }
            
            let lastMessageDate = conversationData.lastMessage?.createdAt ?? Date()
            let messageStatus = self.getMessageStatus(itemMessageDate: lastMessageDate)
            if messageStatus == .sent {
                self.messageStatusImageView.image = getImage("chSingleTickIcon")
                self.messageStatusImageView.tintColor = CHUIConstants.conversationUpdatedTimeColor
            } else {
                self.messageStatusImageView.image = getImage("chDoubleTickIcon")
                self.messageStatusImageView.tintColor = CHUIConstants.appDefaultColor
            }
        } else {
            self.messageStatusImageView.isHidden = true
            if conversationData.unreadMessageCount != 0 {
                let countWidth = "\(conversationData.unreadMessageCount ?? 0)".widthOfString(usingFont: UIFont(fontStyle: .robotoRegular, size: 12.0)!)
                if countWidth + 10 > getDeviceWiseAspectedHeight(constant: 25) {
                    self.messageCountLabelWidthConstraint.constant = countWidth + 10
                    self.layoutIfNeeded()
                }
                self.messageCountLabel.isHidden = false
                self.messageCountLabel.text = "\(conversationData.unreadMessageCount ?? 0)"
            } else {
                self.messageCountLabel.isHidden = true
            }
        }
        
        if conversationData.isTyping == true {
            let typingUserName = conversationData.typingUserName?.capitalized ?? ""
            var typingText = ""
            if conversationData.isGroup == true {
                typingText = String(format: "%@ is Typing...", typingUserName)
            } else {
                typingText = "Typing..."
            }
            self.conversationMessageLabel.text = typingText
            self.conversationMessageLabel.font = CHUIConstants.conversationMessageFont
            self.conversationMessageLabel.textColor = CHUIConstants.appDefaultColor
        } else {
            self.conversationMessageLabel.textColor = CHUIConstants.conversationMessageColor
            if let lastMessage = conversationData.lastMessage {
                if lastMessage.isDeleted == true {
                    let deletedMessageAttributes: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font: UIFont(fontStyle: .robotoItalic, size: CHUIConstants.mediumFontSize)!, NSAttributedString.Key.foregroundColor: CHUIConstants.conversationMessageColor]
                    self.conversationMessageLabel.attributedText = NSAttributedString(string: "This message was deleted.", attributes: deletedMessageAttributes)
                } else {
                    if lastMessage.messageType == .admin {
                        if let metaMessageString = self.createMetaDataString(lastMessage: lastMessage) {
                            self.conversationMessageLabel.text = metaMessageString
                        } else {
                            self.conversationMessageLabel.text = nil
                        }
                    } else if lastMessage.messageType == .normal || lastMessage.messageType == .forward || lastMessage.messageType == .quotedMessage {
                        if lastMessage.body != nil {
                            if let attributedBody = self.createNormalMessageString(lastMessage: lastMessage) {
                                self.conversationMessageLabel.attributedText = attributedBody
                            } else {
                                self.conversationMessageLabel.attributedText = NSAttributedString()
                            }
                        } else {
                            if let attributedString = createAttachmentAttributedString(lastMessage: lastMessage) {
                                self.conversationMessageLabel.attributedText = attributedString
                            } else {
                                self.conversationMessageLabel.attributedText = nil
                                self.conversationMessageLabel.text = nil
                            }
                        }
                    } else {
                        self.conversationMessageLabel.text = nil
                    }
                }
            } else {
                self.conversationMessageLabel.text = nil
            }
        }
        self.profileImageView.image = nil
        if let imageUrl = URL(string: profileImageUrl ?? "") {
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: conversationTitle ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 60), height: getDeviceWiseAspectedWidth(constant: 60)))
            let image = imageGenerator.generateImage()
            self.profileImageView.image = image
        }
    }
    
    private func createMetaDataString(lastMessage: CHMessage) -> String? {
        if let firstAttachment = lastMessage.attachments?.first {
            guard firstAttachment.type == .metaMessage else  {
                return nil
            }
            guard let messageType = firstAttachment.adminMessageType else {
                return nil
            }
            guard let metaData = firstAttachment.metaData else {
                return nil
            }
            switch messageType {
            case .groupCreate:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                let groupName = metaData.objectValues as? String ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                let messageLabel = String(format: "%@ created group %@", arguments: [subjectString,groupName])
                return messageLabel
                
            case .addMembers:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                var addedUsersName = [String]()
                if let objectUsers = metaData.objectUsers {
                    objectUsers.forEach({
                        addedUsersName.append($0.displayName?.capitalized ?? "")
                    })
                }
                let addedUserString = addedUsersName.joined(separator: ",")
                let messageLabel = String(format: "%@ added %@", arguments: [subjectString,addedUserString])
                return messageLabel
                
            case .groupLeave:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                let messageLabel = String(format: "%@ left", subjectString)
                return messageLabel
                
            case .removeMember:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                var removedUsersName = [String]()
                if let removedMembers = metaData.objectUsers {
                    removedMembers.forEach({
                        removedUsersName.append($0.displayName?.capitalized ?? "")
                    })
                }
                let removedMembersString = removedUsersName.joined(separator: ",")
                let messageLabel = String(format: "%@ removed %@", arguments: [subjectString,removedMembersString])
                return messageLabel
                
            case .makeGroupAdmin:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                let messageLabel = String(format: "%@ are now an admin", subjectString)
                return messageLabel
                
            case .changeGroupTitle:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                let newGroupName = metaData.objectValues as? String ?? ""
                let messageLabel = String(format: "%@ changed the title to %@", arguments: [subjectString,newGroupName])
                return messageLabel
                
            case .changeGroupPhoto:
                let subjectName = metaData.subjectUser?.displayName?.capitalized ?? ""
                
                let subjectString = metaData.subjectUser?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
                
                let messageLabel = String(format: "%@ changed group photo", subjectString)
                return messageLabel
            case .missedVideoCall:
                if lastMessage.ownerId == ChannelizeAPI.getCurrentUserId() {
                    return String(format: CHLocalized(key: "pmUserMissedVideoCall"), self.conversation?.conversationPartner?.displayName?.capitalized ?? "")
                } else {
                    return String(format: CHLocalized(key: "pmUserMissedVideoCall"), CHLocalized(key: "pmYou"))
                }
            case .missedVoiceCall:
                if lastMessage.ownerId == ChannelizeAPI.getCurrentUserId() {
                    return String(format: CHLocalized(key: "pmUserMissedVoiceCall"), self.conversation?.conversationPartner?.displayName?.capitalized ?? "")
                } else {
                    return String(format: CHLocalized(key: "pmUserMissedVoiceCall"),CHLocalized(key: "pmYou"))
                }
                
            default:
                return nil
            }
        }
        return nil
    }
    
    private func createAttachmentAttributedString(lastMessage: CHMessage) -> NSAttributedString? {
        
        if let firstAttachment = lastMessage.attachments?.first {
            guard let attachmentType = firstAttachment.type else {
                return nil
            }
            switch attachmentType {
            case .gif:
                return "GIF".with(getImage("gifIcon"))
            case .sticker:
                return "Sticker".with(getImage("chStickerIcon"))
            case .audio:
                return "Audio".with(getImage("chAudioIcon"))
            case .video:
                return "Video".with(getImage("chVideoCallIcon"))
            case .image:
                return "Photo".with(getImage("chPhotoIcon"))
            case .location:
                return "Location".with(getImage("chLocationIcon"))
            default:
                break
            }
        }
        return nil
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
        let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: CHUIConstants.conversationMessageColor, withFont: CHUIConstants.conversationMessageFont!)
        
        var attributedString: NSMutableAttributedString!
        attributedString = markDownMessage
        
        for (_,memberName) in mentionedUserDictionary{
            let allRanges = attributedString.string.ranges(of: memberName)
            if allRanges.count > 0 {
                for range in allRanges {
                    let nsRange = NSRange(range, in: attributedString.string)
                    attributedString.addAttribute(.font, value: UIFont(fontStyle: .robotoMedium, size: CHUIConstants.mediumFontSize)!, range: nsRange)
                    attributedString.addAttribute(
                        .foregroundColor, value: CHUIConstants.conversationMessageColor, range: nsRange)
                }
            }
        }
        return attributedString
    }
    
    func getMessageStatus(itemMessageDate: Date) -> BaseMessageStatus {
        let dateTransformer = ISODateTransform()
        if let lastReadInfoDic = self.conversation?.lastReadDictionary {
            var lastReadData = [String:Date]()
            lastReadInfoDic.forEach({(id,date) in
                if let memberReadDate = dateTransformer.transformFromJSON(date) {
                    lastReadData.updateValue(memberReadDate, forKey: id)
                }
            })
            let sortedData = lastReadData.sorted(by: {$0.value < $1.value})
            if let oldestReader = sortedData.first {
                let oldestReadDate = oldestReader.value
                if itemMessageDate <= oldestReadDate {
                    return .seen
                } else {
                    return .sent
                }
            }
        }
        return .sent
    }
    
}

