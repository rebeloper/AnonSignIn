//
//  RootViewController.swift
//  AnonSignIn
//
//  Created by Alex Nagy on 21/04/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import TinyConstraints
import FirebaseAuth

class RootViewController: UIViewController {
    
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in anon", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func loginButtonTapped() {
        print("Login tapped")
        let auth = Auth.auth()
        auth.signInAnonymously { (result, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            print("Successfully signed in to Firebase Auth")
        }
    }
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.alpha = 0.0
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func logoutButtonTapped() {
        print("Logout tapped")
        let auth = Auth.auth()
        
        do {
            try auth.signOut()
            print("Successfully signed out of Firebase Auth")
        } catch (let err) {
            print(err.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                print("User is nil")
                self.loginButton.alpha = 1.0
                self.logoutButton.alpha = 0.0
                self.title = "User is logged out"
            }
            guard let user = user else { return }
            let uid = user.uid
            print("Found user with uid: \(uid)")
            self.loginButton.alpha = 0.0
            self.logoutButton.alpha = 1.0
            self.title = uid
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let authStateDidChangeListenerHandle = authStateDidChangeListenerHandle else { return }
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }

    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(loginButton)
        view.addSubview(logoutButton)
        
        loginButton.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        loginButton.height(50)
        
        logoutButton.topToBottom(of: loginButton, offset: 12)
        logoutButton.leftToSuperview(offset: 12, usingSafeArea: true)
        logoutButton.rightToSuperview(offset: -12, usingSafeArea: true)
        logoutButton.height(50)
    }

}

