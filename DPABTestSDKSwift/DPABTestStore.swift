//
//  DPABTestStore.swift
//  DPABTestSDKSwift
//
//  Created by BJSTTLP185 on 2025/4/14.
//

import Foundation
import MMKV

class DPABTestStore: NSObject {
    
    // MARK: - 属性
    private var storeDict: [String: String] = [:]
    var whiteKeys: [String] = []
    
    private let lock = NSLock()
    
    static let shared = DPABTestStore()
    static let storeIDKey = "__DPABTestStoreIDKEY__"
    static let NotFoundValue = "__NotFound__"
    static let QA_ABTEST_SWITCH_KEY = "QA_ABTEST_SWITCH_KEY"
    
    private let mmkv = MMKV(mmapID: DPABTestStore.storeIDKey)
    
    // MARK: - 初始化
    override init() {
        
    }
    
    // MARK: - 公共方法
    func updateValueIfExists(_ key: String, value: String) {
        lock.lock()
        defer { lock.unlock() }
        
        guard !key.isEmpty else { return }
        let lowerKey = key.lowercased()
        
        guard !whiteKeys.contains(lowerKey) else { return }
        guard storeDict[lowerKey] == nil else { return }
        
        storeDict[lowerKey] = value
    }
    
    func addWhiteKey(_ key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let lowerKey = key.lowercased()
        if !whiteKeys.contains(lowerKey) {
            whiteKeys.append(lowerKey)
        }
    }
    
    func string(forKey key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        
        guard !key.isEmpty else { return nil }
        let lowerKey = key.lowercased()
        
        // 内存缓存查找
        if let value = storeDict[lowerKey] {
            return value != DPABTestStore.NotFoundValue ? value : nil
        }
        
        // 持久化存储查找
        if let param = mmkv?.object(of: DPABTestParam.self, forKey: lowerKey) as? DPABTestParam {
            let storedValue = param.value ?? DPABTestStore.NotFoundValue
            storeDict[lowerKey] = storedValue
            return storedValue != DPABTestStore.NotFoundValue ? storedValue : nil
        }
        
        return nil
    }
    
    func setValue(_ value: String, forKey key: String) {
        setValue(value, forKey: key, param: nil)
    }
    
    func setValue(_ value: String, forKey key: String, param: String?) {
        lock.lock()
        defer { lock.unlock() }
        
        guard !key.isEmpty else { return }
        let lowerKey = key.lowercased()
        
        storeDict[lowerKey] = value
        let paramObj = DPABTestParam()
        paramObj.key = key
        paramObj.value = value
        paramObj.reserve1 = param
        mmkv?.set(paramObj, forKey: lowerKey)
    }
    // 批量插入DPABTestParam
    func insertABTestParams(_ params: [DPABTestParam]) {
        lock.lock()
        defer { lock.unlock() }
        
        for param in params {
            if let keyS = param.key, !keyS.isEmpty {
                let lowerKey = keyS.lowercased()
                
                storeDict[lowerKey] = param.value ?? DPABTestStore.NotFoundValue
                
                mmkv?.set(param, forKey: lowerKey)
            }
        }
    }
    
    func clearStore() {
        lock.lock()
        defer { lock.unlock() }
        
        storeDict.removeAll()
        whiteKeys.removeAll()
        mmkv?.clearAll()
    }
    
    func queryAllKeyValues() -> [[String: Any]] {
        lock.lock()
        defer { lock.unlock() }
        
        let objects = mmkv?.allKeys() ?? [String]()
        var results = [[String: Any]]()
        
        for key in objects {
            if let keyString = key as? String, !keyString.isEmpty {
                if let param = mmkv?.object(of: DPABTestParam.self, forKey: keyString) as? DPABTestParam {
                    let re = param.dictionaryFromModel()
                    results.append(re)
                }
            }
        }
        return results
    }
}
