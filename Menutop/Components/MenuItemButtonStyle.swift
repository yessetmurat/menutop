//
//  MenuItemButtonStyle.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import SwiftUI

/// A button drawn as a menu item: a full-width row with an optional shortcut at the end,
/// highlighted with the accent colour while the pointer is over it or it is pressed.
struct MenuItemButtonStyle: ButtonStyle {

    /// The shortcut shown at the end of the row, such as `⌘Q`.
    var shortcut: String?

    func makeBody(configuration: Configuration) -> some View {
        MenuItemRow(configuration: configuration, shortcut: shortcut)
    }
}

private struct MenuItemRow: View {

    let configuration: ButtonStyleConfiguration
    let shortcut: String?

    @State private var isHovered = false

    var body: some View {
        let isHighlighted = isHovered || configuration.isPressed

        HStack {
            configuration.label

            Spacer()

            if let shortcut {
                Text(shortcut)
                    .foregroundStyle(isHighlighted ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
            }
        }
        .foregroundStyle(isHighlighted ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHighlighted ? Color.accentColor : .clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}
