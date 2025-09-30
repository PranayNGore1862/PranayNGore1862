//
//  StoreReviewHelper.swift
//  deeplab-ios
//
//  Created by MacMini on 29/09/21.
//  Copyright © 2021 xyh. All rights reserved.
//

import Foundation
import StoreKit

struct UserDefaultsKeys {
    static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
}

let countDefaults = UserDefaults.standard
var partialRatedApp = UserDefaults.standard

struct StoreReviewHelper {
    
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = countDefaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            countDefaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        print("\(appOpenCount)")
        countDefaults.set(appOpenCount, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
    }
    
    static func checkforAppOpenCount() -> Bool { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        var appOpenCount = countDefaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int
        print("App run count is : \(appOpenCount)")
        switch appOpenCount {
        case 2,4,6,8:
            return true
        case _ where appOpenCount! % 2 == 0 :
            return true
        default:
            break;
        }
        return false
    }
    
    fileprivate func requestReview() {
        DispatchQueue.main.async {
             if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    // Fallback on earlier versions
                    // Try any other 3rd party or manual method here.
                }
            }
        }
       
       
    
}
