//
//  ViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 04/08/25.
//

//  ViewController.swift
//  AffirmationApp
//
//  Created by PGNV on 02/08/25.
//

import UIKit
import UniformTypeIdentifiers
import Alamofire
import AVFoundation
import SwiftyJSON
import GoogleMobileAds
import Google_Mobile_Ads_SDK

class ViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate/*, BannerViewDelegate, FullScreenContentDelegate, AdLoaderDelegate*/{
    
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var proBtn: UIButton!
    @IBOutlet weak var selectAudBtn: UIButton!
    @IBOutlet weak var selectVidBtn: UIButton!
    @IBOutlet weak var recordAudBtn: UIButton!
//    @IBOutlet weak var adView: UIView!


    var filename: String? = nil
    var thumbnailImage: UIImage?
    var durationString: String = ""
    var count = 0
//    var interstitial: InterstitialAd?
//    private var adLoader: AdLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadInterstitial()
/*        loadNativeAd()*/ // Native Ads
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        loadNativeAd()
    }
    
    @IBAction func settingButton(_ sender: UIButton) {
        let settingVC = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @IBAction func proButton(_ sender: UIButton) {
        let proVC = storyboard?.instantiateViewController(withIdentifier: "SubscribeViewController") as! SubscribeViewController
        self.navigationController?.pushViewController(proVC, animated: true)
    }
    
    // Audio Button Action and document picker function
    
    @IBAction func audioButton(_ sender: UIButton) {
        presentAudioPicker()
    }
    
    func presentAudioPicker() {
        let types : [String] = ["public.audio"]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types.map { UTType($0)! } , asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let selectedURL = urls.first else { return }
//        filename = selectedURL.lastPathComponent
//        print("Selected audio file: \(selectedURL)")
//        let totalduration = selectedURL
//        let asset = AVAsset(url: totalduration)
//        let duration = CMTimeGetSeconds(asset.duration)
//        durationString =  formatTime(from: duration)
//        let audioVC = storyboard?.instantiateViewController(withIdentifier: "AudioViewController") as? AudioViewController
//        audioVC!.audioName1 = filename
//        audioVC!.mainUrl = selectedURL
//        audioVC!.totalsTime = durationString
//        self.navigationController?.pushViewController(audioVC!, animated: true)
//    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        filename = selectedURL.lastPathComponent
        print("Selected audio file: \(selectedURL)")
        let allowedExtensions = ["amr","asf","flac","flv","m4a","mp3","mpeg","mpg","ogg","wav","webm","wma","wmv"]
        let fileExtension = selectedURL.pathExtension.lowercased()
        if allowedExtensions.contains(fileExtension) {
            // Supported file → proceed
            let asset = AVAsset(url: selectedURL)
            let duration = CMTimeGetSeconds(asset.duration)
            durationString = formatTime(from: duration)

            let audioVC = storyboard?.instantiateViewController(withIdentifier: "AudioViewController") as? AudioViewController
            audioVC?.audioName1 = filename
            audioVC?.mainUrl = selectedURL
            audioVC?.totalsTime = durationString
            self.navigationController?.pushViewController(audioVC!, animated: true)
        } else {
            let alert = UIAlertController(
                title: "Unsupported Format",
                message: "This audio format (\(fileExtension)) is not supported. Please select a supported file.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    
    // Video button action and mediapicker function cj=hecking audio function
    
    @IBAction func videoButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.mediaTypes = [UTType.movie.identifier]
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedURL: URL = info[.mediaURL] as? URL else { return }
        filename = selectedURL.lastPathComponent
        print("Selected Video File \(selectedURL)")
        picker.dismiss(animated: true, completion: nil)
        
        let asset = AVAsset(url: selectedURL)
        let hasAudio = asset.tracks(withMediaType: .audio).count > 0
                    
        if hasAudio {
            print("Video has audio ")
        } else {
            print("No audio in this video ")
            let alert = UIAlertController(title: "Invalid Video",
                                          message: "This video does not contain audio.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        if let videoURL = info[.mediaURL] as? URL {
                    thumbnailImage = generateThumbnail(for: videoURL)
                }
        if let totalduration = info[.mediaURL] as? URL {
            let asset = AVAsset(url: totalduration)
            let duration = CMTimeGetSeconds(asset.duration)
            durationString =  formatTime(from: duration)
        }
        let videoVC = storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController
        videoVC!.videoName = filename
        videoVC!.videoUrl = selectedURL
        videoVC!.thumbnails = thumbnailImage
        videoVC!.totalsTime = self.durationString
        self.navigationController?.pushViewController(videoVC!, animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func generateThumbnail(for url: URL) -> UIImage? {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true // correct orientation

            let time = CMTime(seconds: 1, preferredTimescale: 600) // capture at 1s
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                return UIImage(cgImage: cgImage)
            } catch {
                print("Error generating thumbnail: \(error)")
                return nil
            }
        }
    
//     Record Button action and its function
    
    @IBAction func recordButton(_ sender: UIButton) {
        if let audioVC = storyboard?.instantiateViewController(withIdentifier: "AudioRecordingViewController") as? AudioRecordingViewController {
            navigationController?.pushViewController(audioVC, animated: true)
        } else {
            print("Could not find view controller with identifier 'AudioRecordingViewController'")
        }
    }
    
    func formatTime(from seconds: Double) -> String {
            let hrs = Int(seconds) / 3600
            let mins = (Int(seconds) % 3600) / 60
            let secs = Int(seconds) % 60

            if hrs > 0 {
                return String(format: "%02d:%02d:%02d", hrs, mins, secs)
            } else {
                return String(format: "%02d:%02d", mins, secs)
            }
        }

// Ads Function
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
    
//    private func loadNativeAd() {
//        
//        let adUnitID = "ca-app-pub-3940256099942544/3986624511"
//
//        adLoader = AdLoader(
//                adUnitID: adUnitID,
//                rootViewController: self,
//                adTypes: [.native],
//                options: nil
//            )
//            adLoader.delegate = self
//        adLoader.load(Request())
//        }
//
//    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
//        print("Failed to load native ad: \(error.localizedDescription)")
//    }

}

//extension ViewController {
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

//extension ViewController: NativeAdLoaderDelegate {
//    
//    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
//        print("Native ad loaded")
//
//        // Load your custom NativeAdView from XIB
//        guard let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
//              let nativeAdView = nibObjects.first as? NativeAdView else {
//            return
//        }
//
//        nativeAdView.nativeAd = nativeAd
//        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
//        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
//        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
//        (nativeAdView.mediaView)?.mediaContent = nativeAd.mediaContent
//
//        // Add to main screen
//        adView.addSubview(nativeAdView)
//        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            nativeAdView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
//            nativeAdView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
//            nativeAdView.topAnchor.constraint(equalTo: adView.topAnchor),
//            nativeAdView.bottomAnchor.constraint(equalTo: adView.bottomAnchor)
//        ])
//    }
//
//}


//    @IBAction func myFilesButton(_ sender: UIButton) {
//        MyFileViewController()
//    }
    
//    var bannerView: BannerView!

//    func MyFileViewController() { in class not in extension
//        if let interstitial = interstitial {
//            interstitial.present(from: self)
//            } else {
//                print("Ad wasn't ready")
//            }
//        let myCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "MyFileViewController") as! MyFileViewController
//        self.navigationController?.pushViewController(myCollectionVC, animated: true)
//    }

//    func AudioRecordViewController() {
//        if let interstitial = interstitial {
//            interstitial.present(from: self)
//            } else {
//                print("Ad wasn't ready")
//            }
//        let audioRecordVC = self.storyboard?.instantiateViewController(withIdentifier: "AudioRecordingViewController") as! AudioRecordingViewController
//        self.navigationController?.pushViewController(audioRecordVC, animated: true)
//    }

//bannerView = BannerView(adSize: AdSizeBanner) // "in viewdidload"
//bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174" // Your Ad Unit ID
//bannerView.rootViewController = self
//bannerView.delegate = self
//bannerView.load(Request())
//bannerView.translatesAutoresizingMaskIntoConstraints = false
//view.addSubview(bannerView)
//NSLayoutConstraint.activate([
//    bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//    bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//    bannerView.heightAnchor.constraint(equalToConstant: 30)
//])
//bannerAdView.addSubview(bannerView)
//bannerView.translatesAutoresizingMaskIntoConstraints = false
//NSLayoutConstraint.activate([
//    bannerView.leadingAnchor.constraint(equalTo: bannerAdView.leadingAnchor),
//    bannerView.trailingAnchor.constraint(equalTo: bannerAdView.trailingAnchor),
//    bannerView.topAnchor.constraint(equalTo: bannerAdView.topAnchor),
//    bannerView.bottomAnchor.constraint(equalTo: bannerAdView.bottomAnchor),
//    /*bannerView.heightAnchor.constraint(equalToConstant: 50)*/ // standard banner height
//])
