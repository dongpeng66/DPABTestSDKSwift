//
//  DPABTest.swift
//  DPABTestSDKSwift
//
//  Created by BJSTTLP185 on 2025/4/14.
//

import Foundation
import AFNetworking

class DPABTest: NSObject {
    
    static let DPABTEST_CONFIG_URL = "https://raw.githubusercontent.com/dongpeng66/public/main/abtest.json"


    lazy var abStore: DPABTestStore = {
        let v = DPABTestStore()
        //...白名单
//        [_abStore addWhites:@""];
        return v
    }()
    @objc public static let shared = DPABTest()
    var netWorkSuccess: ((_ abTest: DPABTest) -> ())?
    var netWorkFailure: (() -> ())?
    
    // 保存ab的key和value，为了提升读取速度，增加此变量
    private var testData: [String: Any] = [:]
    private let lock = NSLock()
    
    
    /**
     *  @brief 启用ABTest
     */
    func launch() {
        
        
        if let switchValue = abStore.string(forKey: DPABTestStore.QA_ABTEST_SWITCH_KEY), switchValue == "1" {
            // 打开小工具QA_ABTEST开关则不拉接口，用于调试写死本地的AB值
            netWorkFailure?()
            return
        }
        
        fetchABConfig()
    }
    
    func string(forFlag flag: String, defaultValue: String) -> String {
        lock.lock()
        defer { lock.unlock() }
        
        if let result = testData[flag.lowercased()] as? String {
            return result
        }
        
        if let result = abStore.string(forKey: flag.lowercased()), result != DPABTestStore.NotFoundValue {
            return result
        }
        
        return defaultValue
    }
    
    func bool(forFlag flag: String, defaultValue: Bool) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        if let result = testData[flag.lowercased()] as? String {
            return Bool(result) ?? defaultValue
        }
        
        if let result = abStore.string(forKey: flag.lowercased()), result != DPABTestStore.NotFoundValue {
            return Bool(result) ?? defaultValue
        }
        
