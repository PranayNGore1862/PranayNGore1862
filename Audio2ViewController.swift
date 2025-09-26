//
//  Audio2ViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 05/08/25.
//

import UIKit
import Foundation
import AVFoundation

class Audio2ViewController: UIViewController {

    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var playbutton: UIButton!
    @IBOutlet weak var timestartbutton: UILabel!
    @IBOutlet weak var totaltimebutton: UILabel!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var noiselessbtn: UIButton!
    @IBOutlet weak var originalbtn: UIButton!
    
    var originalSong: URL?
    var fileUrl: URL?
    var oplayer: AVAudioPlayer?
    var nPlayer: AVAudioPlayer?
    var currentPlayer: AVAudioPlayer?
    var progressTimer: Timer?
    var audioName2: String?
    var didNTap: String = "" //optional
    var totalsTimes: String?
    var didtapSave: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label2.text = audioName2
        totaltimebutton.text = totalsTimes
        slider2.value = 0
        timestartbutton.text = formatTime(0)
        setupPlayers()
        setActivePlayer(nPlayer)   // ✅ default noiseless
        updateButtonUI(active: noiselessbtn, inactive: originalbtn)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if oplayer?.isPlaying == true || nPlayer?.isPlaying == true  {
            oplayer?.stop()
            nPlayer?.stop()
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

    
//    @IBAction func sliderAction(_ sender: UISlider) {
//        if didNTap == "noiseless" || didNTap == ""{
//            nPlayer?.currentTime = TimeInterval(sender.value)
//            timestartbutton.text = formatTime(TimeInterval(sender.value))
//        }
//        
//        oplayer?.currentTime = TimeInterval(sender.value)
//        timestartbutton.text = formatTime(TimeInterval(sender.value))
//    }
//    
//    
//    @IBAction func playButton(_ sender: Any) {
//        if didNTap == "original"{
//            oplayer?.currentTime = 0
//            originalAudioPlaying()
//        }else if didNTap == "noiseless"{
//            nPlayer?.currentTime = 0
//            playDefaultAudio()
//        }else{
//            playDefaultAudio()
//        }
//    }
    
//    @IBAction func noiselessButton(_ sender: UIButton) {
//        noiselessbtn.setImage(UIImage(named: "Noiseless_unpress"), for: .normal)
//        originalbtn.setImage(UIImage(named: "Original_unpress"), for: .normal)
//        didNTap = "noiseless"
//        oplayer?.stop()
//        slider2.value = 0
//        progressTimer?.invalidate()
//        noiselessbtn.backgroundColor = .gray
//        originalbtn.backgroundColor = .white
//        print("noiseless")
//    }
//    
//    @IBAction func originalButton(_ sender: UIButton) {
//        originalbtn.setImage(UIImage(named: "Original_press"), for: .normal)
//        noiselessbtn.setImage(UIImage(named: "Noiseless_press"), for: .normal)
//        nPlayer?.stop()
//        slider2.value = 0
//        progressTimer?.invalidate()
//        didNTap = "original"
//        originalbtn.backgroundColor = .gray
//        noiselessbtn.backgroundColor = .white
//        print("original")
//    }
    // new Code
    
    @IBAction func noiselessTapped(_ sender: UIButton) {
//        stopCurrent()
//        setActivePlayer(noiselessPlayer)
//        updateButtonUI(active: noiselessBtn, inactive: originalBtn)
        switchToPlayer(nPlayer, activeBtn: noiselessbtn, inactiveBtn: originalbtn)
    }

    @IBAction func originalTapped(_ sender: UIButton) {
//        stopCurrent()
//        setActivePlayer(originalPlayer)
//        updateButtonUI(active: originalBtn, inactive: noiselessBtn)
        switchToPlayer(oplayer, activeBtn: originalbtn, inactiveBtn: noiselessbtn)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let player = currentPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            playbutton.setImage(UIImage(named: "play"), for: .normal)
            progressTimer?.invalidate()
        } else {
            // if finished, restart from beginning
            if player.currentTime >= player.duration {
                player.currentTime = 0
                slider2.value = 0
                timestartbutton.text = formatTime(0)
            }
            player.play()
            playbutton.setImage(UIImage(named: "pause"), for: .normal)
            startProgressTimer()
        }
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        currentPlayer?.currentTime = TimeInterval(sender.value)
        timestartbutton.text = formatTime(TimeInterval(sender.value))
    }
    
