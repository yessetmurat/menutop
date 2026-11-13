//
//  MenuBarIcon.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import AppKit

/// The app's icon in the menu bar: the `cpu` symbol, drawn larger than the menu bar's default
/// symbol size.
@MainActor
enum MenuBarIcon {

    private static let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .large)

    /// The icon as a template image, so the menu bar tints it.
    static let image: NSImage = {
        let symbol = NSImage(systemSymbolName: "cpu", accessibilityDescription: "Menutop")
        let image = symbol?.withSymbolConfiguration(configuration) ?? NSImage()

        image.isTemplate = true
        return image
    }()
}
