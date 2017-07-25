//
//  AlbumDetailViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 7/18/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit

class AlbumDetailViewController: UIViewController {

    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumArtist: UILabel!
    
    @IBOutlet weak var playingSongName: UILabel!
    @IBOutlet weak var playingArtist: UILabel!
    @IBOutlet weak var playingArtwork: UIImageView!
    @IBOutlet weak var playingProgress: UISlider!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedAlbum: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumArtist.text = selectedAlbum?.artist
        albumTitle.text = selectedAlbum?.title
        albumArtwork.image = UIImage(data: (selectedAlbum?.artwork)!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func play(_ sender: Any) {
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AlbumDetailViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedAlbum?.albumSongs.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SongTableCell
        
        cell.titleLabel?.text = selectedAlbum?.albumSongs[indexPath.row].title
        cell.artistLabel?.text = selectedAlbum?.albumSongs[indexPath.row].artist
        cell.artworkImage?.image = UIImage(data: (selectedAlbum?.albumSongs[indexPath.row].artWork!)!)
        return cell
        
    }
}

extension AlbumDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: false)
        Shared.shared.currentPlaying = selectedAlbum?.albumSongs[indexPath.row]
        Shared.shared.addSongToPlayList()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: nil)

    }
}

