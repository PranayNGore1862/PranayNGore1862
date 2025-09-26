//
//  Video2ViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 06/08/25.
//

import UIKit
import AVFoundation

class Video2ViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet weak var videoTotalTimeLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var noiselessBtn: UIButton!
    @IBOutlet weak var originalBtn: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var videoNames: String?
    var originalVideoURLs: URL?
    var fileUrl: URL?   // noiseless
    var videoThumbnail: UIImage?
    var totalsTimes: String?
    
    var didtapSave: Bool = false
    var isVideoPlaying = false
    
    // players
    var nplayer: AVPlayer?
    var oplayer: AVPlayer?
    var currentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var progressTimer: Timer?
    
    var didTap: String = "noiseless" // default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoLabel.text = videoNames
        videoTotalTimeLabel.text = totalsTimes
        videoSlider.value = 0
        videoTimeLabel.text = formatTime(0)
        thumbnailImage.image = videoThumbnail
        setupPlayer(for: fileUrl, type: "noiseless")
        updateButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAndCleanup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds
    }

    
    // MARK: - Play Button
    @IBAction func playButton(_ sender: UIButton) {
        guard let player = currentPlayer else { return }
        
        if isVideoPlaying {
            // pause
            player.pause()
            isVideoPlaying = false
            playBtn.setImage(UIImage(named: "play"), for: .normal)
            progressTimer?.invalidate()
            print("Video paused")
        } else {
            // restart if already at end
            if let duration = player.currentItem?.duration,
               CMTimeCompare(player.currentTime(), duration) >= 0 {
                player.seek(to: .zero)
                videoSlider.value = 0
                videoTimeLabel.text = formatTime(0)
            }
            
            // play
            player.play()
            isVideoPlaying = true
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            startProgressTimer()
            print("Video playing")
        }
    }
    
    // MARK: - Slider
    @IBAction func sliderButton(_ sender: UISlider) {
        let seconds = Double(sender.value)
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        currentPlayer?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            if self.isVideoPlaying {
                self.currentPlayer?.play()
            }
        }
    }
    
    // MARK: - Switch buttons
    @IBAction func noiselessButton(_ sender: UIButton) {
        didTap = "noiseless"
        setupPlayer(for: fileUrl, type: "noiseless")
        updateButtons()
    }
    
    @IBAction func originalButton(_ sender: UIButton) {
        didTap = "original"
        setupPlayer(for: originalVideoURLs, type: "original")
        updateButtons()
    }
    
    // MARK: - Setup Player
    func setupPlayer(for url: URL?, type: String) {
        guard let url = url else {
            print("No URL available for \(type) video")
            return
        }
        
        stopAndCleanup()
        
        let player = AVPlayer(url: url)
        currentPlayer = player
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            videoView.layer.addSublayer(layer)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        // set duration
        player.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                let duration = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)
                if duration.isFinite && duration > 0 {
                    self.videoSlider.maximumValue = Float(duration)
                    self.videoTotalTimeLabel.text = self.formatTime(duration)
                }
            }
        }
        
        // reset UI
        videoSlider.value = 0
        videoTimeLabel.text = formatTime(0)
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        isVideoPlaying = false
    }
    
    func stopAndCleanup() {
        progressTimer?.invalidate()
        isVideoPlaying = false
        currentPlayer?.pause()
        currentPlayer = nil
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Timer & Finish
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let player = self.currentPlayer else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            self.videoSlider.value = Float(currentTime)
            self.videoTimeLabel.text = self.formatTime(currentTime)
        }
    }
    
    @objc func videoDidFinishPlaying() {
        progressTimer?.invalidate()
        isVideoPlaying = false
        videoSlider.value = 0
        videoTimeLabel.text = formatTime(0)
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        print("Video finished")
    }
    
    // MARK: - Helpers
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func updateButtons() {
        if didTap == "noiseless" {
            noiselessBtn.setImage(UIImage(named: "Noiseless_unpress"), for: .normal)
            originalBtn.setImage(UIImage(named: "Original_unpress"), for: .normal)
        } else {
            noiselessBtn.setImage(UIImage(named: "Noiseless_press"), for: .normal)
            originalBtn.setImage(UIImage(named: "Original_press"), for: .normal)
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        if didtapSave == false{
            let alert = UIAlertController(
                title: "Audio Not Saved",
                message: "Do you want to save your audio before leaving?",
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let save = UIAlertAction(title: "Save", style: .default) { _ in
                self.showSavePopup()
            }
            
            let leave = UIAlertAction(title: "Leave Without Saving", style: .destructive) { _ in
                if let navigationController = self.navigationController {
                    for viewController in navigationController.viewControllers {
                        if viewController is ViewController {
                            navigationController.popToViewController(viewController, animated: true)
                            return // Exit the function after popping
                        }
                    }
                }
            }
            
            alert.addAction(cancel)
            alert.addAction(save)
            alert.addAction(leave)
            present(alert, animated: true)
        } else if didtapSave == true{
            if let navController = self.navigationController {
                for controller in navController.viewControllers {
                    if controller is ViewController {
                        navController.popToViewController(controller, animated: true)
                        break
                    }
                }
            }
        }
    }
    // MARK: - Save
    @IBAction func saveButton(_ sender: Any) {
        didtapSave = true
        showSavePopup()
    }
    
    var name: String = ""
    func showSavePopup() {
        let alert = UIAlertController(title: "Save Audio", message: "Enter name and confirm to save", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Recording name"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.name = alert.textFields?.first?.text ?? "Recording"
            self.saveVideoFile(name: self.name)
            self.backtoVC()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        

        present(alert, animated: true)
    }
    
    func saveVideoFile(name : String) {
        didtapSave = true
        guard let tempFileUrl = fileUrl else {
            print("No audio to save")
            return
        }
        
        let fileManager = FileManager.default
        let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = docURL.appendingPathComponent("\(name).mp4")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: tempFileUrl, to: destinationURL)
            print("Video saved successfully!")

        } catch {
            print("Saving failed: \(error)")
            // Optional: Show error
            let alert = UIAlertController(title: "Error", message: "Failed to save audio: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func backtoVC(){
        if let navigationController = self.navigationController {
            for viewController in navigationController.viewControllers {
                if viewController is ViewController {
                    navigationController.popToViewController(viewController, animated: true)
                    return // Exit the function after popping
                }
            }
        }
    }
    
}
