import UIKit
import Foundation
import AVFoundation

class MyFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var hideenView: UIView!
    @IBOutlet weak var hiddenImage: UIImageView!
    
    var audioFiles: [URL] = []
    var videoFiles: [URL] = []
    var selectedFiles: [URL] = []   // track selected checkboxes

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80

        shareBtn.isHidden = true
        deleteBtn.isHidden = true
        
        hideenView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFiles()
        tableView.reloadData()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        // clear selection when switching
        selectedFiles.removeAll()
        updateActionButtons()
        tableView.reloadData()
    }

    func loadFiles() {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil)
            audioFiles = allFiles.filter { $0.pathExtension.lowercased() == "mp3" || $0.pathExtension.lowercased() == "wav" }
            videoFiles = allFiles.filter { $0.pathExtension.lowercased() == "mp4" || $0.pathExtension.lowercased() == "mov" }
        } catch {
            print("Error loading files:", error)
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentController.selectedSegmentIndex {
        case 0:
            if audioFiles.count == 0 {
                hideenView.isHidden = false
                hiddenImage.image = UIImage(named: "no_Audio_Found")
            }else{
                hideenView.isHidden = true
            }
            return audioFiles.count
        case 1:
            if videoFiles.count == 0 {
                hideenView.isHidden = false
                hiddenImage.image = UIImage(named: "no_Video_Found")
            }else{
                hideenView.isHidden = true
            }
            return videoFiles.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyFileTableViewCell
        cell.selectionStyle = .none

        let fileURL = (segmentController.selectedSegmentIndex == 0) ? audioFiles[indexPath.row] : videoFiles[indexPath.row]
        cell.fileName.text = fileURL.lastPathComponent
        cell.iconImage.image = UIImage(named: segmentController.selectedSegmentIndex == 0 ? "Audio_icon" : "Video_icon")

        // Update checkbox state
        if selectedFiles.contains(fileURL) {
            cell.selectBtn.setImage(UIImage(named: "Select1"), for: .normal)
        } else {
            cell.selectBtn.setImage(UIImage(named: "Unselect1"), for: .normal)
        }

        // Handle checkbox tap
        cell.onSelectTapped = { [weak self] in
            guard let self = self else { return }
            if let index = self.selectedFiles.firstIndex(of: fileURL) {
                self.selectedFiles.remove(at: index)
            } else {
                self.selectedFiles.append(fileURL)
            }
            self.updateActionButtons()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }

    // MARK: - Handle Row Tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If user is in selection mode (checkboxes selected), ignore navigation
        if !selectedFiles.isEmpty { return }

        let fileURL = (segmentController.selectedSegmentIndex == 0) ? audioFiles[indexPath.row] : videoFiles[indexPath.row]

        if segmentController.selectedSegmentIndex == 0 {
            // Audio
            let playerVC = storyboard!.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            playerVC.audioURL = fileURL
            let asset = AVAsset(url: fileURL)
            playerVC.totalsTime = formatTime(from: CMTimeGetSeconds(asset.duration))
            playerVC.nameLabel = fileURL.lastPathComponent
            navigationController?.pushViewController(playerVC, animated: true)
        } else {
            // Video
            let playerVC = storyboard!.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
            playerVC.videoURLs = fileURL
            playerVC.videolabel = fileURL.lastPathComponent
            let asset = AVAsset(url: fileURL)
            playerVC.totallabel = formatTime(from: CMTimeGetSeconds(asset.duration))
            playerVC.thumbnailImages = generateThumbnail(for: fileURL)
            navigationController?.pushViewController(playerVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if segmentController.selectedSegmentIndex == 0 {
                let file = audioFiles[indexPath.row]
                try? FileManager.default.removeItem(at: file) // remove file from disk
                audioFiles.remove(at: indexPath.row)          // remove from array
            } else if segmentController.selectedSegmentIndex == 1 {
                let file = videoFiles[indexPath.row]
                try? FileManager.default.removeItem(at: file) // remove file from disk
                videoFiles.remove(at: indexPath.row)          // remove from array
            }

            // update table safely
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Action Buttons
    func updateActionButtons() {
        let hasSelection = !selectedFiles.isEmpty
        shareBtn.isHidden = !hasSelection
        deleteBtn.isHidden = !hasSelection
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        for file in selectedFiles {
            try? FileManager.default.removeItem(at: file)
        }
        selectedFiles.removeAll()
        loadFiles()
        tableView.reloadData()
        updateActionButtons()
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems: selectedFiles, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }

    // MARK: - Helpers
    func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
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
    @IBAction func backButton(_ sender: UIButton) {
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
