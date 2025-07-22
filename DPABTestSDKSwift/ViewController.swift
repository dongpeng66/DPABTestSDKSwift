//
//  ViewController.swift
//  DPABTestSDKSwift
//
//  Created by BJSTTLP185 on 2025/4/14.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let dataArray = DPABTest.shared.abStore.queryAllKeyValues()
        
        for d in dataArray {
            if !d.isEmpty {
                print("--key ---\(String(describing: d["key"]))   -- value-----\(String(describing: d["value"])) ")
            }
        }
        let fdaAb = DPABTestDefaultFlag.getFda()
        print("[DPABTestDefaultFlag getFda]---\(fdaAb)")
        if fdaAb == .b {
            print("DPABTestValue_B")
        }
        
    }


}

