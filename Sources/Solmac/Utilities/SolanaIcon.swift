import AppKit

enum SolanaIcon {
    // Solana logo: three parallelogram bars forming an "S" shape.
    // Derived from the official Solana SVG (viewBox 397.7 x 311.7), scaled to 18x18.
    //
    // Original parallelogram corners:
    //   Top bar:    TL(73.8, 0)     TR(391.2, 0)     BR(323.9, 77.6)   BL(6.5, 77.6)
    //   Middle bar: TL(6.5, 116.3)  TR(323.9, 116.3) BR(391.2, 193.9)  BL(73.8, 193.9)
    //   Bottom bar: TL(73.8, 234.1) TR(391.2, 234.1) BR(323.9, 311.7)  BL(6.5, 311.7)
    //
    // Top & bottom slant left (↘), middle slants right (↗) — forms the "S".

    private static let scale: CGFloat = 18.0 / 397.7
    private static let yOffset: CGFloat = (18.0 - 311.7 * scale) / 2.0

    private static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * scale, y: y * scale + yOffset)
    }

    private static let topBar: [CGPoint] = [
        p(73.8, 0), p(391.2, 0), p(323.9, 77.6), p(6.5, 77.6)
    ]
    private static let middleBar: [CGPoint] = [
        p(6.5, 116.3), p(323.9, 116.3), p(391.2, 193.9), p(73.8, 193.9)
    ]
    private static let bottomBar: [CGPoint] = [
        p(73.8, 234.1), p(391.2, 234.1), p(323.9, 311.7), p(6.5, 311.7)
    ]

    private static let allBars = [topBar, middleBar, bottomBar]

    static func menuBarIcon(filled: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: true) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            ctx.setLineJoin(.round)
            ctx.setLineCap(.round)

            for bar in allBars {
                guard let first = bar.first else { continue }
                ctx.beginPath()
                ctx.move(to: first)
                for point in bar.dropFirst() {
                    ctx.addLine(to: point)
                }
                ctx.closePath()

                if filled {
                    ctx.setFillColor(NSColor.black.cgColor)
                    ctx.fillPath()
                } else {
                    ctx.setStrokeColor(NSColor.black.cgColor)
                    ctx.setLineWidth(1.0)
                    ctx.strokePath()
                }
            }
            return true
        }
        image.isTemplate = true
        return image
    }

    static var filled: NSImage { menuBarIcon(filled: true) }
    static var outline: NSImage { menuBarIcon(filled: false) }
}
