//
//  APIRequest.swift
//  DemoSwift
//
//  Created by mac-0016 on 17/09/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PKHUD


//MARK:-
//MARK:- Networking Class


/// API Tags

class Networking: NSObject
{
    typealias ClosureSuccess = (_ task:URLSessionTask, _ response:AnyObject?) -> Void
    typealias ClosureError   = (_ task:URLSessionTask, _ error:NSError?) -> Void
    
    var BASEURL:String?
    var headers:[String: String]?
    
    var loggingEnabled = true
    var activityCount = 0
    
    
    
    /// Networking Singleton
    static let sharedInstance = Networking.init()
    
    override init() {
        super.init()
    }
    
    fileprivate func logging(request req:Request?) -> Void
    {
        if (loggingEnabled && req != nil)
        {
            var body:String = ""
            var length = 0
            
            if (req?.request?.httpBody != nil) {
                body = String.init(data: (req!.request!.httpBody)!, encoding: String.Encoding.utf8)!
                length = req!.request!.httpBody!.count
                
                let printableString = "\(req!.request!.httpMethod!) '\(req!.request!.url!.absoluteString)': \(String(describing: req!.request!.allHTTPHeaderFields)) \(body) [\(length) bytes]"
                
                print("API Request: \(printableString)")
                
            }
            
            
        }
    }
    
    fileprivate func logging(response res:DataResponse<Any>) -> Void
    {
        if (loggingEnabled && res != nil)
        {
            
            if (res.result.error != nil) {
                print("API Response: (\(String(describing: res.response?.statusCode))) [\(res.timeline.totalDuration)s] Error:\(String(describing: res.result.error))")
            } else {
                print("API Response: (\(res.response!.statusCode)) [\(res.timeline.totalDuration)s] Response:\(String(describing: res.result.value))")
            }
        }
    }
    
    
    
    /// Uploading
    
