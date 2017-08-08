//
//  TextAreaMarkerManager.swift
//  FindText
//
//  Created by Ilias Van Peer on 8/8/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation

@objc(TextAreaMarkerSwift)
class TextAreaMarkerManager: RCTViewManager {
  override func view() -> UIView! {
//    return UIView()
     return TextAreaMarkerView()
  }
}
