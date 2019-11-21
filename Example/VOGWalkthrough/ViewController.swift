//
//  ViewController.swift
//  VOGWalkthrough
//
//  Created by duypham-vog on 11/21/2019.
//  Copyright (c) 2019 duypham-vog. All rights reserved.
//

import UIKit
import VOGWalkthrough

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var config = VOGWalkthroughConfig()
        config.url = "https://api.staging.adp.vogdevelopment.com/api/walkthrough"
        //        config.color.title = .red
        //        config.color.content = .yellow
        //        config.color.icon = .blue
        config.outsidePadding = 20
        config.insidePadding = 20
        config.delay = 0.6
        config.iconSize = CGSize(width: 20, height: 20)
        
        let walkthrough = VOGWalkthrough.shared
        walkthrough.setConfig(config: config)
        
        VOGWalkthrough.shared.showStep(on: self, screenId: "Scoreboard")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

