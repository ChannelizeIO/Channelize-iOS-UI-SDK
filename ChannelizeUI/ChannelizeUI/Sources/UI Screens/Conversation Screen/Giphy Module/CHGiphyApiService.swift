//
//  CHGiphyApiService.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/7/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

enum GiphType: String {
    case gif = "gif"
    case sticker = "sticker"
}

class CHGiphyApiService {
    
    static var instance: CHGiphyApiService = {
        let instance = CHGiphyApiService()
        return instance
    }()
    
    func createGiphyStickerGetTrendingRequest(offset: Int, type: GiphType = .gif, completion: @escaping ([CHGiphImageModel]?,String?) -> ()) {
        var params = [String:Any]()
        params.updateValue(offset, forKey: "offset")
        params.updateValue(24, forKey: "limit")
        params.updateValue("en", forKey: "lang")
        params.updateValue(CHGifyService.getGiphyKey(), forKey: "api_key")
        
        let url = type == .gif ? "https://api.giphy.com/v1/gifs/trending" : "https://api.giphy.com/v1/stickers/trending"
        
        let dataRequest = Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.init(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal), headers: nil).validate()
        dataRequest.responseJSON(completionHandler: {(res: DataResponse<Any>) in
            switch res.result {
            case .success(let responseData):
                if let response = responseData as? NSDictionary {
                    if let giphResultArray = response.value(forKey: "data") as? NSArray {
                        self.processGiphImages(with: giphResultArray, completion: {(models) in
                            completion(models,nil)
                        })
                    } else {
                        completion(nil,"Error in Getting Giphs")
                    }
                } else {
                    completion(nil,"Error in Getting Giphs")
                }
                break
            case .failure(_):
                completion(nil,"Error in Getting Giphs")
                break
            }
        })
    }
    
    func createGiphyStickerSearchRequest(with query: String, offset: Int, type: GiphType = .gif, completion: @escaping ([CHGiphImageModel]?,String?) -> ()) {
        var params = [String:Any]()
        params.updateValue(query, forKey: "q")
        params.updateValue(offset, forKey: "offset")
        params.updateValue(24, forKey: "limit")
        params.updateValue("en", forKey: "lang")
        params.updateValue(CHGifyService.getGiphyKey(), forKey: "api_key")
        
        let url = type == .gif ? "https://api.giphy.com/v1/gifs/search" : "https://api.giphy.com/v1/stickers/search"
        
        let dataRequest = Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.init(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal), headers: nil).validate()
        dataRequest.responseJSON(completionHandler: {(res: DataResponse<Any>) in
            switch res.result {
            case .success(let responseData):
                if let response = responseData as? NSDictionary {
                    if let giphResultArray = response.value(forKey: "data") as? NSArray {
                        self.processGiphImages(with: giphResultArray, completion: {(models) in
                            completion(models,nil)
                        })
                    } else {
                        completion(nil,"Error in Getting Giphs")
                    }
                } else {
                    completion(nil,"Error in Getting Giphs")
                }
                break
            case .failure(_):
                completion(nil,"Error in Getting Giphs")
                break
            }
        })
    }
    
    private func processGiphImages(with data: NSArray,completion: @escaping ([CHGiphImageModel]) -> () ) {
        var giphModels = [CHGiphImageModel]()
        data.forEach({
            if let giphImageDictionary = $0 as? NSDictionary {
                if let giphImages = giphImageDictionary.value(forKey: "images") as? NSDictionary {
                    // Original Image
                    let originalImageInfo = giphImages.value(forKey: "fixed_width") as? NSDictionary
                    let originalGiphUrl = originalImageInfo?.value(forKey: "url") as? String
                    
                    // DownSampled Image
                    let downloadSampled = giphImages.value(forKey: "fixed_width_downsampled") as? NSDictionary
                    let downSampledUrl = downloadSampled?.value(forKey: "url") as? String
                    
                    // Still Image
                    let stillImage = giphImages.value(forKey: "fixed_width_still") as? NSDictionary
                    let stillImageUrl = stillImage?.value(forKey: "url") as? String
                    
                    var params = [String:Any]()
                    if originalGiphUrl != nil {
                        params.updateValue(originalGiphUrl!, forKey: "originalUrl")
                    }
                    if downSampledUrl != nil {
                        params.updateValue(downSampledUrl!, forKey: "downSampledUrl")
                    }
                    if stillImageUrl != nil {
                        params.updateValue(stillImageUrl!, forKey: "stillUrl")
                    }
                    if let model = Mapper<CHGiphImageModel>().map(JSON: params) {
                        giphModels.append(model)
                    }
                }
            }
        })
        completion(giphModels)
    }
    
    
    
}

