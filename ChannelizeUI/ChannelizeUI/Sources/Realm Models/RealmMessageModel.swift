//
//  RealmMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//
/*
import Foundation
import ObjectMapper
import RealmSwift
import ChannelizeAPI


extension Object {
func toDictionary() -> NSDictionary {
    let properties = self.objectSchema.properties.map { $0.name }
    let dictionary = self.dictionaryWithValues(forKeys: properties)

    let mutabledic = NSMutableDictionary()
    mutabledic.setValuesForKeys(dictionary)

    for prop in self.objectSchema.properties as [Property] {
        // find lists
        if prop.objectClassName != nil  {
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    if let object = nestedListObject._rlmArray[index] as? Object {
                        objects.append(object.toDictionary())
                    }
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
    }
    return mutabledic
}
}

class RealmService {
    
    private init() {}
    static let shared = RealmService()
    
    var realm = try! Realm()
    
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            post(error)
        }
    }
    
    func updateObject<T: Object>(_ object: T){
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch{
            post(error)
        }
    }
    
    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            post(error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            post(error)
        }
    }
    
    func post(_ error: Error) {
        NotificationCenter.default.post(name: NSNotification.Name("RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController, completion: @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"),
                                               object: nil,
                                               queue: nil) { (notification) in
                                                completion(notification.object as? Error)
        }
    }
    
    func stopObservingErrors(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }
    
}

class ListTransform<T:Object> : TransformType where T:Mappable {

    typealias Object = List<T>
    typealias JSON = [[String:Any]]

    let mapper = Mapper<T>()

    func transformFromJSON(_ value: Any?) -> List<T>? {
        let result = List<T>()
        if let tempArr = value as? [Any] {
            for entry in tempArr {
                let mapper = Mapper<T>()
                let model : T = mapper.map(JSONObject: entry)!
                result.append(model)
            }
        }
        return result
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        var results = [[String:Any]]()
        if let value = value {
            for obj in value {
                let json = mapper.toJSON(obj)
                results.append(json)
            }
        }
        return results
    }
}


//public struct ListTransform<T: RealmSwift.Object>: TransformType where T: BaseMappable {
//
//    public typealias Serialize = (List<T>) -> ()
//    private let onSerialize: Serialize
//
//    public init(onSerialize: @escaping Serialize = { _ in }) {
//        self.onSerialize = onSerialize
//    }
//
//    public typealias Object = List<T>
//    public typealias JSON = Array<Any>
//    let mapper = Mapper<T>()
//    public func transformFromJSON(_ value: Any?) -> List<T>? {
//        let list = List<T>()
//        if let objects = Mapper<T>().mapArray(JSONObject: value) {
//            list.append(objectsIn: objects)
//        }
//        self.onSerialize(list)
//        return list
//    }
//
//    public func transformToJSON(_ value: Object?) -> JSON? {
//        var results = [[String:Any]]()
//        if let _value = value {
//           for obj in _value {
//               let json = mapper.toJSON(obj)
//               results.append(json)
//           }
//        }
//        return results
//    }
//
//}

class CHRealmUserModel: Object, Mappable {
    @objc dynamic var id: String?
    @objc dynamic var displayName: String?
    @objc dynamic var profileImageUrl: String?
    //@objc dynamic var metaData: [String : Any]?
    @objc dynamic var profileUrl: String?
    var isOnline = RealmOptional<Bool>()
    @objc dynamic var lastSeen: Date?
    var hasBlocked = RealmOptional<Bool>()
    var isBlocked = RealmOptional<Bool>()
    var isAdmin = RealmOptional<Bool>()
    var isNotificationOn = RealmOptional<Bool>()
    @objc dynamic var language: String?
    var isDeleted = RealmOptional<Bool>()
    var isActive = RealmOptional<Bool>()
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
      return "id"
    }
    
    func mapping(map: Map) {
        
        if map.mappingType == .fromJSON {
            self.id <- map["id"]
            self.displayName <- map["displayName"]
            self.profileImageUrl <- map["profileImageUrl"]
            //self.metaData <- map["metaData"]
            self.profileUrl <- map["profileUrl"]
            self.isOnline <- map["isOnline"]
            self.lastSeen <- (map["lastSeen"], ISODateTransform())
            self.hasBlocked <- map["hasBlocked"]
            self.isBlocked <- map["isBlocked"]
            self.isAdmin <- map["isAdmin"]
            self.isNotificationOn <- map["notification"]
            self.language <- map["language"]
            self.isDeleted <- map["isDeleted"]
            self.isActive <- map["isActive"]
        } else {
            self.id >>> map["id"]
            self.displayName >>> map["displayName"]
            self.profileImageUrl >>> map["profileImageUrl"]
            //self.metaData <- map["metaData"]
            self.profileUrl >>> map["profileUrl"]
            self.isOnline >>> map["isOnline"]
            self.lastSeen >>> (map["lastSeen"], ISODateTransform())
            self.hasBlocked >>> map["hasBlocked"]
            self.isBlocked >>> map["isBlocked"]
            self.isAdmin >>> map["isAdmin"]
            self.isNotificationOn >>> map["notification"]
            self.language >>> map["language"]
            self.isDeleted >>> map["isDeleted"]
            self.isActive >>> map["isActive"]
        }
    }
}


class CHRealmMentionedUser: Object, Mappable {
    
    @objc dynamic var id: String?
    @objc dynamic var userId: String?
    var order = RealmOptional<Int>()
    var wordCount = RealmOptional<Int>()
    @objc dynamic var user: CHRealmUserModel?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
      return "id"
    }
    
    func mapping(map: Map) {
        if map.mappingType == .fromJSON {
            self.id <- map["id"]
            self.userId <- map["userId"]
            self.order <- map["order"]
            self.wordCount <- map["wordCount"]
            self.user <- map["user"]
        } else {
            self.id >>> map["id"]
            self.userId >>> map["userId"]
            self.order >>> map["order"]
            self.wordCount >>> map["wordCount"]
            self.user >>> map["user"]
        }
    }
}


class CHRealmAttachmentModel: Object, Mappable {
    
    @objc dynamic var type: String?
    @objc dynamic var adminMessageType: String?
    @objc dynamic var name: String?
    @objc dynamic var mimeType: String?
    @objc dynamic var attachmentExtension: String?
    var attachMentSize = RealmOptional<Double>()
    @objc dynamic var fileUrl: String?
    @objc dynamic var thumbnailUrl: String?
    var locationLatitude = RealmOptional<Double>()
    var locationLongitude = RealmOptional<Double>()
    @objc dynamic var locationAddress: String?
    @objc dynamic var locationTitle: String?
    var audioDuration = RealmOptional<Double>()
    @objc dynamic var gifStickerDownloadUrl: String?
    @objc dynamic var gifStickerStillUrl: String?
    @objc dynamic var gifStickerOriginalUrl: String?
    @objc dynamic var metaData: CHRealmAttachmentMetaData?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        if map.mappingType == .fromJSON {
            self.type <- map["type"]
            self.adminMessageType <- map["adminMessageType"]
            self.name <- map["name"]
            self.mimeType <- map["mimeType"]
            self.attachmentExtension <- map["extension"]
            self.attachMentSize <- map["size"]
            self.fileUrl <- map["fileUrl"]
            self.thumbnailUrl <- map["thumbnailUrl"]
            self.locationLatitude <- map["latitude"]
            self.locationLongitude <- map["longitude"]
            self.locationAddress <- map["address"]
            self.locationTitle <- map["title"]
            self.audioDuration <- map["duration"]
            self.gifStickerDownloadUrl <- map["downsampledUrl"]
            self.gifStickerStillUrl <- map["stillUrl"]
            self.gifStickerOriginalUrl <- map["originalUrl"]
            self.metaData <- map["metaData"]
        } else {
            self.type >>> map["type"]
            self.adminMessageType >>> map["adminMessageType"]
            self.name >>> map["name"]
            self.mimeType >>> map["mimeType"]
            self.attachmentExtension >>> map["extension"]
            self.attachMentSize >>> map["size"]
            self.fileUrl >>> map["fileUrl"]
            self.thumbnailUrl >>> map["thumbnailUrl"]
            self.locationLatitude >>> map["latitude"]
            self.locationLongitude >>> map["longitude"]
            self.locationAddress >>> map["address"]
            self.locationTitle >>> map["title"]
            self.audioDuration >>> map["duration"]
            self.gifStickerDownloadUrl >>> map["downsampledUrl"]
            self.gifStickerStillUrl >>> map["stillUrl"]
            self.gifStickerOriginalUrl >>> map["originalUrl"]
            self.metaData >>> map["metaData"]
        }
    }
}

class CHRealmMessageModel: Object, Mappable {
    
    @objc dynamic var id: String?
    @objc dynamic var conversationId: String?
    @objc dynamic var messageTypeString: String?
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var body: String?
    @objc dynamic var ownerId: String?
    @objc dynamic var owner: CHRealmUserModel?
    @objc dynamic var parentMessage: CHRealmMessageModel?
    var attachments = List<CHRealmAttachmentModel>()
    var isDeleted = RealmOptional<Bool>()
    var mentionedUser = List<CHRealmMentionedUser>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
      return "id"
    }
    
    func mapping(map: Map) {
        
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()
        
        if map.mappingType == .fromJSON {
            self.id <- map["id"]
            self.conversationId <- map["conversationId"]
            self.messageTypeString <- map["type"]
            self.createdAt <- (map["createdAt"],ISODateTransform())
            self.updatedAt <- (map["updatedAt"],ISODateTransform())
            self.body <- map["body"]
            self.ownerId <- map["ownerId"]
            self.owner <- map["owner"]
            self.parentMessage <- map["parentMessage"]
            self.isDeleted <- map["isDeleted"]
            self.mentionedUser <- (map["mentionedUsers"], ListTransform<CHRealmMentionedUser>())
            self.attachments <- (map["attachments"], ListTransform<CHRealmAttachmentModel>())
        } else {
            self.id >>> map["id"]
            self.conversationId >>> map["conversationId"]
            self.messageTypeString >>> map["type"]
            self.createdAt >>> (map["createdAt"],ISODateTransform())
            self.updatedAt >>> (map["updatedAt"],ISODateTransform())
            self.body >>> map["body"]
            self.ownerId >>> map["ownerId"]
            self.owner >>> map["owner"]
            self.parentMessage >>> map["parentMessage"]
            self.isDeleted >>> map["isDeleted"]
            self.mentionedUser >>> (map["mentionedUsers"], ListTransform<CHRealmMentionedUser>())
            self.attachments >>> (map["attachments"], ListTransform<CHRealmAttachmentModel>())
        }
    }
}

class CHRealmAttachmentMetaData: Object, Mappable {
    
    @objc dynamic var subjectId: String?
    @objc dynamic var subjectType: String?
    @objc dynamic var objectType: String?
    @objc dynamic var objectValues: String?
    @objc dynamic var subjectUser: CHRealmUserModel?
    var objectUsers = List<CHRealmUserModel>()
    @objc dynamic var objectUser: CHRealmUserModel?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        if map.mappingType == .fromJSON {
            self.subjectId <- map["subId"]
            self.subjectType <- map["subType"]
            self.objectType <- map["objType"]
            self.objectValues <- map["objValues"]
            self.subjectUser <- map["subUser"]
            if map.JSON["objUsers"] is NSArray {
                self.objectUsers <- (map["objUsers"], ListTransform<CHRealmUserModel>())
            } else {
                self.objectUser <- map["objUsers"]
            }
        } else {
            self.subjectId >>> map["subId"]
            self.subjectType >>> map["subType"]
            self.objectType >>> map["objType"]
            self.objectValues >>> map["objValues"]
            self.subjectUser >>> map["subUser"]
            if map.JSON["objUsers"] is NSArray {
                self.objectUsers >>> (map["objUsers"], ListTransform<CHRealmUserModel>())
            } else {
                self.objectUser >>> map["objUsers"]
            }
        }
    }
}

*/

