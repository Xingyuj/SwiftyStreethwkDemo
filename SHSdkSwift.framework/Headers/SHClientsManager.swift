//
//  Created by Xingyuji on 27/12/17.
//  Copyright © 2017 com.xingyuji. All rights reserved.
//

import Foundation
import Alamofire
import os.log
import SwiftyBeaver
import SwiftyJSON

let log = SwiftyBeaver.self

/// This is a convenience class for the typical single user case. To use this

@objc public class SHClientsManager:NSObject {
    @objc public static var shProcessor: SHClientsManager?
    @objc public var appKey: String
    var logBuffer: Array<Any>
    var locationUpdates: String?
    @objc public var host: String?
    var libVersion: String?
    var growthHost: String?
    var installId: String?
    var model: String?
    var osVersion: String?

    @objc init(appKey: String) {
        self.appKey = appKey
        self.logBuffer = []
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String {
            self.libVersion = version
        }
        // set log
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()  // log to default swiftybeaver.log file
        let url = URL.init(string: "/tmp/streethawk.log")
        file.logFileURL = url
        log.addDestination(console)
        log.addDestination(file)
    }
    
    @objc public static func setupWithAppKey(_ appKey: String, completionHandler: @escaping (String) -> ()) {
        NSLog("[StreetHawk] setupWithAppKey [" + appKey + "]")
        let manager = SHClientsManager.init(appKey: appKey)
        self.shProcessor = manager
        manager.findAppHost(){ result in
            log.debug("request app status finished")
            let host = result!["host"].stringValue
            completionHandler(host)
            manager.host = host
            manager.growthHost = result!["growthHost"].stringValue
            manager.locationUpdates = result!["locationUpdates"].stringValue
            manager.registerInstall()
        }
    }
    
    private func findAppHost(completionHandler: @escaping (JSON?) -> ()){
        print("findAppHost beginning....")
        let apiProcessor = SHApiProcessor.init(ManagerConstants.ROUTE_SERVER)
        apiProcessor.requestScheme = ManagerConstants.HTTPS_SCHEME
        apiProcessor.encoding = URLEncoding.default
        apiProcessor.path = ManagerConstants.ROUTE_QUERY
        apiProcessor.parameters = ["app_key": appKey]
        apiProcessor.method = HTTPMethod.get
        apiProcessor.headers = ["X-App-Key": "hipointX", "X-Version": "1.8.8", "User-Agent": "hipointX(1.8.8)"]

        print("prepare processing SHApi....")
        apiProcessor.requestHandler(){ res, error in
            if let _res = res {
                var result = JSON()
                if let locationUpdates = _res["app_status"]["location_updates"].rawString() {
                    result["locationUpdates"].string = locationUpdates
                } else {
                    print("app_status.location_updates is nil")
                }
                if let host = _res["app_status"]["host"].rawString() {
                    result["host"].string = host
                } else {
                    print("app_status.host is nil")
                }
                if let growthHost = _res["app_status"]["growth_host"].rawString() {
                    result["growthHost"].string = growthHost
                } else {
                    print("app_status.growth_host is nil")
                }
                completionHandler(result)
            } else if let _error = error {
                NSLog(_error.localizedDescription)
            } else {
                os_log("Both response and error are nil return from server", type: .error)
            }
        }
    }
    
    private func registerInstall(){
        print("registerInstall beginning....")
        if let _host = host {
            print("registerInstall host got....")
            let apiProcessor = SHApiProcessor.init((URL(string: _host)?.host)!)
            print("init ManagerUtil done....")
            apiProcessor.requestScheme = ManagerConstants.HTTPS_SCHEME
            apiProcessor.encoding = JSONEncoding.default
            apiProcessor.path = ManagerConstants.INSTALL_REGISTER
            apiProcessor.parameters = ["sh_version": "1.8.8", "operating_system": "ios"]
            apiProcessor.headers = ["X-App-Key": appKey, "Content-Type": "application/json"]
            apiProcessor.method = HTTPMethod.post
            print("registerInstall initial done....")
            apiProcessor.requestHandler(){ res, error in
                print("registerInstall res returned....")
                if let _res = res {
                    if let installid = _res["value"]["installid"].rawString() {
                        self.installId = installid
                        NSLog("install id: "+installid)
                        print("update install begin....")
                        self.updateInstall()
                    } else {
                        print("app_status.location_updates is nil")
                    }
                }
            }
        } else {
            os_log("host is unclear", type: .error)
        }
        
    }
    
