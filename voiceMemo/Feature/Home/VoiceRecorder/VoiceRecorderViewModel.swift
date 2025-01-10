//
//  VoiceRecorderViewModel.swift
//  voiceMemo
//

import AVFoundation

class VoiceRecorderViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // AVAudioPlayerDelegate는 내부적으로 NSObject를 채택함 이 프로토콜은 Core Foundation 속성을 가진 타입이기에 객체들이 실행되는 런타임시에 런타임 매커니즘이 해당 프로토콜을 기반으로 동작하게 됨.
    // 그렇기에 AVAudioPlayerDelegate를 채택하여 객체를 구현하기 위해서는 NSObjectPlayer 프로토콜을 채택하거나 NSObject를 상속받아서 해당 AVAudioPlayerDelegate가 간접적으로 이 런타임 매커니즘을 사용할 수 있게 만들 수 있습니다.
    // 즉 둘 중 하나의 방식인데 NSObject를 상속받는 것이 더 단순해서 사용해봄.
    // 만약 둘 다 채택 혹은 상속하지 않는다면 기본 AVAudioPlayerDelegate의 필수 구현 메서드를 모두 정의해야지만 사용할 수 있지만 간단히 NSObject를 상속받아서 해결할 수 있습니다.
    
    @Published var isDisplayRemoveVoiceRecorderAlert: Bool
    @Published var isDisplayAlert: Bool
    @Published var alertMessage: String
    
    /// 음성메모 녹음 관련 프로퍼티
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording: Bool
    
    
    /// 음성메모 재생 관련 프로퍼티
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool
    @Published var isPaused: Bool
    @Published var playedTime: TimeInterval
    private var progressTimer: Timer?
    
    /// 음성메모된 파일
    var recordedFiles: [URL]
    
    /// 현재 선택된 음성메모 파일
    @Published var selectedRecordedFile: URL?
    
    init(isDisplayRemoveVoiceRecorderAlert: Bool = false,
         isDisplayAlert: Bool = false,
         alertMessage: String = "",
         isRecording: Bool = false,
         isPlaying: Bool = false,
         isPaused: Bool = false,
         playedTime: TimeInterval = 0,
         recordedFiles: [URL] = [],
         selectedRecordedFile: URL? = nil
    ) {
        self.isDisplayRemoveVoiceRecorderAlert = isDisplayRemoveVoiceRecorderAlert
        self.isDisplayAlert = isDisplayAlert
        self.alertMessage = alertMessage
        self.isRecording = isRecording
        self.isPlaying = isPlaying
        self.isPaused = isPaused
        self.playedTime = playedTime
        self.recordedFiles = recordedFiles
        self.selectedRecordedFile = selectedRecordedFile
    }
}

extension VoiceRecorderViewModel {
    func voiceRecordCellTapped(_ recordedFile: URL) {
        if selectedRecordedFile != recordedFile {
            stopPlaying()
            selectedRecordedFile = recordedFile
        }
    }
    
    func removeBtnTapped() {
        setIsDisplayRemoveVoiceRecorderAlert(true)
    }
    
    func removeSelectedVoiceRecord() {
        guard let fileToRemove = selectedRecordedFile,
              let indexToRemove = recordedFiles.firstIndex(of: fileToRemove) else {
            displayAlert(message: "선택된 음성메모 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: fileToRemove)
            recordedFiles.remove(at: indexToRemove)
            selectedRecordedFile = nil
            stopPlaying()
            displayAlert(message: "선택된 음성메모 파일을 성공적으로 삭제했습니다.")
        } catch {
            displayAlert(message: "선택된 음성메모 파일 삭제 중 오류가 발생했습니다.")
        }
    }
    
    private func setIsDisplayRemoveVoiceRecorderAlert(_ isDisplay: Bool) {
        isDisplayRemoveVoiceRecorderAlert = isDisplay
    }
    
    private func setErrorAlertMessage(_ message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
        }
    }
    
