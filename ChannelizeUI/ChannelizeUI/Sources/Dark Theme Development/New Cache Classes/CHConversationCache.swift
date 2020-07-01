import Foundation
import ChannelizeAPI

class CHConversationCache {
    
    var conversations = [CHConversation]()
    
    static var instance: CHConversationCache = {
        let instance = CHConversationCache()
        return instance
    }()
    
    func appendConversation(newConversations: [CHConversation]) {
        newConversations.forEach({
            let newConversation = $0
            if conversations.filter({
                $0.id == newConversation.id
            }).count == 0 {
                conversations.append(newConversation)
            }
        })
    }
    
    func removeConversation(conversation: CHConversation?) {
        self.conversations.removeAll(where: {
            $0.id == conversation?.id
        })
    }
}