    func switchToPlayer(_ newPlayer: AVAudioPlayer?, activeBtn: UIButton, inactiveBtn: UIButton) {
        // Stop only the currently playing one
        currentPlayer?.stop()
            currentPlayer?.currentTime = 0
            progressTimer?.invalidate()
            
            // Set new active player
            currentPlayer = newPlayer
            
            guard let player = currentPlayer else { return }
            player.currentTime = 0   // ✅ always start from zero
            slider2.maximumValue = Float(player.duration)
            slider2.value = 0
            timestartbutton.text = formatTime(0)
            totaltimebutton.text = formatTime(player.duration)
            
            // Update button UI
            updateButtonUI(active: activeBtn, inactive: inactiveBtn)
            
            // Reset play button to "play"
            playbutton.setImage(UIImage(named: "play"), for: .normal)
    }
    
    func setupPlayers() { // new func
        do {
            nPlayer = try AVAudioPlayer(contentsOf: fileUrl!)
            nPlayer?.prepareToPlay()
            nPlayer?.delegate = self
            
            oplayer = try AVAudioPlayer(contentsOf: originalSong!)
            oplayer?.prepareToPlay()
            oplayer?.delegate = self
        } catch {
            print("Error initializing players: \(error)")
        }
    }
    
    func setActivePlayer(_ player: AVAudioPlayer?) {
        currentPlayer = player
        guard let player = player else { return }
        slider2.maximumValue = Float(player.duration)
        totaltimebutton.text = formatTime(player.duration)
        timestartbutton.text = formatTime(player.currentTime)
    }

    func stopCurrent() {
        currentPlayer?.stop()
        currentPlayer?.currentTime = 0
        progressTimer?.invalidate()
        slider2.value = 0
        playbutton.setImage(UIImage(named: "play"), for: .normal)
    }

    func updateButtonUI(active: UIButton, inactive: UIButton) {
        active.backgroundColor = .black
        if active == noiselessbtn && inactive == originalbtn {
            active.setImage(UIImage(named: "Noiseless_unpress"), for: .normal)
            inactive.setImage(UIImage(named: "Original_unpress"), for: .normal)
        }
        inactive.backgroundColor = .black
        if active == originalbtn && inactive == noiselessbtn {
            inactive.setImage(UIImage(named: "Noiseless_press"), for: .normal)
            active.setImage(UIImage(named: "Original_press"), for: .normal)
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let player = self.currentPlayer else { return }
            self.slider2.value = Float(player.currentTime)
            self.timestartbutton.text = self.formatTime(player.currentTime)
        }
    }
        
