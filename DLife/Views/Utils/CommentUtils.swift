//
//  CommentUtils.swift
//  DLife
//
//  Created by Евгений Губин on 09.07.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

func parseCommentText(text: String) -> NSAttributedString? {
    let htmlString = "<span style=\"font-family: HelveticaNeue-Medium; font-size: 17\">\(text)</span>"
    return NSAttributedString(
        data: htmlString.dataUsingEncoding(NSUTF8StringEncoding)!,
        options: [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ],
        documentAttributes: nil,
        error: nil)
}