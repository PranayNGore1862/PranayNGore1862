//
//  AudioViewController.swift
//  AffirmationApp
//
//  Created by PGNV on 02/08/25.

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import AVFoundation
import GoogleMobileAds

class AudioViewController: UIViewController, FullScreenContentDelegate {
    
    @IBOutlet weak var audioFileLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var totaltimeofAudio: UILabel!
    @IBOutlet weak var sliderBtn: UISlider!
    @IBOutlet weak var removeNoiseBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var gifImage: UIImageView!
    
    
    var player: AVAudioPlayer?
    var progressTimer: Timer?
    var didTap: Bool = false
    var audioName1: String?
    var fileId: String?
    var statusTimer: Timer?
    var mainUrl: URL?
    var totalsTime: String?
//    var interstitial: InterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        playBtn.setImage(UIImage(named: "play"), for: .normal)
        loaderView.isHidden = true
        audioFileLabel.text = audioName1
        totaltimeofAudio.text = totalsTime
        sliderBtn.value = 0
        timeStartLabel.text = formatTime(0)
//        loadInterstitial()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if player?.isPlaying == true {
            player?.stop()
            player?.currentTime = 0
            sliderBtn.value = 0
        }
        timeStartLabel.text = formatTime(0)
        loaderView.isHidden = true
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is ViewController {
                    navController.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
    @IBAction func sliderButton(_ sender: UISlider) {
        
        player?.currentTime = TimeInterval(sender.value)
        timeStartLabel.text = formatTime(TimeInterval(sender.value))
    }
    
    // this will playing any audio
    // MARK: - Play / Pause Button
    @IBAction func playOriginalAudioButton(_ sender: UIButton) {
        guard let url = mainUrl else {
            print("No original audio URL available")
            return
        }
        
        // Initialize player if not already
        if player == nil {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.delegate = self  // ✅ To detect when audio finishes
                sliderBtn.maximumValue = Float(player?.duration ?? 0)
                totaltimeofAudio.text = formatTime(player?.duration ?? 0)
                print("Player initialized")
            } catch {
                print("Failed to initialize player: \(error)")
                return
            }
        }
        
        guard let player = player else { return }
        
        if player.isPlaying {
            // Pause audio
            playBtn.setImage(UIImage(named: "play"), for: .normal)
            player.pause()
            progressTimer?.invalidate()
            print("Paused at time: \(player.currentTime)")
        } else {
            // If finished before, restart from beginning
            if player.currentTime >= player.duration {
                player.currentTime = 0
                sliderBtn.value = 0
                timeStartLabel.text = formatTime(0)
            }
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            player.play()
            startProgressTimer()
            print("Playing from time: \(player.currentTime)")
        }
    }

    
    @IBAction func removeNoiseButton(_ sender: UIButton) {
        uploadAudioUrl(selectedURL: mainUrl!)
        player?.stop()
        sliderBtn.value = 0
        loaderView.backgroundColor = .black
        gifImage.loadGif(name: "playing")
        loaderView.isHidden = false
//        if let interstitial = interstitial {
//            interstitial.present(from: self)
//        } else {
//            print("Ad wasn't ready")
//        }
//        if interstitial != nil {
//            gifImage.loadGif(name: "playing")
//            loaderView.isHidden = false
//        }
        UserDefaults.standard.set(1, forKey: "launchCount")
    }

    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5 , repeats: true) { _ in
            guard let player = self.player else { return }
            self.sliderBtn.value = Float(player.currentTime)
            self.timeStartLabel.text = self.formatTime(player.currentTime)
        }
    }
    
//    func loadInterstitial() {
//        let request = Request()
//        InterstitialAd.load(with: "ca-app-pub-3940256099942544/4411468910", request: request) { [self] ad, error in
//            if let error = error {
//                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                return
//            }
//            interstitial = ad
//            interstitial?.fullScreenContentDelegate = self
//            print("Interstitial ad loaded")
//        }
//    }

    func uploadAudioUrl(selectedURL: URL) {
        
        let uploadAudioUrl = "https://api.audo.ai/v1/upload"
        
        let headers: HTTPHeaders = [
            "x-api-key" : "38d7944b7c50539e0b144bbfafee20ff"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in multipartFormData.append(selectedURL, withName: "file")}, to: uploadAudioUrl, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("Upload JSON: \(json)")
                if let fileId = json["fileId"].string
                    {
                    self.fileId = fileId
                    self.removeAudioNoise()
                }
                
            case .failure(let error):
                print("file not uploaded \(error)")
            }
        }
    }
    
    
