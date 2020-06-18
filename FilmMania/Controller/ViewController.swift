//
//  ViewController.swift
//  FilmMania
//
//  Created by Surote Gaide on 18/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC = storyboard.instantiateViewController(identifier: "nav")
            self.view.window?.rootViewController = VC
        } else { return }
    }
    

}

