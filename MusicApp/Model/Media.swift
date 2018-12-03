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
    var audioLength = 0.0
    var songs = [Song]()
    var albums = [Album]()
    var artists = [Artist]()
    
    
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
    func pauseSong(){
        Shared.shared.audioPlayer.pause()
        updateInfoMPNowPlaying()
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
    
    func nextSong(){
        var currentIndex = 0
        for i in 0 ..< Shared.shared.playList.count{
            if Shared.shared.currentPlaying?.title == Shared.shared.playList[i].title{
                currentIndex = i
            }
        }
        if ((currentIndex + 1) >= Shared.shared.playList.count){
            Shared.shared.currentPlaying = Shared.shared.playList[0]
        }
        else{
            Shared.shared.currentPlaying = Shared.shared.playList[currentIndex + 1]
        }
        do{
            let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
            try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch{
            print("ERROR")
        }
    }
    
    func prevSong(){
        var currentIndex = 0
        for i in 0 ..< Shared.shared.playList.count{
            if Shared.shared.currentPlaying?.title == Shared.shared.playList[i].title{
                currentIndex = i
            }
        }
        if ((currentIndex - 1) < 0){
            Shared.shared.currentPlaying = Shared.shared.playList[Shared.shared.playList.count - 1]
        }
        else{
            Shared.shared.currentPlaying = Shared.shared.playList[currentIndex - 1]
        }
        do{
            let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
            try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch{
            print("ERROR")
        }
    }
    
    //Return Song Length
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    func showTotalSongLength(){
        calculateSongLength()
        //totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        //        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }

    func getSongNames(){
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        var songTitle, songArtist, songAlbum: String!
        var songArtWork: Data!
        do
        {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for song in songPath
            {
                let mySong = song.absoluteString
                if mySong.contains(".mp3") || mySong.contains(".m4a")
                {   songArtWork = nil
                    songAlbum = nil
                    let avpltem = AVPlayerItem(url: song)
                    let commonMetadata = avpltem.asset.commonMetadata
                    for i in commonMetadata{
                        if convertFromOptionalAVMetadataKey(i.commonKey) == "title"{
                            songTitle = i.stringValue
                        }
                        if convertFromOptionalAVMetadataKey(i.commonKey) == "artist"{
                            songArtist = i.stringValue
                        }
                        if convertFromOptionalAVMetadataKey(i.commonKey) == "albumName"{
                            songAlbum = i.stringValue
                        }
                        if convertFromOptionalAVMetadataKey(i.commonKey) == "artwork"{
                            songArtWork = i.dataValue
                        }
                    }
                    if songTitle.isEmpty {
                        songTitle = "Unknow Song"
                    }
                    if songAlbum == nil || songAlbum == " " {
                        songAlbum = "Unknow Album"
                    }
                    songs.append(Song(title: songTitle, artist: songArtist ?? "Unknow Artist", album: songAlbum, artWork: songArtWork ?? UIImage(named: "default")!.pngData()!))
                }
                
            }
        }
        catch{
            print ("ERROR")
        }
    }
    // Get Album
    func getAlbums(){
        for i in songs{
            var checkAlbum = 0
            for album in albums{
                if (i.album == album.title){
                    checkAlbum = 1
                }
            }
            if (checkAlbum == 0){
                if i.artWork != nil{
                    albums.append(Album(title: i.album, artist: i.artist, artwork: i.artWork))
                }
                else{
                    let image = UIImage(named: "default")
                    let data:Data = image!.pngData()!
                    albums.append(Album(title: i.album, artist: i.artist, artwork: data))
                }
            }
        }
        
        //Add Song To Album
        for i in songs{
            for j in 0 ..< albums.count {
                if (i.album == albums[j].title){
                    albums[j].appendSong(song: i)
                }
            }
        }
    }
    // Get Artist
    func getArtist(){
        for i in songs{
            var checkArtist = 0
            for artist in artists{
                if (i.artist == artist.name){
                    checkArtist = 1
                }
            }
            if (checkArtist == 0){
                if i.artWork != nil{
                    artists.append(Artist(name: i.artist, artwork: i.artWork))
                }
                else{
                    let image = UIImage(named: "default")
                    let data:Data = image!.pngData()!
                    artists.append(Artist(name: i.artist, artwork: data))
                }
            }
        }
        for i in songs{
            for j in 0 ..< artists.count {
                if (i.artist == artists[j].name){
                    artists[j].appendSong(song: i)
                }
            }
        }
        for album in albums{
            for i in 0 ..< artists.count{
                if (album.artist == artists[i].name){
                    artists[i].appendAlbum(album: album)
                }
            }
        }
    }

    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalAVMetadataKey(_ input: AVMetadataKey?) -> String? {
	guard let input = input else { return nil }
	return input.rawValue
}
