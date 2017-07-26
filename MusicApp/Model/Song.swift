//
//  Song.swift
//  MusicApp
//
//  Created by Alaxabo on 6/21/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import Foundation
class Song{
    var title: String
    var artist: String
    var album: String
    var artWork: Data!
    init(title: String, artist: String, album: String, artWork: Data?){
        self.title = title
        self.artist = artist
        self.album = album
        self.artWork = artWork
    }
}
