//
//  HeaderView.swift
//  ContactInformation
//
//  Created by Jun Dang on 12/22/18.
//  Copyright © 2018 Jun Dang. All rights reserved.
//

import UIKit
import Cartography

class BaseView: UIView {
    
    var didSetupConstraints = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layoutView()
    }
    
    func setup() {
       
    }
    
    func layoutView() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if didSetupConstraints {
            super.updateConstraints()
            return
        }
        layoutView()
        super.updateConstraints()
        didSetupConstraints = true
    }
}

class HeaderView: BaseView {
   
    let sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.text = ""
        label.backgroundColor =
         .yellow
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(UIImage(named: "Chevron-Dn-Wht"), for: .normal)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .right
        button.backgroundColor = .yellow
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        return button
    }()
    
    override func setup() {
        addSubview(sectionLabel)
        addSubview(button)
    }
    
    override func layoutView() {
        constrain(sectionLabel) {
            $0.left == $0.superview!.left + 10
            $0.width == 80
            $0.top == $0.superview!.top + 2
            $0.bottom == $0.superview!.bottom - 2
        }
        constrain(button, sectionLabel) {
            $0.top == $1.top
            $0.bottom == $1.bottom
            $0.left == $1.right + 6
            $0.right == $0.superview!.right
        }
    }
    
    weak var delegate: HandleButtonDelegate?
    
    @objc func handleExpandClose(button: UIButton) {
        delegate?.handleExpandClose(button: button)
    }
}