// this is remove noise button function these will go and play in audio2viewcontroller dont change it
    
    func removeAudioNoise() {
        
        guard let fileId = self.fileId else {
                print("Missing fieldId")
                return
            }
        
        let removeNoiseUrl = "https://api.audo.ai/v1/remove-noise"
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "x-api-key" : "38d7944b7c50539e0b144bbfafee20ff"
        ]
        
        let parameters: [String:Any] = [
            "input" : fileId,
            "outputExtension": "mp3",
            "noiseReductionAmount" : 100
        ]
        
        AF.request(removeNoiseUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("Response : \(json)")
                if let jobId = json["jobId"].string {
                    self.removeNoiseStatus(jobId: jobId)
                }else{
                    print("No job id found")
                }
            case .failure(let error):
                print("APi Remove-Noise Failed : \(error)")
            }
        }
    }
    
    
    
    func removeNoiseStatus(jobId: String) {
        let headers: HTTPHeaders = [
            "x-api-key": "38d7944b7c50539e0b144bbfafee20ff"
        ]
        
        let statusUrl = "https://api.audo.ai/v1/remove-noise/\(jobId)/status"
        
        statusTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            AF.request(statusUrl, method: .get, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("Status JSON: \(json)")

                    guard let state = json["state"].string else {
                        print("Missing state")
                        return
                    }

                    switch state {
                    case "queued":
                        if let jobsAhead = json["jobsAhead"].int {
                            print("Job queued. Jobs ahead: \(jobsAhead)")
                        }
                    case "in_progress":
                        if let percent = json["percent"].int {
                            print("In progress: \(percent)% done")
                        }
                    case "succeeded":
                        self.statusTimer?.invalidate()
                        self.statusTimer = nil
                        if let downloadPath = json["downloadPath"].string {
                            print("Succeeded. Download path: \(downloadPath)")
                            self.downloadProcessedAudio(downloadPath: downloadPath) // this line will be changed but  not now
                        }
                    case "failed":
                        self.statusTimer?.invalidate()
                        self.statusTimer = nil
                        if let reason = json["reason"].string {
                            print("Failed. Reason: \(reason)")
                        }
                    case "downloading":
                        print("Still downloading the input from URL...")
                    default:
                        print("Unknown state: \(state)")
                    }

                case .failure(let error):
                    print("Error checking status: \(error.localizedDescription)")
                }
            }
        }
    }

    
    func downloadProcessedAudio(downloadPath: String) {
        let fullUrl = "https://api.audo.ai/v1\(downloadPath)"
        
        AF.download(fullUrl).responseData { response in
            switch response.result {
            case .success(let data):
                print("Downloaded audio data")
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Pranay.mp3")
                do {
                    try data.write(to: tempURL)
                    print("Saved to: \(tempURL)")
                    let audio2VC = self.storyboard?.instantiateViewController(withIdentifier: "Audio2ViewController") as! Audio2ViewController
                    audio2VC.fileUrl = tempURL
                    audio2VC.audioName2 = self.audioName1
                    audio2VC.originalSong = self.mainUrl
                    audio2VC.totalsTimes = self.totalsTime
                    self.navigationController?.pushViewController(audio2VC, animated: true)
                } catch {
                    print("Error saving file: \(error)")
                }
            case .failure(let error):
                print("Download failed: \(error)")
            }
        }
    }
            
}

//extension AudioViewController {
//    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
//        print("Interstitial dismissed")
//        loadInterstitial() // Preload the next ad
//    }
//
//    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        print("Ad failed to present: \(error.localizedDescription)")
//    }
//
//    func adDidPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
//        print("Interstitial presented")
//    }
//}

extension AudioViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer?.invalidate()
        sliderBtn.value = 0
        timeStartLabel.text = formatTime(0)
        
        // Reset button to "play" after finishing
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        print("Audio finished")
    }
}
