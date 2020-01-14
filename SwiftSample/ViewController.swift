//
//  ViewController.swift
//  SwiftSample
//
//  Created by Sungil Kim on 2019/10/18.
//  Copyright © 2019 Sungil Kim. All rights reserved.
//

import UIKit
import ADFMovieReward

class ViewController: UIViewController {
    private var adf: ADFmyMovieReward?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        adf = ADFmyMovieReward.getInstance("5ad844a543f0846b08000005", delegate: self)
        adf?.load()
    }
}

extension ViewController: ADFmyMovieRewardDelegate {
    func adsFetchCompleted(_ appID: String!, isTestMode isTestMode_inApp: Bool) {
        adf?.play()
    }
}