    func upload(
        _ URLRequest: URLRequestConvertible,
        multipartFormData: (MultipartFormData) -> Void,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) -> Void
    {
        
        let formData = MultipartFormData()
        multipartFormData(formData)
        
        
        var URLRequestWithContentType = try? URLRequest.asURLRequest()
        
        URLRequestWithContentType?.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileName = UUID().uuidString
        
        #if swift(>=2.3)
            let directoryURL = tempDirectoryURL.appendingPathComponent("com.alamofire.manager/multipart.form.data")
            let fileURL = directoryURL.appendingPathComponent(fileName)
        #else
            
            let directoryURL = tempDirectoryURL.appendingPathComponent("com.alamofire.manager/multipart.form.data")
            let fileURL = directoryURL.appendingPathComponent(fileName)
        #endif
        
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            try formData.writeEncodedData(to: fileURL)
            
            DispatchQueue.main.async {
                
                let encodingResult = SessionManager.MultipartFormDataEncodingResult.success(request: SessionSharedManager.shared().upload(fileURL, with: URLRequestWithContentType!), streamingFromDisk: true, streamFileURL: fileURL)
                encodingCompletion?(encodingResult)
            }
        } catch {
            DispatchQueue.main.async {
                encodingCompletion?(.failure(error as NSError))
            }
        }
    }
    
    
    
    
    /// HTTPs Methods
    func GET(param parameters:[String: AnyObject]?, success:ClosureSuccess?,  failure:ClosureError?) -> URLSessionTask?
    {
        
        let uRequest = SessionSharedManager.shared().request(BASEURL!, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
        self.logging(request: uRequest)
        print("Request = \(uRequest)")
        
        uRequest.responseJSON { (response) in
            
            self.logging(response: response)
            if(response.result.error == nil)
            {
                if(success != nil) {
                    success!(uRequest.task!, response.result.value as AnyObject)
                }
            }
            else
            {
                if(failure != nil) {
                    failure!(uRequest.task!, response.result.error as NSError?)
                }
            }
        }
        
        return uRequest.task
    }
    
    func POST(param parameters:[String: AnyObject]?, success:ClosureSuccess?,  failure:ClosureError?) -> URLSessionTask?
    {
        
        let uRequest = SessionSharedManager.shared().request((BASEURL! + (parameters?["tag"] as? String ?? "")), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        self.logging(request: uRequest)
        
        uRequest.responseJSON { (response) in
            
            self.logging(response: response)
            if(response.result.error == nil)
            {
                if(success != nil) {
                    success!(uRequest.task!, response.result.value as AnyObject)
                }
            }
            else
            {
                if(failure != nil) {
                    failure!(uRequest.task!, response.result.error as
                        NSError?)
                }
            }
        }
        
        return uRequest.task
    }
    
    func POST(param parameters:[String: AnyObject]?, multipartFormData: @escaping (MultipartFormData) -> Void, success:ClosureSuccess?,  failure:ClosureError?) -> Void
    {
        
        
        SessionSharedManager.shared().upload(multipartFormData: { (multipart) in
            multipartFormData(multipart)
            
            for (key, value) in parameters! {
                
                multipart.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        },  to: (BASEURL! + (parameters?["tag"] as? String ?? "")), method: HTTPMethod.post , headers: headers) { (encodingResult) in
            
            switch encodingResult {
                
            case .success(let uRequest, _, _):
                
                self.logging(request: uRequest)
                
                uRequest.responseJSON { (response) in
                    
                    self.logging(response: response)
                    if(response.result.error == nil)
                    {
                        if(success != nil) {
                            success!(uRequest.task!, response.result.value as AnyObject)
                        }
                    }
                    else
                    {
                        if(failure != nil) {
                            failure!(uRequest.task!, response.result.error as NSError?)
                        }
                    }
                }
                
                break
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
        
    }
    
    func HEAD(param parameters: [String: AnyObject]?, success : ClosureSuccess?, failure:ClosureError?) -> URLSessionTask
    {
        
        let uRequest = SessionSharedManager.shared().request(BASEURL!, method: .head, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        self.logging(request: uRequest)
        
        uRequest.responseJSON { (response) in
            
            self.logging(response: response)
            if response.result.error == nil
            {
                if (success != nil) {
                    success!(uRequest.task!, response.result.value as AnyObject)
                }
            }
            else
            {
                if(failure != nil) {
                    failure!(uRequest.task!, response.result.error as NSError?)
                }
            }
        }
        
        return uRequest.task!
    }
    
    func PATCH(param parameters: [String: AnyObject]?, success : ClosureSuccess?, failure:ClosureError?) -> URLSessionTask
    {
        
        let uRequest = SessionSharedManager.shared().request(BASEURL!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        self.logging(request: uRequest)
        
        uRequest.responseJSON { (response) in
            
            self.logging(response: response)
            if response.result.error == nil
            {
                if (success != nil) {
                    success!(uRequest.task!, response.result.value as AnyObject)
                }
            }
            else
            {
                if(failure != nil) {
                    failure!(uRequest.task!, response.result.error as NSError?)
                }
            }
        }
        
        return uRequest.task!
    }
    
    func PUT(param parameters: [String: AnyObject]?, success : ClosureSuccess?, failure:ClosureError?) -> URLSessionTask
    {
        
        let uRequest = SessionSharedManager.shared().request(BASEURL!, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        self.logging(request: uRequest)
        
        uRequest.responseJSON { (response) in
            
            self.logging(response: response)
            if response.result.error == nil
            {
                if (success != nil) {
                    success!(uRequest.task!, response.result.value as AnyObject)
                }
            }
            else
            {
                if(failure != nil) {
                    failure!(uRequest.task!, response.result.error as NSError?)
                }
            }
            
        }
        
        return uRequest.task!
    }
    
    func DELETE(param parameters: [String: AnyObject]?, success : ClosureSuccess?, failure:ClosureError?) -> URLSessionTask
    {
        
        let uRequest = SessionSharedManager.shared().request(BASEURL!, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        self.logging(request: uRequest)
        
        uRequest.responseJSON { (response) in
            
            self.logging(response: response)
            if response.result.error == nil
            {
                if (success != nil) {
                    success!(uRequest.task!, response.result.value as AnyObject)
                }
            }
            else
            {
                if(failure != nil) {
                    failure!(uRequest.task!, response.result.error as? NSError)
                }
            }
        }
        
        return uRequest.task!
    }
}


//MARK:-
//MARK:- APIRequest Class

class APIRequest: NSObject {
    
    
    typealias ClosureCompletion = (_ response:AnyObject?, _ error:NSError?) -> Void
    
    typealias successCallBack = (([String:AnyObject]?) -> ())
    typealias failureCallBack = ((String) -> ())
    
    /// API BASEURL
    var BASEURL:String      = "https://stark-spire-93433.herokuapp.com/json"
    
    
    
    
    //MARK:- APIRequest Singleton
    
    private override init() {
        super.init()
    }
    
    private var apiRequest:APIRequest {
        let apiRequest = APIRequest()
        
        if (BASEURL.characters.count > 0 && !BASEURL.hasSuffix("/")) {
            BASEURL = BASEURL + "/"
        }
        
        Networking.sharedInstance.BASEURL = BASEURL
        return apiRequest
    }
    
    static func shared() -> APIRequest {
        return APIRequest().apiRequest
    }
    
    private func handleStatusCode(response:AnyObject? , successCallBack:successCallBack , failureCallBack:failureCallBack) {
        
        
    }
    
    
    //MARK: Get category list
    func wsGetCategoryList(successCallBack:@escaping successCallBack , failureCallBack:@escaping failureCallBack)
    {
        HUD.show(.labeledProgress(title: nil, subtitle: "Fetching details..."))
        Networking.sharedInstance.GET(param: nil, success: { (task
            , response) in
            HUD.hide()
            successCallBack(response as? [String : AnyObject] ?? nil)
        }) { (task, error) in
            HUD.hide()
            failureCallBack((error?.localizedDescription)!)
            
        }
    }
    

    
    
}

class SessionSharedManager {
    
    private init() {}
    
    private static var sessionManager:SessionManager =  {
        let sessionManager = SessionManager()
        return sessionManager
    }()
    
    static func shared() -> SessionManager {
        return self.sessionManager
    }
    
}