    private func setIsDisplayErrorAlert(_ isDisplay: Bool) {
        DispatchQueue.main.async {
            self.isDisplayAlert = isDisplay
        }
    }
    
    private func displayAlert(message: String) {
        setErrorAlertMessage(message)
        setIsDisplayErrorAlert(true)
    }
}

// MARK: - 음성메모 녹음 관련
extension VoiceRecorderViewModel {
    func recordBtnTapped() {
        selectedRecordedFile = nil
        
        if isPlaying {
            stopPlaying()
            startRecording()
        } else if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let fileURL = getDocumentDirectory().appendingPathComponent("새로운 녹음 \(recordedFiles.count + 1)")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000, // 샘플링 되는 비율. 어떻게 샘플링 비율을 가져갈 것인지 설정해주는 것. 이건 기본적으로 많이 사용되는 설정값
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.record) // 새로 추가
            try AVAudioSession.sharedInstance().setActive(true) // 새로 추가
            self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            if self.audioRecorder!.prepareToRecord() {
                self.audioRecorder?.record()
                self.isRecording = true
            } else {
                print("녹음 실패")
            }
        } catch {
            displayAlert(message: "음성메모 녹음 중 오류가 발생했습니다.")
        }
        
        
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        self.recordedFiles.append(self.audioRecorder!.url)
        print("appended url: \(self.audioRecorder!.url)")
        self.isRecording = false
    }
    
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

// MARK: - 음성메모 재생 관련
extension VoiceRecorderViewModel {
    func startPlaying(recordingURL: URL) {
        do {
            print("input url: \(recordingURL)")
            try AVAudioSession.sharedInstance().setCategory(.playback) // 새로 추가
            try AVAudioSession.sharedInstance().setActive(true) // 새로 추가
            audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            audioPlayer!.delegate = self
            if audioPlayer!.prepareToPlay() {
                print("start playing")
                audioPlayer!.play()
                self.isPlaying = true
                self.isPaused = false
                self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    self.updateCurrentTime()
                }
            } else {
                print("Not prepared audio")
            }
            
        } catch {
            print("****")
            displayAlert(message: "음성메모 재생 중 오류가 발생했습니다.")
        }
    }
    
    private func updateCurrentTime() {
        self.playedTime = audioPlayer?.currentTime ?? 0
    }
    
    private func stopPlaying() {
        audioPlayer?.stop()
        playedTime = 0
        self.progressTimer?.invalidate()
        self.isPlaying = false
        self.isPaused = false
    }
    
    func pausePlaying() {
        audioPlayer?.pause()
        self.isPaused = true
    }
    
    func resumePlaying() {
        audioPlayer?.play()
        self.isPaused = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { // playing이 끝났을 떄 실행되는 delegate 함수
        self.isPlaying = false
        self.isPaused = false
    }
    
    func getFileInfo(for url: URL) -> (Date?, TimeInterval?) {
        let fileManager = FileManager.default
        var creationDate: Date?
        var duration: TimeInterval?
        
        do {
            let fileAttributes = try fileManager.attributesOfItem(atPath: url.path)
            creationDate = fileAttributes[.creationDate] as? Date
        } catch {
            displayAlert(message: "선택된 음성메모 파일 정보를 불러올 수 없습니다.")
        }
        
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer.duration
        } catch {
            displayAlert(message: "선택된 음성메모 파일의 재생 시간을 불러올 수 없습니다.")
        }
        
        return (creationDate, duration)
    }
}

extension VoiceRecorderViewModel {
    private func enableBuiltInMic() {
        // Get the shared audio session.
        let session = AVAudioSession.sharedInstance()
        
        // Find the built-in microphone input.
        guard let availableInputs = session.availableInputs,
              let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            print("The device must have a built-in microphone.")
            return
        }
        
        // Make the built-in microphone input the preferred input.
        do {
            try session.setPreferredInput(builtInMicInput)
        } catch {
            print("Unable to set the built-in mic as the preferred input.")
        }
    }
}
