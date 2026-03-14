#!/usr/bin/env swift

import AppKit
import CoreGraphics

// MARK: - Icon Generator for Solmac
// Generates a macOS .icns app icon: Solana logo + small Mac symbol

let sizes: [(name: String, size: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let scale = s / 1024.0

    // --- Background: rounded rectangle with Solana-style gradient ---
    let cornerRadius = s * 0.22
    let bgRect = CGRect(x: 0, y: 0, width: s, height: s)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Dark gradient background (deep purple to near-black)
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let bgColors = [
        CGColor(colorSpace: colorSpace, components: [0.08, 0.02, 0.18, 1.0])!,
        CGColor(colorSpace: colorSpace, components: [0.02, 0.01, 0.08, 1.0])!,
    ]
    let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 1.0])!

    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    ctx.drawLinearGradient(bgGradient,
                           start: CGPoint(x: 0, y: s),
                           end: CGPoint(x: s, y: 0),
                           options: [])
    ctx.restoreGState()

    // --- Subtle inner glow/border ---
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.setStrokeColor(CGColor(colorSpace: colorSpace, components: [0.4, 0.2, 0.8, 0.3])!)
    ctx.setLineWidth(1.5 * scale)
    ctx.strokePath()
    ctx.restoreGState()

    // --- Solana Logo (three bars) ---
    // Original viewBox: 397.7 x 311.7
    // Center the logo in the icon with padding
    let logoPadding = s * 0.18
    let logoAreaSize = s - logoPadding * 2
    let logoScale = logoAreaSize / 397.7
    let logoYScale = logoAreaSize / 311.7
    let finalScale = min(logoScale, logoYScale)
    let logoW = 397.7 * finalScale
    let logoH = 311.7 * finalScale
    let logoX = (s - logoW) / 2.0
    // Shift logo up slightly to make room for the Mac badge
    let logoY = (s - logoH) / 2.0 - s * 0.03

    func lp(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * finalScale + logoX, y: s - (y * finalScale + logoY) - logoH)
    }

    // Flip Y for Core Graphics (origin bottom-left)
    func lp_cg(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        let py = y * finalScale + logoY
        return CGPoint(x: x * finalScale + logoX, y: s - py - logoH + logoH)
    }

    // The three Solana bars (top, middle, bottom) - using original SVG coords
    // In CG coords, Y is flipped, so "top" bar visually is at top
    let bars: [[(CGFloat, CGFloat)]] = [
        // Top bar
        [(73.8, 0), (391.2, 0), (323.9, 77.6), (6.5, 77.6)],
        // Middle bar
        [(6.5, 116.3), (323.9, 116.3), (391.2, 193.9), (73.8, 193.9)],
        // Bottom bar
        [(73.8, 234.1), (391.2, 234.1), (323.9, 311.7), (6.5, 311.7)],
    ]

    // Solana gradient colors (official: teal/green to purple/magenta)
    let solGradColors = [
        CGColor(colorSpace: colorSpace, components: [0.0, 1.0, 0.82, 1.0])!,   // #00FFD1 bright teal
        CGColor(colorSpace: colorSpace, components: [0.53, 0.33, 1.0, 1.0])!,  // #8854FF purple
        CGColor(colorSpace: colorSpace, components: [0.86, 0.20, 0.86, 1.0])!, // #DC33DC magenta
    ]
    let solGradient = CGGradient(colorsSpace: colorSpace, colors: solGradColors as CFArray, locations: [0.0, 0.5, 1.0])!

    // Draw all bars with gradient
    // First, create a combined path for clipping
    ctx.saveGState()

    let combinedPath = CGMutablePath()
    for bar in bars {
        let points = bar.map { lp_cg($0.0, $0.1) }
        combinedPath.move(to: points[0])
        for pt in points.dropFirst() {
            combinedPath.addLine(to: pt)
        }
        combinedPath.closeSubpath()
    }

    ctx.addPath(combinedPath)
    ctx.clip()

    // Draw gradient across the full logo area
    ctx.drawLinearGradient(solGradient,
                           start: CGPoint(x: logoX, y: s - logoY),
                           end: CGPoint(x: logoX + logoW, y: s - logoY - logoH),
                           options: [])
    ctx.restoreGState()

    // --- Add subtle glow behind the logo ---
    ctx.saveGState()
    let glowColor = CGColor(colorSpace: colorSpace, components: [0.0, 1.0, 0.82, 0.08])!
    ctx.setShadow(offset: .zero, blur: 20 * scale, color: glowColor)
    ctx.addPath(combinedPath)
    ctx.setFillColor(CGColor(colorSpace: colorSpace, components: [0.0, 1.0, 0.82, 0.15])!)
    ctx.fillPath()
    ctx.restoreGState()

    // --- Mac Badge (bottom-right corner) ---
    // Draw a small, clean Mac/laptop icon
    let badgeSize = s * 0.22
    let badgeX = s - badgeSize - s * 0.08
    let badgeY = s * 0.08  // bottom-right in CG coords (origin bottom-left)

    // Badge background circle
    let badgeCenter = CGPoint(x: badgeX + badgeSize / 2, y: badgeY + badgeSize / 2)
    let badgeRadius = badgeSize / 2

    // Dark circle background with border
    ctx.saveGState()
    let badgeBgPath = CGPath(ellipseIn: CGRect(x: badgeCenter.x - badgeRadius,
                                                 y: badgeCenter.y - badgeRadius,
                                                 width: badgeRadius * 2,
                                                 height: badgeRadius * 2), transform: nil)
    ctx.addPath(badgeBgPath)
    ctx.setFillColor(CGColor(colorSpace: colorSpace, components: [0.06, 0.02, 0.14, 0.95])!)
    ctx.fillPath()

    ctx.addPath(badgeBgPath)
    ctx.setStrokeColor(CGColor(colorSpace: colorSpace, components: [0.53, 0.33, 1.0, 0.6])!)
    ctx.setLineWidth(1.2 * scale)
    ctx.strokePath()
    ctx.restoreGState()

    // Draw a small Apple/Mac symbol (simplified laptop shape)
    ctx.saveGState()
    let macScale = badgeSize / 100.0

    // Laptop screen
    let screenW = 52.0 * macScale
    let screenH = 36.0 * macScale
    let screenX = badgeCenter.x - screenW / 2
    let screenY = badgeCenter.y - screenH / 2 + 6 * macScale
    let screenCorner = 4.0 * macScale

    let screenRect = CGRect(x: screenX, y: screenY, width: screenW, height: screenH)
    let screenPath = CGPath(roundedRect: screenRect, cornerWidth: screenCorner, cornerHeight: screenCorner, transform: nil)

    ctx.addPath(screenPath)
    ctx.setFillColor(CGColor(colorSpace: colorSpace, components: [0.0, 1.0, 0.82, 0.9])!)
    ctx.fillPath()

    // Laptop base
    let baseW = 64.0 * macScale
    let baseH = 4.0 * macScale
    let baseX = badgeCenter.x - baseW / 2
    let baseY = screenY - baseH - 2 * macScale
    let baseCorner = 2.0 * macScale

    let baseRect = CGRect(x: baseX, y: baseY, width: baseW, height: baseH)
    let basePath = CGPath(roundedRect: baseRect, cornerWidth: baseCorner, cornerHeight: baseCorner, transform: nil)

    ctx.addPath(basePath)
    ctx.setFillColor(CGColor(colorSpace: colorSpace, components: [0.0, 1.0, 0.82, 0.9])!)
    ctx.fillPath()

    // Small Solana "S" mark inside the screen
    let miniBarH = 4.0 * macScale
    let miniBarW = 26.0 * macScale
    let miniSlant = 5.0 * macScale
    let miniCenterX = badgeCenter.x
    let miniCenterY = screenY + screenH / 2
    let miniGap = 2.0 * macScale

    ctx.setFillColor(CGColor(colorSpace: colorSpace, components: [0.06, 0.02, 0.14, 0.9])!)

    // Three mini bars inside the screen
    for i in -1...1 {
        let yy = miniCenterY + CGFloat(i) * (miniBarH + miniGap)
        let slantDir: CGFloat = (i == 0) ? -1.0 : 1.0
        let path = CGMutablePath()
        path.move(to: CGPoint(x: miniCenterX - miniBarW/2 + slantDir * miniSlant, y: yy - miniBarH/2))
        path.addLine(to: CGPoint(x: miniCenterX + miniBarW/2, y: yy - miniBarH/2))
        path.addLine(to: CGPoint(x: miniCenterX + miniBarW/2 - slantDir * miniSlant, y: yy + miniBarH/2))
        path.addLine(to: CGPoint(x: miniCenterX - miniBarW/2, y: yy + miniBarH/2))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }

    ctx.restoreGState()

    image.unlockFocus()
    return image
}

// Create iconset directory
let iconsetDir = "Resources/AppIcon.iconset"
let fm = FileManager.default

try? fm.removeItem(atPath: iconsetDir)
try fm.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

for (name, size) in sizes {
    let image = drawIcon(size: size)
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to generate \(name)")
        continue
    }
    let path = "\(iconsetDir)/\(name).png"
    try png.write(to: URL(fileURLWithPath: path))
    print("Generated \(name).png (\(size)x\(size))")
}

print("\nIconset created at \(iconsetDir)")
print("Run: iconutil -c icns \(iconsetDir) -o Resources/AppIcon.icns")
