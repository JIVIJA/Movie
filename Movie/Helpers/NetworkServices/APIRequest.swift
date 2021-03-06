//
//  APIRequest.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class APIRequest {
    
    private init() {}
    
    private static var apiRequest:APIRequest = {
        let apiRequest = APIRequest()
        return apiRequest
    }()
    
    static var shared:APIRequest {
        return apiRequest
    }
    
    typealias successCompletion = ((_ response:Any? , _ status:Int?) -> ())?
    typealias failureCompletion = ((String) -> ())?
    
}

// MARK: -
// MARK: - APIRequest Basic Configurations.
extension APIRequest {
    
    //... BaseURL
    fileprivate static var baseURL = "https://easy-mock.com/mock/5c19c6ff64b4573fc81a61f3/movieapp/"
    
    fileprivate static var header:[String:String] {
        return ["Accept":"application/json" ]
    }
    
    fileprivate static var arrSuccessStatus = [Int](200 ... 299)
    fileprivate static var arrFailureStatus = [400 , 401 , 403 , 405 , 429 , 503]
}

// MARK: -
// MARK: - loggingRequest && loggingResponse Methods.
extension APIRequest {
    
    fileprivate static func loggingRequest(req:DataRequest) {
        var body = ""
        var length = 0
        
        if let httpBody = req.request?.httpBody {
            body = String(data: httpBody, encoding: String.Encoding.utf8) ?? ""
            length = httpBody.count
        }
        
        let printableString = "\(req.request?.httpMethod ?? "") '\(req.request?.url?.absoluteString ?? "")': \(req.request?.allHTTPHeaderFields ?? [:]) \(body) [\(length) bytes]"
        print("API Request: \(printableString)")
    }
    
    fileprivate static func loggingResponse(response:DataResponse<Any>) {
        if let error = response.result.error {
            print("API Response: (\(response.response?.statusCode ?? 0) [\(response.timeline.totalDuration)s] Response:\(error)")
        } else {
            print("API Response: (\(response.response?.statusCode ?? 0) [\(response.timeline.totalDuration)s] Response:\(response.result.value ?? "")")
        }
    }
}

// MARK: -
// MARK: - Alamofire Various HTTP Methods && Handlation of Status Code && Handlation of Response JSON.
extension APIRequest {
    
    fileprivate static func GET(apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        return alamofireDataRequest(method: .get, apiURL: apiURL, param: param, successCompletion: successCompletion, failureCompletion: failureCompletion)
    }
    
    fileprivate static func HEAD(apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        return alamofireDataRequest(method: .head, apiURL: apiURL, param: param, successCompletion: successCompletion, failureCompletion: failureCompletion)
    }
    
    fileprivate static func POST(apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        return alamofireDataRequest(method: .post, apiURL: apiURL, param: param, successCompletion: successCompletion, failureCompletion: failureCompletion)
    }
    
    fileprivate static func PUT(apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        return alamofireDataRequest(method: .put, apiURL: apiURL, param: param, successCompletion: successCompletion, failureCompletion: failureCompletion)
    }
    
    fileprivate static func PATCH(apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        return alamofireDataRequest(method: .patch, apiURL: apiURL, param: param, successCompletion: successCompletion, failureCompletion: failureCompletion)
    }
    
    fileprivate static func DELETE(apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        return alamofireDataRequest(method: .delete, apiURL: apiURL, param: param, successCompletion: successCompletion, failureCompletion: failureCompletion)
    }
    
    fileprivate static func alamofireDataRequest(method : HTTPMethod , apiURL:URL? , param:[String:Any]? , successCompletion:successCompletion , failureCompletion:failureCompletion) -> URLSessionTask? {
        
        guard let apiURL = apiURL else { return nil }
        guard let reachabilityManager = NetworkReachabilityManager() else { return nil }
        
        if reachabilityManager.isReachable {
            
            let request = Alamofire.request(apiURL, method: method, parameters: param, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: header).responseJSON { (response) in
                handleResponseStatus(response: response, successCompletion: successCompletion, failureCompletion: failureCompletion)
            }
            
            loggingRequest(req: request)
            return request.task
            
        } else {
            //.. No Internet Connection.
            failureCompletion?(ApplicationMessages.noInternetConnection)
            //.. We can handle No Internet connection here at TopMost VC & retry options as well.
            return nil
        }
    }
    
    fileprivate static func handleResponseStatus(response:DataResponse<Any> , successCompletion:successCompletion , failureCompletion:failureCompletion) {
        
        loggingResponse(response: response)
        
        guard let httpResponse = response.response else {
            successCompletion?(nil, nil)
            return
        }
        
        let statusCode = httpResponse.statusCode
        
        if arrSuccessStatus.contains(where: {$0 == statusCode}) {
            handleResponseJSON(response: response, successCompletion: successCompletion)
        } else {
            let message = response.result.error?.localizedDescription ?? "CMessageSomethingWrong"
            failureCompletion?(message)
        }
    }
    
    fileprivate static func handleResponseJSON(response:DataResponse<Any> , successCompletion:successCompletion) {
        guard let responseValue = response.result.value as? [String:Any] else {
            successCompletion?(nil, response.response?.statusCode)
            return
        }
        successCompletion?(responseValue, response.response?.statusCode)
    }
}


// MARK: -
// MARK: - API URLs.
struct APIUrl {
    fileprivate static var movieListURL = URL(string: (APIRequest.baseURL + "home"))
    fileprivate static var movieSearchURL = URL(string: (APIRequest.baseURL + "search"))
    fileprivate static var movieLoadMoreURL = URL(string: (APIRequest.baseURL + "loadmore"))
}

// MARK: -
// MARK: - APIs Methods.
extension APIRequest {
    
    @discardableResult
    func movieList(successCompletion: successCompletion, failureCompletion: failureCompletion) -> URLSessionTask? {
        return APIRequest.GET(apiURL: APIUrl.movieListURL, param: nil, successCompletion: { (response, status) in
            if let responseDict = response as? [String:Any] , responseDict.keys.count > 0 {
                if let result = responseDict["results"] as? [[String:AnyObject]] {
                    for dataDict in result{
                        try? CAppdelegate?.persistentContainer.viewContext.rx.update(MovieModel(JSON: dataDict)!)
                    }
                }
            }
            successCompletion?(nil, status)
        }, failureCompletion: { (message) in
            failureCompletion?(message)
        })
    }
    
    @discardableResult
    func searchMovie(byKeyword keyword: String, offset: Int16, successCompletion: successCompletion, failureCompletion: failureCompletion) -> URLSessionTask? {
        
        let params = ["keyword": keyword, "offset": offset] as [String : Any]
        
        return APIRequest.GET(apiURL: APIUrl.movieSearchURL, param: params, successCompletion: { (response, status) in
            successCompletion?(response, status)
        }, failureCompletion: { (message) in
            failureCompletion?(message)
        })
    }
    
    @discardableResult
    func movieList(byKeyword keyword: String, type: String, offset: Int, successCompletion: successCompletion, failureCompletion: failureCompletion) -> URLSessionTask? {
        
        let params = ["keyword": keyword, "type": type, "offset": offset] as [String : Any]
        
        return APIRequest.GET(apiURL: APIUrl.movieLoadMoreURL, param: params, successCompletion: { (response, status) in
            successCompletion?(response, status)
        }, failureCompletion: { (message) in
            failureCompletion?(message)
        })
    }
    
}
