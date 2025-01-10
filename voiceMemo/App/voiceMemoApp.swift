//
//  voiceMemoApp.swift
//  voiceMemo
//

import SwiftUI

@main
struct voiceMemoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // UIKit의 UIApplicationDelegate와 상호작용할 수 있음
    // swiftui의 라이프사이클을 사용하는 앱에서 app delegate 콜백을 처리하려면 uiapplicationdelegate 프로토콜을 준수해야 하고 각자 필요한 delegate 메서드를 구현해야 합니다.
    // swiftui는 delegate를 인스턴스화하고 생명주기 이벤트가 발생할 때마다 응답해서 delegate 메서드를 호출합니다.
    // delegate adaptor는 앱 선언부에서만 정의하고 꼭 앱에서 한 번만 선언해야 합니다.
    // 만약 여러 번 선언을 해서 사용하게 되면 swiftui가 런타임 에러를 일으키게 됩니다.
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }
    }
}
