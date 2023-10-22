//
//  FontWeight.swift
//  FlexiblePickerExample
//
//  Created by Jędrzej Chołuj on 23/01/2022.
//

import SwiftUI

enum FontWeight {
    case light
    case thin
    case medium
    case regular
    case semibold
    case bold
    case ultralight
    case heavy
    case black
    
    var swiftUIFontWeight: Font.Weight {
        switch self {
        case .light:            return .light
        case .thin:             return .thin
        case .medium:           return .medium
        case .regular:          return .regular
        case .semibold:         return .semibold
        case .bold:             return .bold
        case .ultralight:       return .ultraLight
        case .heavy:            return .heavy
        case .black:            return .black
        }
    }
    
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .light:            return .light
        case .thin:             return .thin
        case .medium:           return .medium
        case .regular:          return .regular
        case .semibold:         return .semibold
        case .bold:             return .bold
        case .ultralight:       return .ultraLight
        case .heavy:            return .heavy
        case .black:            return .black
        }
    }
}


extension String {
    func getWidth(with font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func getHeight(with font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
