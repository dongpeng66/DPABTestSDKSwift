//
//  DPABTestDefaultFlag.swift
//  DPABTestSDKSwift
//
//  Created by BJSTTLP185 on 2025/4/14.
//

import Foundation
class DPABTestDefaultFlag: NSObject {
    // MARK: - AB测试枚举
    enum DPABTestValue: Int {
        case a = 0
        case b = 1
        case c = 2
    }
    class func getFda() -> DPABTestValue {
        return DPABTestDefaultFlag.DPABTestValue(rawValue: Int(DPABTest.shared.string(forFlag: DPABTestConst.ABTEST_FDA, defaultValue: "0")) ?? 0) ?? .a
    }
    
}

