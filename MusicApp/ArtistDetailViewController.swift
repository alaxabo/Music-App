//
//  ArtistDetailViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 7/18/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit

class ArtistDetailViewController: UIViewController {

    @IBOutlet weak var artistArtwork: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    
    var selectedArtist: Artist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistName.text = selectedArtist?.name
        artistArtwork.image = UIImage(data: (selectedArtist?.artwork)!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension ArtistDetailViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedArtist?.allSong.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SongTableCell
        
        cell.titleLabel?.text = selectedArtist?.allSong[indexPath.row].title
        cell.artistLabel?.text = selectedArtist?.allSong[indexPath.row].artist
        cell.artworkImage?.image = UIImage(data: (selectedArtist?.allSong[indexPath.row].artWork!)!)
        return cell
        
    }
}

extension ArtistDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: false)
        Shared.shared.currentPlaying = selectedArtist?.allSong[indexPath.row]
        Shared.shared.addSongToPlayList()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: nil)
        
    }

}

