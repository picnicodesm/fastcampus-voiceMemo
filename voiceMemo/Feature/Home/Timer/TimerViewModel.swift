//
//  TimerViewModel.swift
//  voiceMemo
//

import Foundation
import UIKit

class TimerViewModel: ObservableObject {
    @Published var isDisplaySetTimeView: Bool
    @Published var time: Time
    @Published var timer: Timer?
    @Published var timeRemaining: Int
    @Published var isPaused: Bool
    var notificationService: NotificationService
    
    init(
        isDisplaySetTimeView: Bool = true,
        time: Time = .init(hours: 0, minutes: 0, seconds: 0),
        timer: Timer? = nil,
        timeRemaining: Int = 0,
        isPaused: Bool = false,
        notificationService: NotificationService = .init()
    ) {
        self.isDisplaySetTimeView = isDisplaySetTimeView
        self.time = time
        self.timer = timer
        self.timeRemaining = timeRemaining
        self.isPaused = isPaused
        self.notificationService = notificationService
    }
}

extension TimerViewModel {
    func settingBtnTapped() {
        isDisplaySetTimeView = false
        timeRemaining = time.convertedSeconds
        startTimer()
    }
    
    func cancelBtnTapped() {
        stopTimer()
        isDisplaySetTimeView = true
    }
    
    func pauseOrRestartBtnTapped() {
        if isPaused {
            startTimer()
        } else {
            timer?.invalidate()
            timer = nil
        }
        isPaused.toggle()
    }
}

private extension TimerViewModel { // private extension에 작성된 함수들은 자동으로 private로 작성됨
    func startTimer() {
        guard timer == nil else { return }
        
        // 백그라운드에서도 동작핤 수 있도록 만들어줘야 함.
        var backgroundTaskID: UIBackgroundTaskIdentifier?
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            // 앱이 백그라운드로 전환되었을 떄 일부 작업을 계속 수행할 수 있게 해주는 메서드
            // UIapplicationTaskIdentifier 타입의 값을 반환하며 이 값은 나중에 백그라운드 작업을 종료시키기 위해 사용합니다.
            // expireHandler는 파라미터에 전달된 클로저는 ios 시스템이 애플리케이션에 할당한 백그라운드 실행시간이 소진되어 갈 때 호출합니다.
            // 클로저 내부에서 먼저 위에서 저장한 백그라운드 작업, id, 백그라운드 task id가 있는지 확인합니다.
            // 만약 task id가 없으면 uiapplication.share에 endbakcgroundTask 메서드를 호출해서 해당 백그라운드 작업을 종료시킵니다.
            // 그리고 invalid를 대입해서 해당 변수를 무효화 시킵니다.
            // 따라서 이 코드는 애플리케이션의 일부 기능, 타이머 같은 게 있는 ios시스템으로부터 제공받은 제한적인 시간동안 계속해서 실행하도록 하는 역할을 하게 됩니다.
            // 그래서 백그라운드에서 알림을 발생시키고 푸시 알림을 받을 수 있는 것이죠.
            // 이게 없으면 푸시는 올 수 있지만 타이머가 흐르지 않습니다.
            if let task = backgroundTaskID {
                UIApplication.shared.endBackgroundTask(task)
                backgroundTaskID = .invalid
            }
        }
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.notificationService.sendNotification()
                
                if let task = backgroundTaskID {
                    UIApplication.shared.endBackgroundTask(task)
                    backgroundTaskID = .invalid
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
