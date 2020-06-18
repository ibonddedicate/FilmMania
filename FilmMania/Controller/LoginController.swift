//
//  LoginController.swift
//  FilmMania
//
//  Created by Surote Gaide on 18/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class LoginController: UIViewController {

    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Utilities.styleTextField(emailBox)
        Utilities.styleTextField(passwordBox)
        Utilities.styleFilledButton(loginButton)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if validateLogin() {
            let properEmail = emailBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let properPassword = passwordBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: properEmail, password: properPassword) { [weak self] result, error in
              guard let strongSelf = self else { return }
                if error != nil {
                    SCLAlertView().showError("Error", subTitle: String(error!.localizedDescription))
                } else {
                    strongSelf.moveToHome()
                }
                
            }
        }
    }
    
    func validateLogin() -> Bool {
        
        if emailBox.text != "" || passwordBox.text != "" {
            if Utilities.isValidEmail(email: emailBox.text){
                return true
            } else {
                SCLAlertView().showError("Email Invalid", subTitle: "Please enter your email correctly.")
                return false
            }
            
        } else {
            SCLAlertView().showError("No credentials", subTitle: "Please enter your login information")
            return false
        }
    }
    
    func moveToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: "nav") as? NavigationController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
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
