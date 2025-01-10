//
//  AppDelegate.swift
//  voiceMemo
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate { // 앱에서 일어나는 상호작용이나 시스템 로우레벨에서 일어나는 일을 컨트롤할수 있음
    var notificationDelegate = NotificationDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        return true
    }
}