        return defaultValue
    }

    // MARK: - 网络请求
    func fetchABConfig() {
        fetchABConfig(success: nil, failure: nil)
    }
    
    func fetchABConfig(success: ((DPABTest) -> Void)?, failure: (() -> Void)?) {
//        let configUrl = DPABTest.DPABTEST_CONFIG_URL
//        let parameters: [String: Any] = [:]  // 可根据需要添加参数
//        
//        let manager = AFHTTPSessionManager(baseURL: URL(string: configUrl))
//        manager.requestSerializer = AFHTTPRequestSerializer()
//        let responseSerializer = AFJSONResponseSerializer()
//        responseSerializer.acceptableContentTypes = ["application/json", "text/json", "text/javascript", "text/html", "text/plain"]
//        manager.responseSerializer = responseSerializer
//        
//        manager.get(configUrl, parameters: parameters, headers: nil) { downloadProgress  in
//            
//        } success: { [weak self] task, responseObject in
//            guard let self = self else { return }
//            
//            if let json = responseObject as? [String: Any],
//               let respCode = json["respCode"] as? String, respCode == "0",
//               let respData = json["respData"] as? [String: Any] {
//                handleSuccessResponse(json, success: success, failure: failure)
//            } else {
//                handleBusinessFailure(failure: failure)
//            }
//        } failure: { [weak self]  task, error in
//            guard let self = self else { return }
//            handleFailure(error: error as NSError, failure: failure)
//        }
        
        loadNetWork(success: success, failure: failure)
    }
    
    func loadNetWork(success: ((DPABTest) -> Void)?, failure: (() -> Void)?) {
        let configUrl = DPABTest.DPABTEST_CONFIG_URL
        guard let apiURL = URL(string: configUrl) else {
            return
        }
        
        fetchJSONFromURL(apiURL) { [weak self]  (responseObject, error) in
            guard let self = self else { return }
            print("22222")
            if let json = responseObject as? [String: Any],
               let respCode = json["respCode"] as? String, respCode == "0",
               let respData = json["respData"] as? [String: Any] {
                handleSuccessResponse(json, success: success, failure: failure)
            } else {
                if let err = error {
                    handleFailure(error: err as NSError, failure: failure)
                } else {
                    handleBusinessFailure(failure: failure)
                }
                
            }
        }
    }
    func fetchJSONFromURL(_ url: URL, completion: @escaping (Any?, Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            // 错误处理
            if let error = error ?? (data == nil ? NSError(domain: "Data Error", code: -1, userInfo: nil) : nil) {
                completion(nil, error)
                return
            }
            
            // 状态码验证
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(nil, NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil))
                return
            }
            
            // JSON解析
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                completion(jsonObj, nil)
            } catch let jsonError {
                completion(nil, jsonError)
            }
        }
        task.resume()
    }

    
    // MARK: - 响应处理
    private func handleSuccessResponse(_ response: Any,
                                       success: ((DPABTest) -> Void)?,
                                       failure: (() -> Void)?) {
        guard let json = response as? [String: Any],
              let respCode = json["respCode"] as? String, respCode == "0",
              let respData = json["respData"] as? [String: Any],
              let testData = respData["testdata"] as? [[String: Any]] else {
            handleBusinessFailure(failure: failure)
            return
        }

        
        // 处理测试数据
        var storeArray: [DPABTestParam] = []
        var updatedTestData: [String: String] = [:]
        
        for configDict in testData {
            guard let key = (configDict["abtk"] as? String)?.lowercased(),
                  let value = configDict["abtv"] as? String,
                  !key.isEmpty, !value.isEmpty else {
                // 判断key和value一个不存在，则跳过
                continue
            }
            
            // 额外值，额外字段，可扩展，可以不用
            let params = configDict["para"] as? String
            let param = DPABTestParam()
            param.key = key
            param.value = value
            param.reserve1 = params
            
            storeArray.append(param)
            updatedTestData[key] = value
            
            // 更新存储，更新内存中的字典值，用于快速使用，提高首次启动就获取到准备的AB值的命中率
            self.abStore.updateValueIfExists(key, value: value)
        }
        
        // 清理存储
        self.abStore.clearStore()
        
        // 添加版本信息
        let versionParam = DPABTestParam()
        versionParam.key = "version"
        versionParam.value = "1.2"
        storeArray.append(versionParam)
        
        // 批量写入
        self.abStore.insertABTestParams(storeArray)
        
        // 更新内存数据
        lock.lock()
        defer { lock.unlock() }
        self.testData.removeAll()
        self.testData = updatedTestData
        
        // 发送通知
        NotificationCenter.default.post(name: .kABTestFetchConfigSuccessNotification, object: nil)
        
        // 回调
        success?(self)
        self.netWorkSuccess?(self)
        
    }
    
    private func handleFailure(error: NSError, failure: (() -> Void)?) {
        NotificationCenter.default.post(name: .kABTestFetchConfigFailedNotification, object: ["reason": "error"])
        failure?()
        self.netWorkFailure?()
    }
    
    private func handleBusinessFailure(failure: (() -> Void)?) {
        NotificationCenter.default.post(name: .kABTestFetchConfigFailedNotification, object:  ["reason": "buz"])
        failure?()
        self.netWorkFailure?()
    }
    // MARK: - 主要方法
    func getLocalJson() {
        // 实现本地 JSON 获取逻辑
        guard let path = Bundle.main.path(forResource: "abtest", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            guard let response = jsonObject as? [String: Any],
                  let respCode = response["respCode"] as? String, respCode == "0",
                  let respData = response["respData"] as? [String: Any],
                  let testData = respData["testdata"] as? [[String: Any]] else {
                return
            }
            
            handleSuccessResponse(jsonObject, success: nil, failure: nil)
            
        } catch {
            print("解析失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 调试方法-debug小工具使用，用于手动更改某个AB值
    func debug_updateTestData(key: String, value: String) {
        guard !key.isEmpty, !value.isEmpty else { return }
        
        lock.lock()
        defer { lock.unlock() }
        testData[key] = value
        abStore.setValue(key, forKey: value)
    }
    
    // MARK: - 调试方法-debug小工具使用，用于手动清楚AB值数据
    func debug_clearData() {
        abStore.clearStore()
    }
    
}
// MARK: - Notification
extension NSNotification.Name {
    static let kABTestFetchConfigSuccessNotification = Notification.Name("kABTestFetchConfigSuccessNotification")
    static let kABTestFetchConfigFailedNotification = Notification.Name("kABTestFetchConfigFailedNotification")
}
