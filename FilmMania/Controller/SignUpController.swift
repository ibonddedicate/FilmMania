//
//  SignUpController.swift
//  FilmMania
//
//  Created by Surote Gaide on 18/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class SignUpController: UIViewController {

    @IBOutlet weak var firstNameBox: UITextField!
    @IBOutlet weak var lastNameBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var rePasswordBox: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Utilities.styleFilledButton(signUpButton)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        let properFirstname = firstNameBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let properLastname = lastNameBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let properEmail = emailBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let properPassword = passwordBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if validateForm() {
            Auth.auth().createUser(withEmail: properEmail, password: properPassword) { (result, error) in
                
                if error != nil {
                    
                    SCLAlertView().showError("Error", subTitle: String(error!.localizedDescription))
                    
                } else {
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstName" : properFirstname, "lastName" : properLastname, "email" : properEmail, "uid": result!.user.uid]) { (error) in
                        if error != nil {
                            print(error!)
                        }
                    }
                    
                    print ("successfully registered")
                    let noCloseApperance = SCLAlertView.SCLAppearance(showCloseButton : false)
                    let successAlert = SCLAlertView(appearance: noCloseApperance)
                    successAlert.addButton("Got it!") {
                        self.moveToHome()
                        print("button Pressed")
                    }
                    successAlert.showSuccess("Registration Successful", subTitle: "You are now a member of our Film Mania Community. You will be able to rate and comment on your favorite films.")
                }
            }
        } else {
            print ("failed")
        }
        
    }
    
    func validateForm() -> Bool{
        
        if firstNameBox.text != "" || lastNameBox.text != "" || emailBox.text != "" || passwordBox.text != "" || rePasswordBox.text != "" {
            
            if Utilities.isValidEmail(email: emailBox.text) {
                if Utilities.isValidPassword(testStr: passwordBox.text) {
                    if passwordBox.text == rePasswordBox.text {
                        return true
                    } else {
                        SCLAlertView().showError("Passwords do not match", subTitle: "Please check whether both of the password fields are exactly the same.")
                        return false
                    }
                } else {
                    SCLAlertView().showError("Incorrect Password Format", subTitle: "The password needs to be at least 8 characters long with at least 1 Upper-case and 1 Lower-case character. Special character is not supported.")
                    return false
                }
            } else {
                SCLAlertView().showError("Email Invalid", subTitle: "Please enter your email correctly.")
                return false
            }
        } else {
            SCLAlertView().showWarning("Empty Fields", subTitle: "Please check whether all fields are correctly filled.")
            return false
        }
    }
    
    func moveToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: "Home") as? HomeViewController
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
