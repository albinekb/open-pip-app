//
//  ViewController.swift
//  open-pip
//
//  Created by Albin Ekblom on 2017-03-29.
//  Copyright © 2017 Albin Ekblom. All rights reserved.
//


import Cocoa
import AVFoundation
import AVKit
import AppKit

func setTimeout(delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
}

func fileExists (filePath: String) -> Bool {
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: filePath)
}

func padLeft (str: String) -> String {
    if str.characters.count == 1 {
        return "0\(str)"
    }
    return str
}

func formatTimecode (time: CMTime) -> String {
    let millisecondTimescale: CMTimeScale = 1000
    var finalTime: CMTimeValue!
    
    if time.timescale != millisecondTimescale {
        finalTime = CMTimeConvertScale(time, millisecondTimescale, .roundTowardZero).value
    } else {
        finalTime = time.value
    }
    
    let totalMS = finalTime as CMTimeValue
    let ms = (totalMS % 1000) as CMTimeValue
    let total_seconds = (totalMS - ms) / 1000;
    let seconds = total_seconds % 60
    let total_minutes = (total_seconds - seconds) / 60
    let minutes = total_minutes % 60
    let hours = (total_minutes - minutes) / 60
    
    let hoursString = padLeft(str: "\(hours)")
    let minutesString = padLeft(str: "\(minutes)")
    let secondsString = padLeft(str: "\(seconds)")
    
    
    return "\(hoursString):\(minutesString):\(secondsString)"
}


class ViewController: NSViewController {
    @IBOutlet weak var playerView: AVPlayerView!
    let player = AVPlayer()
    var window: NSWindow?
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let popover = NSPopover()
    
    let errorFilePath = "\(Bundle.main.bundlePath)/error.log"
    
    lazy var pip: PIPViewController! = {
        let pip = PIPViewController()!
        pip.delegate = self
        pip.aspectRatio = CGSize(width: 16, height: 9)
        pip.userCanResize = false
        
        pip.replacementWindow = self.view.window
        pip.replacementRect = self.view.bounds
        
        return pip
    }()

    var pipIsActive = false
    var currentUrl: URL!
    var currentItem: AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.isHidden = true
        playerView.player = player
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                let frame = self.player.currentItem?.currentTime() as CMTime!
                self.statusItem.button?.title = formatTimecode(time: frame!)
            }
        }
        
        statusItem.button?.title = "IMBA"
    }
    
    override func viewDidDisappear() {
        if playerView.isHidden {
            exit(0)
        }
    }
    
    let cleanInput = (CommandLine.arguments[1] as String).replacingOccurrences(of: "\"", with: "") as String
    
    override func viewDidAppear() {
        if playerView.isHidden {
            playerView.isHidden = false
            openPIP()
        } else {
            print(cleanInput)
            
            if fileExists(filePath: cleanInput) {
                currentUrl = URL(fileURLWithPath: cleanInput)
            } else {
                currentUrl = URL(string: cleanInput)
            }
            
            currentItem = AVPlayerItem(url: currentUrl)
            
            currentItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
            
            
            
            player.replaceCurrentItem(with: currentItem)
            pip.replacementWindow.orderOut(self)
            player.play()
            pip.setPlaying(true)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != "status" {
            return
        }
        if player.currentItem?.status == AVPlayerItemStatus.failed {
            do {
                try "error: \(cleanInput)".write(toFile: errorFilePath, atomically: true, encoding: String.Encoding.utf8)
                print("wrote error.log")
            }
            catch {
                print("error writing error.log")
            }
            
            exit(EXIT_FAILURE)
        } else {
            currentItem.removeObserver(self, forKeyPath: "status", context: nil)
        }
    }
    
    func doCoolStuff () {
        print("WOW")
    }
    
  
    func openPIP() {
        if !pipIsActive {
            pip.presentAsPicture(inPicture: self)
            pipIsActive = true
        }
    }
    
}

// MARK: - PIPViewControllerDelegate

extension ViewController: PIPViewControllerDelegate {
    func pipDidClose(_ pip: PIPViewController!) {
        print("Panel closed")
        exit(0)
    }
    
    func pipActionStop(_ pip: PIPViewController!) {
        print("Stopped")
    }
    
    func pipActionPlay(_ pip: PIPViewController!) {
        player.play()
    }
    
    func pipActionPause(_ pip: PIPViewController!) {
        player.pause()
    }
    
}


