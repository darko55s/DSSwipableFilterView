//
//  ViewController.swift
//  DSSwipableFilterView
//
//  Created by Darko Spasovski on 11/4/17.
//  Copyright © 2017 Darko Spasovski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var examples = ["Live camera filtering example","Media library example"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Example"
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell")
        cell?.textLabel?.text = examples[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            performSegue(withIdentifier: "liveCameraSegue", sender: nil)
        }else if indexPath.row == 1 {
            performSegue(withIdentifier: "gallerySegue", sender: nil)
        }
    }
}

