//
//  PrivacyView.swift
//  googleMap
//
//  Created by Ke4a on 15.12.2022.
//

import UIKit

class PrivacyView: UIVisualEffectView {
    init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        super.init(effect: blurEffect)
        self.frame = frame
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
