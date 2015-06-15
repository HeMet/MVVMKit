//
//  EntryView.swift
//  DLife
//
//  Created by Евгений Губин on 15.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import Cartography

@IBDesignable
class EntryView: UIView {
    var imgPicture: UIImageView = UIImageView()
    var lblDescription: UILabel = UILabel()
    @IBInspectable var lblRating: UILabel = UILabel()
    @IBInspectable var lblRatingValue: UILabel = UILabel()
    
    @IBInspectable var picture: UIImage? {
        return imgPicture.image
    }
    
    @IBInspectable var title: String = "Description" {
        didSet {
            lblDescription.text = title
        }
    }
    
    @IBInspectable var ratingValue: Int = 0 {
        didSet {
            lblRatingValue.text = "\(ratingValue)"
        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTranslatesAutoresizingMaskIntoConstraints(false)
        setup()
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    func setup() {
        setDefaultValues()
        setupHierarchy()
        setupLayout()
    }
    
    func setDefaultValues() {
        lblDescription.text = "Descriptions"
        lblRating.text = "Raring:"
        lblRatingValue.text = "over 9000"
    }
    
    func setupHierarchy() {
        addSubview(lblDescription)
        addSubview(imgPicture)
        addSubview(lblRating)
        addSubview(lblRatingValue)
    }
    
    func setupLayout() {
        constrain(lblDescription) { desc in
            desc.left == desc.superview!.left + 8
            desc.right == desc.superview!.right - 8
            desc.top == desc.superview!.top + 8
        }
        
        constrain(lblDescription, imgPicture, lblRatingValue) { desc, pic, rating in
            pic.top == desc.bottom + 16
            pic.centerX == pic.superview!.centerX
            
            rating.top == pic.bottom + 16
        }
        
        constrain(lblRating, lblRatingValue) { rating, value in
            value.right == value.superview!.right - 8
            value.bottom == value.superview!.bottom - 8
            
            rating.right == value.left - 8
            rating.baseline == value.baseline
        }
    }
    
    func placeholderImage(width: Float, _ height: Float) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: CGFloat(width), height: CGFloat(height)))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
