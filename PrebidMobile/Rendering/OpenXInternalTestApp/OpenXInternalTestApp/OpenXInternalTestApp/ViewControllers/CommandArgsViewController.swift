//
//  CommandArgsViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import UIKit

final class CommandArgsViewController: UITableViewController {
    
    let cmdArgs = Array(ProcessInfo.processInfo.arguments[1...])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Command line args"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cmdArgs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = cmdArgs[indexPath.row]
        return cell
    }
}
