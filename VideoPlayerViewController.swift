//
//  VideoPlayerViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 11/08/25.
//

import UIKit
import Foundation
import AVFoundation


class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var totalTimeLabel: UILabel!
    var videoURLs: URL!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var videoTimer: Timer?
    var progressTimer: Timer?
    var isVideoPlaying = false
    var videolabel: String?
    var totallabel : String?
    var thumbnailImages: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.value = 0
        label.text = videolabel
        totalTimeLabel.text = totallabel
        imageView.image = thumbnailImages
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.pause()
        player?.replaceCurrentItem(with: nil) // completely unloads the video
        player = nil
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playNoiseButton(_ sender: UIButton) {
        
        if isVideoPlaying == true {
            playBtn.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
            isVideoPlaying = false
            videoTimer?.invalidate()
            print("Video paused at: \(player?.currentTime().seconds ?? 0)")
        } else {
            // Resume or start playback
            if player == nil {
                setupVideoPlayer()
            }
            if let current = player?.currentTime(),
               let duration = player?.currentItem?.duration,
               CMTimeCompare(current, duration) >= 0 {
                player?.seek(to: .zero)
                slider.value = 0
                timeLabel.text = formatTime(0)
            }
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            player?.play()
            isVideoPlaying = true
            startProgressTimer()
            print("Video playing from: \(player?.currentTime().seconds ?? 0)")
        }
        
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        let seconds = Double(sender.value)
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        
        player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            if self.isVideoPlaying {
                self.player?.play()
            }
        }
    }
    
    
    func setupVideoPlayer() {
        guard let url = videoURLs else {
            print("No original video URL available")
            return
        }

        playerLayer?.removeFromSuperlayer()
        player = AVPlayer(url: url)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = uiView.bounds
        playerLayer?.videoGravity = .resizeAspect

        if let layer = playerLayer {
            uiView.layer.addSublayer(layer)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        // Get video duration (once ready)
        player?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                guard let duration = self.player?.currentItem?.duration else { return }
                let seconds = CMTimeGetSeconds(duration)
                
                if seconds.isFinite && !seconds.isNaN {
                    self.slider.maximumValue = Float(seconds)
                    self.totalTimeLabel.text = self.formatTime(seconds)
                } else {
                    print("Invalid video duration (nan or infinite)")
                    self.slider.maximumValue = 0
                    self.totalTimeLabel.text = self.formatTime(0)
                }
            }
        }

    }

        
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let player = self.player else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            if currentTime.isFinite && !currentTime.isNaN {
                self.slider.value = Float(currentTime)
                self.timeLabel.text = self.formatTime(currentTime)
            }
        }
    }

    @objc func videoDidFinishPlaying() {
        progressTimer?.invalidate()
        isVideoPlaying = false
        
        // Reset slider & labels
        slider.value = 0
        timeLabel.text = formatTime(0)
        
        // Reset play button
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        
        print("Video finished and reset to start")
    }
}
