//
//  LoadingScreen.swift
//  CoDraw
//
//  Created by Metin Öztürk on 15.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import UIKit

class LoadingScreen : UIViewController {
    private let activityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingText : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .lightGray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Searching For Another\nUser"
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        setupActivityIndicator()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator.startAnimating()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.activityIndicator.stopAnimating()
        
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        view.addSubview(loadingText)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: loadingText, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: loadingText, attribute: .top, relatedBy: .equal, toItem: activityIndicator, attribute: .bottom, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: loadingText, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: loadingText, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        ])
    }
}
