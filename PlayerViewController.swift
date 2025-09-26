//
//  PlayerViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 08/08/25.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var totaltimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var audioURL: URL?
    var audioPlayer: AVAudioPlayer?
    var progressTimer: Timer?
    var totalsTime: String?
    var nameLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = nameLabel
        slider.value = 0
        timeLabel.text = formatTime(0)
        totaltimeLabel.text = totalsTime
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            slider.value = 0
        }
        timeLabel.text = formatTime(0)
    }
    
                        
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sliderButton(_ sender: UISlider) {
        
        audioPlayer?.currentTime = TimeInterval(sender.value)
        timeLabel.text = formatTime(TimeInterval(sender.value))
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        playAudio()
    }
    
    func playAudio() {
        guard let url = audioURL else {
            print("No original audio URL available")
            return
        }
        
        // Initialize player if not already
        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.delegate = self  // ✅ To detect when audio finishes
                slider.maximumValue = Float(audioPlayer?.duration ?? 0)
                totaltimeLabel.text = formatTime(audioPlayer?.duration ?? 0)
                print("Player initialized")
            } catch {
                print("Failed to initialize player: \(error)")
                return
            }
        }
        
        guard let audioPlayer = audioPlayer else { return }
        
        if audioPlayer.isPlaying {
            // Pause audio
            playBtn.setImage(UIImage(named: "play"), for: .normal)
            audioPlayer.pause()
            progressTimer?.invalidate()
            print("Paused at time: \(audioPlayer.currentTime)")
        } else {
            // If finished before, restart from beginning
            if audioPlayer.currentTime >= audioPlayer.duration {
                audioPlayer.currentTime = 0
                slider.value = 0
                timeLabel.text = formatTime(0)
            }
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            audioPlayer.play()
            startProgressTimer()
            print("Playing from time: \(audioPlayer.currentTime)")
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0 , repeats: true) { _ in
            guard let player = self.audioPlayer else { return }
            self.slider.value = Float(player.currentTime)
            self.timeLabel.text = self.formatTime(player.currentTime)
        }
    }
    
}

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer?.invalidate()
        slider.value = 0
        timeLabel.text = formatTime(0)
        
        // Reset button to "play" after finishing
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        print("Audio finished")
    }
}

