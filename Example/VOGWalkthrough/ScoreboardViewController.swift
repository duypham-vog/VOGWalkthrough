//
//  ScoreboardViewController.swift
//  VOGWalkthrough_Example
//
//  Created by Duy Pham on 2019-11-21.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import VOGWalkthrough

class ScoreboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        VOGWalkthrough.shared.showStep(on: self, screenId: "Scoreboard")
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
