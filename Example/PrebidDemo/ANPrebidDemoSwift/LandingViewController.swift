//
//  LandingViewController.swift
//  ANPrebidDemoSwift
//
//  Created by Punnaghai Puviarasu on 8/27/20.
//  Copyright © 2020 Prebid. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    let cellReuseIdentifier = "cell"
    
    let adUnits: [String] = ["Banner", "Interstitial", "Banner - Native", "Banner - Video", "Rewarded Video"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        segmentedControl.selectedSegmentIndex = 1;
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.adUnits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        
        // set the text from the data model
        cell.textLabel?.text = self.adUnits[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == adUnits.count-1){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "rewardedView") as! RewardedVideoController
            if(segmentedControl.selectedSegmentIndex == 0){
                nextViewController.adServerName = "DFP"
            }
            else {
                nextViewController.adServerName = "MoPub"
            }
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
