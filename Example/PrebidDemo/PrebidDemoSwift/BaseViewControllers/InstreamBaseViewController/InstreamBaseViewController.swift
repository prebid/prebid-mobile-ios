/*   Copyright 2019-2022 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

fileprivate let instreamBaseViewControllerNibName = "InstreamBaseViewController"

/// Base controller for video in-stream integration cases, provides instream view and play button
class InstreamBaseViewController: UIViewController {

    @IBOutlet weak var instreamView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var adSize = CGSize(width: 300, height: 250)
    
    convenience init(adSize: CGSize) {
        self.init(nibName: instreamBaseViewControllerNibName, bundle: nil)
        self.adSize = adSize
    }
    
    convenience init() {
        self.init(nibName: instreamBaseViewControllerNibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        
        instreamView.constraints.first { $0.firstAttribute == .width }?.constant = adSize.width
        instreamView.constraints.first { $0.firstAttribute == .height }?.constant = adSize.height
    }
    
    @IBAction func onPlayButtonPressed(_ sender: AnyObject) {}
}
