//
//  SingInViewController.swift
//  VendingMachine
//
//  Created by Mac on 07/10/2017.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SingInViewController: UIViewController {
    @IBOutlet weak var SignInSelector: UISegmentedControl!
    
    @IBOutlet weak var EmailLabel: UILabel!
    
    @IBOutlet weak var EmailTxt: UITextField!
    
    @IBOutlet weak var PasswordText: UITextField!

    @IBOutlet weak var SignInBtn: UIButton!
    
    @IBOutlet weak var SignInLabel: UILabel!
    var isSignedIn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        EmailTxt.autocorrectionType = .no
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions

    @IBAction func SignInSelectorChanged(_ sender: UISegmentedControl) {
        
        //flip the button
        isSignedIn = !isSignedIn
        
        //check if signed in
        if isSignedIn {
            SignInLabel.text = "Sign In"
            SignInBtn.setTitle("Sign in", for: .normal)
        } else {
            SignInLabel.text = "Register"
            SignInBtn.setTitle("Register", for: .normal)
        }
    }
    
    //MARK: - Sign in, Register
    @IBAction func SignIn(_ sender: UIButton) {
        
        //Check email validation
        if let email = EmailTxt.text, let password = PasswordText.text {
            
            //check if sign in or register
            if isSignedIn {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    //check user not nil
                    if let user = user {
                        //check user
                    self.performSegue(withIdentifier: "goToStore", sender: self)
                        print("Sign in")
                    } else {
                        //check error show message
                        self.showAlert(title: "Input", message: "Wrong email or password, please try again")
                        
                    }
                })
            } else {
                //register the user with firebase
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    if let user = user {
                       self.performSegue(withIdentifier: "goToStore", sender: self)
                         print("Sign up")
                    } else {
                         print("Not Sign up")
                    }
                })
                
            }
        }
    }
    
    // MARK: - Handle touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dismiss keyboard when view tapped on
        EmailTxt.resignFirstResponder()
        PasswordText.resignFirstResponder()
    }
    // MARK: - Alert 
    
    func showAlert(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "OK", style: .default, handler: dismiss)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func dismiss(sender: UIAlertAction) -> Void {
        PasswordText.text = ""
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
