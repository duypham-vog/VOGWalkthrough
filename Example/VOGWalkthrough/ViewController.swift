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

        VOGWalkthrough.shared.showStep(on: self, screenId: "NUBHomeViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

