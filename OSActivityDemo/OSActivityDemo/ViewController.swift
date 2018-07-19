//
//  ViewController.swift
//  OSActivityDemo
//
//  Created by Ben Scheirman on 7/19/18.
//  Copyright © 2018 NSScreencast. All rights reserved.
//

import UIKit
import os.log
import os.activity

class ViewController: UIViewController {
    let log = OSLog(subsystem: "com.ficklebits.OSActivityDemo", category: "general")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
        let sym = dlsym(RTLD_DEFAULT, "_os_activity_current")
        let OS_ACTIVITY_CURRENT = unsafeBitCast(sym, to: os_activity_t.self)
        
        
        let dso = UnsafeMutableRawPointer(mutating: #dsohandle)
        let desc: StaticString = "My Custom Activity"
        desc.withUTF8Buffer { buffer in
            if let address = buffer.baseAddress {
                let descriptionBuffer = UnsafeRawPointer(address).assumingMemoryBound(to: Int8.self)
                
                let activity = _os_activity_create(dso, descriptionBuffer, OS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT)
                os_activity_apply(activity, {
                    os_log("Logging from my custom activity", log: self.log, type: .info)
                })
            }
        }
        
        
        
        
        
        let activity = Activity("Complex Work")
        activity.apply {
            os_log("Starting some work...", log: log, type: .info)
            DispatchQueue.global(qos: .background).async {
                os_log("Work started...", log: self.log, type: .info)
                self.doStuff()
            }
        }
        
        makeCoffee()
    }
    
    func doStuff() {
        os_log("work...", log: self.log, type: .info)
        os_log("work...", log: self.log, type: .info)
        os_log("work...", log: self.log, type: .info)
    }
    

    
    
    
    
    
    
    
    
    
    
    lazy var operationQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 2
        q.underlyingQueue = DispatchQueue.global(qos: .userInitiated)
        return q
    }()
    

    
    func makeCoffee() {
        let makeCoffeeActivity = Activity("Make Coffee")
        makeCoffeeActivity.apply {
            os_log("Starting to make the coffee", log: self.log, type: .info)
            
            let waterOp = heatUpWater()
            let grindOp = grindBeans()
            let brewOp = brew()
            
            brewOp.addDependency(waterOp)
            brewOp.addDependency(grindOp)
            
            let done = BlockOperation {
                os_log("Enjoy your coffee!", log: self.log, type: .info)
            }
            done.addDependency(brewOp)
            self.operationQueue.addOperation(waterOp)
            self.operationQueue.addOperation(grindOp)
            self.operationQueue.addOperation(brewOp)
            self.operationQueue.addOperation(done)
        }
    }
    
    func heatUpWater() -> Operation {
        let waterActivity = Activity("Heat Up Water")
        return BlockOperation {
            _ = waterActivity.enter()
            os_log("Heating up water", log: self.log, type: .info)
            var temp = 72
            while temp < 209 {
                os_log("Water temp: %d°F", log: self.log, type: .info, temp)
                sleep(1)
                temp += 18
            }
            os_log("Water is ready! temp: %d°F", log: self.log, type: .info, temp)
        }
    }
    
    func grindBeans() -> Operation {
        let grindActivity = Activity("Grind Beans")
        return BlockOperation {
            _ = grindActivity.enter()
            os_log("Grinding Beans...", log: self.log, type: .info)
            sleep(3)
            os_log("Beans are ready!", log: self.log, type: .info)
        }
    }
    
    func brew() -> Operation {
        let brewActivity = Activity("Brew")
        return BlockOperation {
            _ = brewActivity.enter()
            os_log("Brewing coffee...", log: self.log, type: .info)
            sleep(1)
            os_log("☕️!", log: self.log, type: .info)
        }
    }
}
