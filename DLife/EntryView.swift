//
//  EntryView.swift
//  DLife
//
//  Created by Евгений Губин on 15.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import Cartography
import MVVMKit
import WebImage

@IBDesignable
class EntryView: UIView, ViewForViewModel {
    let placeholder_image = "placeholder_image"
    let designer_image = "designer_image"
    
    var imgPicture: UIImageView = UIImageView()
    var lblDescription: UILabel = UILabel()
    var lblRating: UILabel = UILabel()
    var lblRatingValue: UILabel = UILabel()
    
    var viewModel: DLEntry! {
        didSet {
            #if TARGET_INTERFACE_BUILDER
            bindToViewModel()
            #endif
        }
    }
    
    var instantGifLoading = false
    
    var loadingOverlay : LoadingOverlayLayer = LoadingOverlayLayer()
    
    @IBInspectable var picture: UIImage? {
        didSet {
            viewModel.previewURL = designer_image
            bindToViewModel()
        }
    }
    
    @IBInspectable var title: String = "Description" {
        didSet {
            viewModel.description = title
            bindToViewModel()
        }
    }
    
    @IBInspectable var ratingValue: Int = 0 {
        didSet {
            viewModel.votes = ratingValue
            bindToViewModel()
        }
    }

    @IBInspectable var overlay: Bool {
        get {
            return !loadingOverlay.hidden
        }
        set {
            loadingOverlay.hidden = !newValue
        }
    }
    
    @IBInspectable var loadingPercentage: CGFloat {
        get {
            return loadingOverlay.percentage
        }
        set {
            loadingOverlay.percentage = newValue
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
        setupHierarchy()
        setupLayout()
        setDefaultValues()
    }
    
    func setDefaultValues() {
        lblRating.text = "Rating:"
        
        loadingOverlay.hidden = true
        
        let dvm = DLEntry()
        dvm.description = "Descriptions"
        dvm.votes = 9000
        dvm.previewURL = placeholder_image
        dvm.imgSize = (50, 50)
        
        viewModel = dvm
    }
    
    func setupHierarchy() {
        addSubview(lblDescription)
        addSubview(imgPicture)
        addSubview(lblRating)
        addSubview(lblRatingValue)
        
        imgPicture.layer.addSublayer(loadingOverlay)
        
        let tr = UITapGestureRecognizer(target: self, action: Selector("handlePictureTap:"))
        imgPicture.addGestureRecognizer(tr)
        imgPicture.userInteractionEnabled = true
        
        lblDescription.numberOfLines = 0
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
            rating.left >= value.superview!.left + 8
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingOverlay.frame = imgPicture.layer.bounds
    }
    
    func bindToViewModel() {
        lblDescription.text = viewModel.description
        lblRatingValue.text = "\(viewModel.votes)"
        updatePicture()
    }
    
    func handlePictureTap(recognizer: UITapGestureRecognizer) {
        loadGif(imgPicture.image!)
    }
    
    func loadPreview() {
        let ph = placeholderImage(viewModel.imgSize.0, viewModel.imgSize.1)
        imgPicture.sd_setImageWithURL(NSURL(string: viewModel.previewURL), placeholderImage: ph) { img, _, _, _ in
            if (self.instantGifLoading) {
                // Workaround: in some cases (first load in our case) completition block is not called
                NSTimer.schedule(delay: 0.1) { _ in
                    self.loadGif(img)
                }
            }
        }
    }
    
    func loadGif(preview: UIImage) {
        if !self.viewModel.gifURL.isEmpty {
            loadingOverlay.hidden = false
            
            imgPicture.sd_setImageWithURL(NSURL(string: self.viewModel.gifURL),
                placeholderImage: preview,
                options: SDWebImageOptions(0),
                progress: { receivedSize, expectedSize in
                    self.loadingPercentage = CGFloat(receivedSize * 100 / expectedSize)
                }) { _ in
                self.loadingOverlay.hidden = true
            }
        }
    }
    
    func updatePicture() {
        switch viewModel.previewURL {
        case placeholder_image:
            imgPicture.image = placeholderImage(viewModel.imgSize.0, viewModel.imgSize.1, transparent: false)
        case designer_image:
            imgPicture.image = picture
        default:
            loadPreview()
        }
    }
    
    func placeholderImage(width: Float, _ height: Float, transparent: Bool = true) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        UIGraphicsBeginImageContext(CGSize(width: rect.width, height: rect.height))
        
        if (!transparent) {
            let ctx = UIGraphicsGetCurrentContext()
            UIColor.blackColor().set()
            CGContextFillRect(ctx, rect)
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
