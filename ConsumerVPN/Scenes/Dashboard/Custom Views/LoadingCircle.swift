//
//  AnimatedCircle.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/26/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class LoadingCircle: UIView {
    
    enum AnimationState {
        case connecting
        case disconnecting
        case loadingServers
    }
    
    // Constants
    let circleLineWidth: CGFloat = 2.0
    let circleSizeDifference: CGFloat = 0.85
    let arcLineWidth: CGFloat = 4.0
    let arcEndAngle: CGFloat = 1.6 * CGFloat.pi
    let fontSize: CGFloat = 20.0
    let labelConstrainingHeight: CGFloat = 21.0
    
    let connectingText =    "Connecting..."
    let disconnectingtext = "Disconnecting..."
    let loadingText =       "Loading servers..."
    
    // Animation duration for one rotation (in seconds)
    let rotationAnimationDuration = 1.5
    
    // Shapes
    let circleLayer = CAShapeLayer()
    let arcLayer = CAShapeLayer()
    
    let label = UILabel()
    
    override func layoutSubviews() {
        addSubview(label)
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = UIColor.appWideTint
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        circleLayer.frame = rect
        let circleRadius = (rect.size.width / 2.0) * circleSizeDifference
        circleLayer.path = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0),
                                        radius: circleRadius,
                                        startAngle: 0.0,
                                        endAngle: 2.0 * CGFloat.pi,
                                        clockwise: true).cgPath
        circleLayer.strokeColor = UIColor.appWideTint.cgColor
        circleLayer.lineWidth = circleLineWidth
        circleLayer.fillColor = nil
        layer.addSublayer(circleLayer)
        
        arcLayer.frame = rect
        arcLayer.path = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0),
                                     radius: rect.width / 2.0,
                                     startAngle: 0.0,
                                     endAngle: arcEndAngle,
                                     clockwise: false).cgPath
        arcLayer.lineWidth = arcLineWidth
        arcLayer.strokeColor = UIColor.appWideTint.cgColor
        arcLayer.fillColor = nil
        layer.addSublayer(arcLayer)
    }
    
    func spinCycle(for state: AnimationState, completionDelegate: CAAnimationDelegate? = nil) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        switch state {
        case .connecting:
            label.text = connectingText
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = CGFloat.pi * 2.0
        case .disconnecting:
            label.text = disconnectingtext
            rotationAnimation.fromValue = CGFloat.pi * 2.0
            rotationAnimation.toValue = 0.0
        case .loadingServers:
            label.text = loadingText
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = CGFloat.pi * 2.0
        }
        
        rotationAnimation.duration = rotationAnimationDuration
        
        if let delegate = completionDelegate {
            rotationAnimation.delegate = delegate
        }
        
        arcLayer.add(rotationAnimation, forKey: nil)
    }
}
