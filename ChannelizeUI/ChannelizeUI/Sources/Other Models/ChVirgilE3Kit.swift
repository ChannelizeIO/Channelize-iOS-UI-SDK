//
//  ChVirgilE3Kit.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 6/25/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import VirgilE3Kit

class ChVirgilE3Kit {

    static var isEndToEndEncryptionEnabled: Bool = false
    static var currentEthreeObject: EThree?
    static var isSuccessfullyInitialized: Bool = false
    
    static var instance: ChVirgilE3Kit = {
        let instance = ChVirgilE3Kit()
        return instance
    }()
    
    static func initializeEthree(completion: @escaping (Bool,String?) -> Void) {
        let tokenCallBack: EThree.RenewJwtCallback = { completion in
            ChannelizeAPIService.getVirgilAuthenticationToken(completion: completion)
        }
        do {
            currentEthreeObject = try EThree(identity: Channelize.getCurrentUserId(), tokenCallback: tokenCallBack)
            completion(true,nil)
        } catch {
            print(error.localizedDescription)
            completion(false,error.localizedDescription)
        }
    }
    
    static func checkAndRegisterUser(completion: @escaping (Bool,String?) -> Void) {
        guard let myEthree = currentEthreeObject else {
            completion(false,"Ethree Is Not initialized")
            return
        }
        var hasPrivateKey: Bool = false
        do {
            hasPrivateKey = try myEthree.hasLocalPrivateKey()
        } catch {
            print(error.localizedDescription)
            completion(false,error.localizedDescription)
        }
        
        if hasPrivateKey {
            completion(true,nil)
            isSuccessfullyInitialized = true
        } else {
            myEthree.register(completion: { error in
                if error as? EThreeError == EThreeError.userIsAlreadyRegistered {
                    myEthree.restorePrivateKey(password: getPassword(), completion: { error in
                        if error == nil {
                            isSuccessfullyInitialized = true
                            completion(true,nil)
                        } else {
                            completion(false,error?.localizedDescription ?? "")
                        }
                    })
                } else if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion(false,error?.localizedDescription ?? "")
                } else {
                    myEthree.backupPrivateKey(password: getPassword(), completion: { error in
                        if error == nil {
                            isSuccessfullyInitialized = true
                            completion(true,nil)
                        } else {
                            completion(false,error?.localizedDescription ?? "")
                        }
                    })
                }
            })
        }
    }
    
    static func getPassword() -> String {
        let userId = Channelize.getCurrentUserId()
        let password = userId.sha256
        return password
    }
}


