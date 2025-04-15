//
//  DPABTestParam.swift
//  DPABTestSDKSwift
//
//  Created by BJSTTLP185 on 2025/4/14.
//

import Foundation
import MJExtension

@objcMembers
class DPABTestParam: NSObject, NSCoding {
    var key: String?
    var value: String?
    var reserve1: String?
    var reserve2: String?
    var reserve3: String?
    var reserve4: String?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.key = aDecoder.decodeObject(forKey: "key") as? String
        self.value = aDecoder.decodeObject(forKey: "value") as? String
        self.reserve1 = aDecoder.decodeObject(forKey: "reserve1") as? String
        self.reserve2 = aDecoder.decodeObject(forKey: "reserve2") as? String
        self.reserve3 = aDecoder.decodeObject(forKey: "reserve3") as? String
        self.reserve4 = aDecoder.decodeObject(forKey: "reserve4") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")
        aCoder.encode(value, forKey: "value")
        aCoder.encode(reserve1, forKey: "reserve1")
        aCoder.encode(reserve2, forKey: "reserve2")
        aCoder.encode(reserve3, forKey: "reserve3")
        aCoder.encode(reserve4, forKey: "reserve4")
    }
}
extension DPABTestParam {
    func dictionaryFromModel() -> [String: Any] {
        let result = self.mj_JSONObject()
        return result as? [String: Any] ?? [:]
    }
}
