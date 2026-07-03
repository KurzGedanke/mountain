//
//  HTMLText.swift
//  mountain
//
//  Band descriptions arrive from the API as HTML. This renders that markup as
//  styled text — bold/italic/links survive, but the document's hard-coded fonts
//  and colors are dropped so it follows Dynamic Type and the color scheme.
//

import SwiftUI
import UIKit

struct HTMLText: View {
    let html: String

    var body: some View {
        Text(Self.attributed(from: html) ?? AttributedString(html))
    }

    /// Convert an HTML fragment into an `AttributedString`, re-mapping the
    /// importer's fonts onto the system body font (preserving bold/italic) and
    /// removing baked-in colors so the surrounding view styling applies.
    static func attributed(from html: String) -> AttributedString? {
        guard let data = html.data(using: .utf8),
              let ns = try? NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil)
        else { return nil }

        let full = NSRange(location: 0, length: ns.length)
        let base = UIFont.preferredFont(forTextStyle: .body)

        ns.enumerateAttribute(.font, in: full) { value, range, _ in
            let traits = (value as? UIFont)?.fontDescriptor.symbolicTraits ?? []
            var descriptor = base.fontDescriptor
            if let withTraits = descriptor.withSymbolicTraits(
                traits.intersection([.traitBold, .traitItalic])) {
                descriptor = withTraits
            }
            ns.addAttribute(.font,
                            value: UIFont(descriptor: descriptor, size: base.pointSize),
                            range: range)
        }
        ns.removeAttribute(.foregroundColor, range: full)

        // The HTML importer appends a trailing newline; drop it so spacing matches.
        while ns.length > 0,
              (ns.string as NSString).hasSuffix("\n") {
            ns.deleteCharacters(in: NSRange(location: ns.length - 1, length: 1))
        }

        return try? AttributedString(ns, including: \.uiKit)
    }
}
