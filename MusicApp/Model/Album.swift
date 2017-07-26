//
//  Album.swift
//  MusicApp
//
//  Created by Alaxabo on 6/28/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import Foundation

class Album{
    var title: String
    var artist: String
    var artwork: Data!

    var albumSongs = [Song]()
    init(title: String, artist: String, artwork: Data){
        self.title = title
        self.artist = artist
        self.artwork = artwork
    }
    func appendSong(song: Song){
        self.albumSongs.append(song)
    }
}
