////
////  AudioRecordingViewController.swift
////  AffirmationApp
////
////  Created by PGNV on 02/08/25.
////


import UIKit
import AVFoundation

class AudioRecordingViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    var timer: Timer?
    var recordingTime: TimeInterval = 0
    var isRecording = false
    var tempUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = "00:00:00"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioRecorder?.stop()
        stopTimer()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Record Button
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        checkMicroPhoneAccess {
            if !self.isRecording {
                self.startRecording()
            } else {
                self.stopRecording()
            }
        }
    }
    
    // MARK: - Recording Functions
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setPreferredSampleRate(44100)
            try audioSession.setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
            return
        }
        
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tempRecording.m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileUrl, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            recordingTime = 0
            startTimer()
            recordButton.setImage(UIImage(named: "Pause"), for: .normal)
        } catch {
            print("Audio recorder error: \(error.localizedDescription)")
        }
    }
    
    var duration: String = ""
    func stopRecording() {
        audioRecorder?.stop()
        duration = timeLabel.text!
        print(duration as Any)
        isRecording = false
        stopTimer()
        recordButton.setImage(UIImage(named: "Play"), for: .normal)
        timeLabel.text = formatTime(0)
        
        if let url = audioRecorder?.url {
            tempUrl = url
            print("Recording saved at: \(url)")
            removeNoise(URL :tempUrl!)
        }
    }
    
    // MARK: - Timer
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.recordingTime += 1
            self.timeLabel.text = self.formatTime(self.recordingTime)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let hrs = Int(time) / 3600
        let mins = (Int(time) / 60) % 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
    
    // MARK: - Permission
    func checkMicroPhoneAccess(completion: @escaping () -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion()
        case .denied:
            showPermissionAlert()
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    granted ? completion() : self.showPermissionAlert()
                }
            }
        @unknown default:
            break
        }
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Access Needed",
            message: "Please enable microphone access in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:])
            }
        })
        present(alert, animated: true)
    }
    
    func removeNoise(URL: URL){
        
        let removeNoiseAlert = UIAlertController(title: "Removing Noise", message:"Want To Remove Noise?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let Ok = UIAlertAction(title: "Ok", style: .default) { _ in
            let audioVC = self.storyboard?.instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController
            audioVC.mainUrl = URL
            audioVC.audioName1 = "Recording"
            audioVC.totalsTime = self.duration
            self.navigationController?.pushViewController(audioVC, animated: true)
        }
        
        removeNoiseAlert.addAction(cancel)
        removeNoiseAlert.addAction(Ok)
        present(removeNoiseAlert, animated: true)
        
    }
}
