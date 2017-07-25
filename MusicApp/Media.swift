//
//  Media.swift
//  MusicApp
//
//  Created by Alaxabo on 7/20/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class Shared {
    static let shared = Shared() //lazy init, and it only runs once
    
    var reapeatValue: Bool! = false
    var shufferValue: Bool! = false
    var editValue: Bool! = false
    
    var playList = [Song]()
    var currentPlaying: Song?
    var audioPlayer = AVAudioPlayer()
    var timer:Timer!
    
    
    func playSong(){
        Shared.shared.audioPlayer.play()
        updateInfoMPNowPlaying()
    }
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    func updateInfoMPNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentPlaying?.title,
            MPMediaItemPropertyArtist: currentPlaying?.artist,
            MPMediaItemPropertyAlbumTitle: currentPlaying?.album,
            MPMediaItemPropertyPlaybackDuration: Shared.shared.audioPlayer.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: Shared.shared.audioPlayer.currentTime,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: UIImage(data: (currentPlaying?.artWork)!)!),
            MPNowPlayingInfoPropertyPlaybackRate: Shared.shared.audioPlayer.isPlaying ? 1 : 0
        ]
    }
    func addSongToPlayList(){
        var check = 0
        for i in playList{
            if i.title == currentPlaying?.title{
                check = 1
            }
        }
        if check == 0{
            playList.append(currentPlaying!)
        }
    }

}