    private func updateInstall(){
        print("updateInstall beginning....")
        if let _host = host {
            print("updateInstall host got....")
            let apiProcessor = SHApiProcessor.init((URL(string: _host)?.host)!)
            print("init ManagerUtil done....")
            apiProcessor.requestScheme = ManagerConstants.HTTPS_SCHEME
            apiProcessor.encoding = JSONEncoding.default
            apiProcessor.path = ManagerConstants.INSTALL_UPDATE
            apiProcessor.queryItems = [URLQueryItem(name: "installid", value: installId)]
            apiProcessor.parameters = [
                ManagerConstants.APP_KEY: appKey,
                ManagerConstants.INSTALL_ID: installId ?? "",
                ManagerConstants.SH_LIBRARY_VERSION: ManagerUtils.getSDKVersion(),
                ManagerConstants.OPERATING_SYSTEM: "ios",
                ManagerConstants.CLIENT_VERSION: ManagerUtils.getSDKVersion(),
                ManagerConstants.MODEL: model ?? "",
                ManagerConstants.OS_VERSION: UIDevice.current.systemVersion,
                ManagerConstants.MAC_ADDRESS: UIDevice.current.identifierForVendor?.uuidString ?? ""
            ]
            apiProcessor.headers = [
                "X-App-Key": appKey,
                "X-Installid": installId ?? "",
                "Content-Type": "application/json"
            ]
            apiProcessor.method = HTTPMethod.post
            
            print("updateInstall initial done....")
            apiProcessor.requestHandler(){ res, error in
                print("updateInstall res returned....")
                if let _res = res {
                    log.info("Install update successful, res: \(String(describing: _res))")
                    print("Install update successful, res: \(String(describing: _res))")
                } else if let _error = error {
                    NSLog(_error.localizedDescription)
                } else {
                    os_log("Both response and error are nil return from server", type: .error)
                }
            }
        } else {
            os_log("host is unclear", type: .error)
        }
    }
    
    private func presetCommonValues(_ processor: SHApiProcessor, method: HTTPMethod? = HTTPMethod.get){
        log.debug("presetCommonValues....")
        processor.requestScheme = ManagerConstants.HTTPS_SCHEME
        processor.encoding = JSONEncoding.default
        processor.queryItems = [URLQueryItem(name: "installid", value: installId)]
        processor.parameters = [
            ManagerConstants.APP_KEY: appKey,
            ManagerConstants.INSTALL_ID: installId ?? "",
        ]
        processor.headers = [
            "X-App-Key": appKey,
            "X-Installid": installId ?? "",
            "Content-Type": "application/json"
        ]
        processor.method = method
        log.debug("presetCommonValues done....")
    }
    
    @objc public func tagViaApi(_ content: Dictionary<String, String>, authToken: String){
        if (host == nil){
            return
        }
        log.debug("tagViaApi begin")
        
        print((URL(string: host!)?.host)!)
        let apiProcessor = SHApiProcessor.init((URL(string: host!)?.host)!)
        presetCommonValues(apiProcessor, method: HTTPMethod.post)
        let presetParameters = JSON(apiProcessor.parameters!)
        guard let resultParam = try? presetParameters.merged(with: JSON(content)) else {
            log.error("error occur when merging two json, thrown by SwiftyJSON merged method")
            return
        }
        apiProcessor.path = ManagerConstants.V3_TAGS
        apiProcessor.headers!["X-Auth-Token"] = authToken
        apiProcessor.parameters = (resultParam.rawValue as! [String:Any])
        
        log.debug("processLogline initial finished")
        apiProcessor.requestHandler(){ res, error in
            print("tagViaApi sent successful res returned....")
            if let _res = res {
                log.info("tagViaApi sent successful, res: \(String(describing: _res))")
                print("tagViaApi sent successful, res: \(String(describing: _res))")
            } else if let _error = error {
                NSLog(_error.localizedDescription)
            } else {
                os_log("Both response and error are nil return from server", type: .error)
            }
        }
    }
    
    @objc public func tagViaLogline(_ content: Dictionary<String, String>){
        var jsonContent = JSON(content)
        jsonContent[ManagerConstants.CODE].int = ManagerConstants.CODE_UPDATE_CUSTOM_TAG
        sendPriorityLogline(jsonContent)
    }
    
    public func sendPriorityLogline(_ content: JSON){
        var immediateLogBuffer: Array<Any> = []
        ManagerUtils.assembleLogRecords(&immediateLogBuffer, content)
        processLogline(immediateLogBuffer)
    }
    
    public func processLogline(_ records: Array<Any>){
        log.info("processLogline begin")
        if (host == nil){
            return
        }
        print((URL(string: host!)?.host)!)
        let apiProcessor = SHApiProcessor.init((URL(string: host!)?.host)!)
        var param = [String: Any]()
        param = [
            ManagerConstants.APP_KEY: appKey,
            ManagerConstants.INSTALL_ID: installId ?? "",
        ]
        param[ManagerConstants.RECORDS] = records
        apiProcessor.requestScheme = ManagerConstants.HTTPS_SCHEME
        apiProcessor.encoding = JSONEncoding.default
        apiProcessor.path = ManagerConstants.INSTALL_LOG
        apiProcessor.queryItems = [URLQueryItem(name: "installid", value: installId)]
        apiProcessor.parameters = param
        apiProcessor.headers = [
            "X-App-Key": appKey,
            "X-Installid": installId ?? "",
            "Content-Type": "application/json"
        ]
        apiProcessor.method = HTTPMethod.post
        log.debug("processLogline initial finished")
        apiProcessor.requestHandler(){ res, error in
            print("Logline sent successful res returned....")
            if let _res = res {
                log.info("Logline sent successful, res: \(String(describing: _res))")
                print("Logline sent successful, res: \(String(describing: _res))")
            } else if let _error = error {
                NSLog(_error.localizedDescription)
            } else {
                os_log("Both response and error are nil return from server", type: .error)
            }
        }
    }
    
}
