//
//  Utilities.swift
//  FilmMania
//
//  Created by Surote Gaide on 18/6/20.
//  Copyright © 2020 Surote Gaide. All rights reserved.
//
import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 255/255, green: 149/255, blue: 0/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        button.backgroundColor = UIColor.init(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    static func isValidEmail(email:String?) -> Bool {
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        
        return pred.evaluate(with: email)
    }
    
    static func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        
        return passwordTest.evaluate(with: testStr)
    }
    
}
