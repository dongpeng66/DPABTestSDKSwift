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
        
//        NSArray *dataArray = [[DPABTest sharedInstance].abStore queryAllKeyValues];
//        for (NSDictionary *dic in dataArray) {
//            NSLog(@"--key ---%@   -- value-----%@",dic[@"key"],dic[@"value"]);
//            
//        }
//
//        NSLog(@"[DPABTestDefaultFlag getFda]---%ld",[DPABTestDefaultFlag getFda]);
//        if ([DPABTestDefaultFlag getFda] == DPABTestValue_B) {
//            NSLog(@"DPABTestValue_B");
//        }
        
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

