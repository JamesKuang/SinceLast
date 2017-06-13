//
//  ContentInsetLabel.swift
//  SinceLast
//
//  Created by James Kuang on 6/12/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class ContentInsetLabel: UILabel {
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, contentInset))
    }

    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        let width = contentSize.width + contentInset.left + contentInset.right
        let heigth = contentSize.height + contentInset.top + contentInset.bottom
        return CGSize(width: width, height: heigth)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        let width = size.width + contentInset.left + contentInset.right
        let heigth = size.height + contentInset.top + contentInset.bottom
        return CGSize(width: width, height: heigth)
    }
}