        //start
//    func originalAudioPlaying(){
//        guard let url = originalSong else {
//            print(" No audio URL available")
//            return
//        }
//        print(url)
//        
//        if oplayer == nil {
//            do {
//                oplayer = try AVAudioPlayer(contentsOf: originalSong!)
//                oplayer?.prepareToPlay()
//                slider2.maximumValue = Float(oplayer?.duration ?? 0)
//                totaltimebutton.text = formatTime(oplayer?.duration ?? 0)
//                print("Player initialized")
//            } catch {
//                print("Failed to initialize player: \(error)")
//                return
//            }
//        }
//        
//        if oplayer?.isPlaying == true {
//            // Pause audio and stop updating UI
//            playbutton.setImage(UIImage(named: "play"), for: .normal)
//            oplayer?.pause()
//            progressTimer?.invalidate()
//            print("Paused at time: \(oplayer?.currentTime ?? 0)")
//        } else {
//            // Resume from currentTime (do NOT reinitialize)
//            playbutton.setImage(UIImage(named: "pause"), for: .normal)
//            oplayer?.play()
//            startProgressTimer()
//            print("Resumed playing from time: \(oplayer?.currentTime ?? 0)")
//        }
//    }
        
//    func playDefaultAudio() {
//        guard let url = fileUrl else {
//            print("No audio URL available")
//            return
//        }
//        
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            print("File not found at: \(url.path)")
//            return
//        }
//        
//        if nPlayer == nil {
//            do{
//                nPlayer = try AVAudioPlayer(contentsOf: url)
//                nPlayer?.prepareToPlay()
//                slider2.maximumValue = Float(nPlayer?.duration ?? 0)
//                totaltimebutton.text = formatTime(nPlayer?.duration ?? 0)
//                print("Player initialized")
//            }catch{
//                print("failed to initialize player")
//                return
//            }
//        }
//        
//        if nPlayer?.isPlaying == true {
//            // Pause audio and stop updating UI
//            nPlayer?.pause()
//            progressTimer?.invalidate()
//            print("Paused at time: \(nPlayer?.currentTime ?? 0)")
//        } else {
//            // Resume from currentTime (do NOT reinitialize)
//            nPlayer?.play()
//            startProgressTimer()
//            print("Resumed playing from time: \(nPlayer?.currentTime ?? 0)")
//        }
//    }
    
//    func formatTime(_ time: TimeInterval) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
    
//    func startProgressTimer() {
//        if didNTap == "original" {
//            progressTimer?.invalidate()
//            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5 , repeats: true) { _ in
//                guard let player = self.oplayer else { return }
//                self.slider2.value = Float(player.currentTime)
//                self.timestartbutton.text = self.formatTime(player.currentTime)
//            }
//        }
//        if didNTap == "noiseless" || didNTap == "" {
//            progressTimer?.invalidate()
//            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5 , repeats: true) { _ in
//                guard let player = self.nPlayer else { return }
//                self.slider2.value = Float(player.currentTime)
//                self.timestartbutton.text = self.formatTime(player.currentTime)
//            }
//        }
//    }
    
    // Save File Button Iboutlet and Function
    
    var name: String = ""
    
    @IBAction func saveButton(_ sender: UIButton) {
        showSavePopup()
    }
    
    func saveAudioFile(name : String) {
        didtapSave = true
        guard let tempFileUrl = fileUrl else {
            print("No audio to save")
            return
        }
        
        let fileManager = FileManager.default
        let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = docURL.appendingPathComponent("\(name).mp3")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: tempFileUrl, to: destinationURL)
            print("Audio saved successfully!")

        } catch {
            print("Saving failed: \(error)")
            // Optional: Show error
            let alert = UIAlertController(title: "Error", message: "Failed to save audio: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func showSavePopup() {
        let alert = UIAlertController(title: "Save Audio", message: "Enter name and confirm to save", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Recording name"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.name = alert.textFields?.first?.text ?? "Recording"
            self.saveAudioFile(name: self.name)
            self.backtoVC()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        

        present(alert, animated: true)
    }
    
    func backtoVC() {
        if let navigationController = self.navigationController {
            // 1. Iterate through the stack of view controllers
            for viewController in navigationController.viewControllers {
                
                // 2. Check if the current viewController in the loop is an instance of MyTargetViewController
                if viewController is ViewController {
                    
                    // 3. If found, pop to that specific instance and exit the loop
                    navigationController.popToViewController(viewController, animated: true)
                    return // Exit the function after popping
                }
            }
        }
    }
    
}

extension Audio2ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer?.invalidate()
        slider2.value = 0
        timestartbutton.text = formatTime(0)
        playbutton.setImage(UIImage(named: "play"), for: .normal)
    }
}
