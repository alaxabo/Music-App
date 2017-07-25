//
//  Artist.swift
//  MusicApp
//
//  Created by Alaxabo on 6/28/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import Foundation

class Artist{
    var name: String
    var artwork: Data
    var albumName = [Album]()
    var songName = [String]()
    var allSong = [Song]()
    init(name: String, artwork: Data){
        self.name = name
        self.artwork = artwork
    }
    func appendAlbum(album: Album){
        self.albumName.append(album)
    }
    func appendSong(song: Song){
        self.allSong.append(song)
    }
}
