//
//  LoadingCircle.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 3/21/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import UIKit

class ProgressSpinnerView: UIView {
    
    private let spinnerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white // Default color, can be customized
        return imageView
    }()
    
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(spinnerImageView)
        
        NSLayoutConstraint.activate([
            spinnerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinnerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinnerImageView.widthAnchor.constraint(equalTo: widthAnchor),
            spinnerImageView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        
        // Set the initial image for the spinner
        spinnerImageView.image = UIImage(systemName: "circle.dashed")
        
        // Start animation when the view appears
        startAnimating()
    }
    
    override func removeFromSuperview() {
        stopAnimating()
        super.removeFromSuperview()
    }
    
    // MARK: - Animation
    
    func startAnimating() {
        guard !isAnimating else { return }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 3.0
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "rotationAnimation")
        
        isAnimating = true
    }
    
    func stopAnimating() {
        guard isAnimating else { return }
        
        layer.removeAnimation(forKey: "rotationAnimation")
        isAnimating = false
    }
    
    // MARK: - Public Methods
    
    func setColor(_ color: UIColor) {
        spinnerImageView.tintColor = color
    }
    
    func show() {
            isHidden = false
            startAnimating()
            superview?.isUserInteractionEnabled = false
        }
        
    func hide() {
            isHidden = true
            stopAnimating()
            superview?.isUserInteractionEnabled = true
    }
    
}
