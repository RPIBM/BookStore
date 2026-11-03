#!/usr/bin/env swift
// Generates Bookstore/Assets.xcassets: book cover artwork, the app icon and the launch-screen logo.
// Usage (from the repository root):
//   swiftc -O Scripts/generate_assets.swift -o /tmp/generate_assets && /tmp/generate_assets Bookstore/Assets.xcassets
import AppKit
import CoreGraphics
import ImageIO

// MARK: - Catalog (keep in sync with MockBookRepository.sampleBooks)

struct BookArt {
    let id: String, title: String, author: String, genre: String
    let c1: UInt32, c2: UInt32
}

let books: [BookArt] = [
    BookArt(id: "b01", title: "The Midnight Library", author: "Matt Haig", genre: "Fiction", c1: 0x1B2A49, c2: 0x6A4C93),
    BookArt(id: "b02", title: "Project Hail Mary", author: "Andy Weir", genre: "Science Fiction", c1: 0x0B132B, c2: 0x3A86FF),
    BookArt(id: "b03", title: "The Silent Patient", author: "Alex Michaelides", genre: "Mystery", c1: 0x2B2D42, c2: 0xEF233C),
    BookArt(id: "b04", title: "Dune", author: "Frank Herbert", genre: "Science Fiction", c1: 0x7F4F24, c2: 0xDDA15E),
    BookArt(id: "b05", title: "The Name of the Wind", author: "Patrick Rothfuss", genre: "Fantasy", c1: 0x264653, c2: 0x2A9D8F),
    BookArt(id: "b06", title: "Educated", author: "Tara Westover", genre: "Biography", c1: 0x4A4E69, c2: 0xC9ADA7),
    BookArt(id: "b07", title: "Atomic Habits", author: "James Clear", genre: "Non-Fiction", c1: 0xE76F51, c2: 0xF4A261),
    BookArt(id: "b08", title: "Gone Girl", author: "Gillian Flynn", genre: "Mystery", c1: 0x370617, c2: 0xD00000),
    BookArt(id: "b09", title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", c1: 0x386641, c2: 0xA7C957),
    BookArt(id: "b10", title: "Sapiens", author: "Yuval Noah Harari", genre: "Non-Fiction", c1: 0x5F0F40, c2: 0xFB8B24),
    BookArt(id: "b11", title: "Circe", author: "Madeline Miller", genre: "Fantasy", c1: 0x003049, c2: 0xFCBF49),
    BookArt(id: "b12", title: "Becoming", author: "Michelle Obama", genre: "Biography", c1: 0x3D405B, c2: 0xE07A5F),
    BookArt(id: "b13", title: "Neuromancer", author: "William Gibson", genre: "Science Fiction", c1: 0x10002B, c2: 0x00F5D4),
    BookArt(id: "b14", title: "Where the Crawdads Sing", author: "Delia Owens", genre: "Fiction", c1: 0x1B4332, c2: 0x74C69D),
    BookArt(id: "b15", title: "The Da Vinci Code", author: "Dan Brown", genre: "Mystery", c1: 0x1D3557, c2: 0xE63946),
    BookArt(id: "b16", title: "A Brief History of Time", author: "Stephen Hawking", genre: "Non-Fiction", c1: 0x03045E, c2: 0x90E0EF)
]

// MARK: - Drawing helpers

func cgColor(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha)
}

func makeContext(_ width: Int, _ height: Int, opaque: Bool) -> CGContext {
    let info = opaque ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: info)!
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    return ctx
}

func writePNG(_ ctx: CGContext, to url: URL) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Could not write \(url.path)") }
}

func writeJSON(_ object: Any, to url: URL) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let data = try! JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
    try! data.write(to: url)
}

let assetInfo: [String: Any] = ["author": "xcode", "version": 1]

func linearGradient(_ ctx: CGContext, from: CGPoint, to: CGPoint, _ colors: [CGColor]) {
    let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: colors as CFArray, locations: nil)!
    ctx.drawLinearGradient(gradient, start: from, end: to, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}

func drawText(_ ctx: CGContext, _ attributed: NSAttributedString, in rect: CGRect) {
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    attributed.draw(with: rect, options: [.usesLineFragmentOrigin], context: nil)
    NSGraphicsContext.restoreGraphicsState()
}

func serifBold(_ size: CGFloat) -> NSFont {
    NSFont(name: "Georgia-Bold", size: size) ?? NSFont.boldSystemFont(ofSize: size)
}

// MARK: - Book cover artwork (origin is bottom-left, canvas 600 x 870)

let coverWidth = 600, coverHeight = 870

func drawMotif(_ ctx: CGContext, genre: String) {
    let white: (CGFloat) -> CGColor = { CGColor(srgbRed: 1, green: 1, blue: 1, alpha: $0) }

    func star(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ a: CGFloat = 0.8) {
        ctx.setFillColor(white(a))
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }

    switch genre {
    case "Fiction": // sun over water
        ctx.setFillColor(white(0.88))
        ctx.fillEllipse(in: CGRect(x: 195, y: 290, width: 210, height: 210))
        for (i, w) in [330, 270, 210, 150, 90].enumerated() {
            ctx.setFillColor(white(0.42 - CGFloat(i) * 0.05))
            let y = 245 - CGFloat(i) * 34
            ctx.fill(CGRect(x: 300 - CGFloat(w) / 2, y: y, width: CGFloat(w), height: 16))
        }
    case "Mystery": // magnifying glass
        ctx.setFillColor(white(0.14))
        ctx.fillEllipse(in: CGRect(x: 170, y: 270, width: 200, height: 200))
        ctx.setStrokeColor(white(0.92))
        ctx.setLineWidth(24)
        ctx.strokeEllipse(in: CGRect(x: 170, y: 270, width: 200, height: 200))
        ctx.setLineWidth(38)
        ctx.setLineCap(.round)
        ctx.move(to: CGPoint(x: 348, y: 296))
        ctx.addLine(to: CGPoint(x: 432, y: 212))
        ctx.strokePath()
    case "Science Fiction": // ringed planet and stars
        for (x, y, r) in [(90, 520, 4), (500, 540, 5), (130, 200, 3), (520, 230, 4), (440, 470, 3), (70, 360, 3)] as [(CGFloat, CGFloat, CGFloat)] {
            star(x, y, r)
        }
        ctx.setFillColor(white(0.88))
        ctx.fillEllipse(in: CGRect(x: 205, y: 240, width: 190, height: 190))
        ctx.saveGState()
        ctx.translateBy(x: 300, y: 335)
        ctx.rotate(by: -0.38)
        ctx.setStrokeColor(white(0.95))
        ctx.setLineWidth(14)
        ctx.strokeEllipse(in: CGRect(x: -170, y: -42, width: 340, height: 84))
        ctx.restoreGState()
    case "Fantasy": // mountains under a moon
        star(455, 470, 42, 0.92)
        for (x, y, r) in [(100, 500, 4), (230, 540, 3), (360, 520, 4), (540, 380, 3)] as [(CGFloat, CGFloat, CGFloat)] {
            star(x, y, r)
        }
        ctx.setFillColor(white(0.45))
        ctx.move(to: CGPoint(x: 40, y: 190)); ctx.addLine(to: CGPoint(x: 195, y: 400))
        ctx.addLine(to: CGPoint(x: 350, y: 190)); ctx.closePath(); ctx.fillPath()
        ctx.setFillColor(white(0.78))
        ctx.move(to: CGPoint(x: 210, y: 190)); ctx.addLine(to: CGPoint(x: 385, y: 440))
        ctx.addLine(to: CGPoint(x: 560, y: 190)); ctx.closePath(); ctx.fillPath()
    case "Non-Fiction": // sunburst
        ctx.setStrokeColor(white(0.85))
        ctx.setLineCap(.round)
        ctx.setLineWidth(14)
        let center = CGPoint(x: 300, y: 345)
        for i in 0..<16 {
            let angle = CGFloat(i) * .pi / 8
            let inner: CGFloat = 78, outer: CGFloat = i % 2 == 0 ? 170 : 128
            ctx.move(to: CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
            ctx.addLine(to: CGPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
        }
        ctx.strokePath()
        ctx.setFillColor(white(0.92))
        ctx.fillEllipse(in: CGRect(x: center.x - 52, y: center.y - 52, width: 104, height: 104))
    default: // Biography: portrait silhouette
        ctx.setFillColor(white(0.88))
        ctx.fillEllipse(in: CGRect(x: 237, y: 345, width: 126, height: 126))
        ctx.move(to: CGPoint(x: 150, y: 190))
        ctx.addCurve(to: CGPoint(x: 450, y: 190), control1: CGPoint(x: 150, y: 380), control2: CGPoint(x: 450, y: 380))
        ctx.closePath()
        ctx.setFillColor(white(0.7))
        ctx.fillPath()
    }
}

func drawCover(_ book: BookArt) -> CGContext {
    let ctx = makeContext(coverWidth, coverHeight, opaque: true)
    let w = CGFloat(coverWidth), h = CGFloat(coverHeight)

    linearGradient(ctx, from: CGPoint(x: 0, y: h), to: CGPoint(x: w, y: 0), [cgColor(book.c1), cgColor(book.c2)])

    // Soft light bloom and a darker foot so white text stays legible.
    linearGradient(ctx, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 260),
                   [CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.35), CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0)])

    drawMotif(ctx, genre: book.genre)

    // Spine shading on the left edge.
    ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.28))
    ctx.fill(CGRect(x: 0, y: 0, width: 22, height: h))
    ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.22))
    ctx.fill(CGRect(x: 22, y: 0, width: 3, height: h))

    // Title: shrink until it fits the title block.
    let textRect = CGRect(x: 56, y: h - 56 - 270, width: w - 56 - 40, height: 270)
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineSpacing = 2
    var size: CGFloat = 72
    var title: NSAttributedString
    repeat {
        title = NSAttributedString(string: book.title, attributes: [
            .font: serifBold(size), .foregroundColor: NSColor.white, .paragraphStyle: paragraph
        ])
        let bounds = title.boundingRect(with: CGSize(width: textRect.width, height: .greatestFiniteMagnitude),
                                        options: [.usesLineFragmentOrigin])
        if bounds.height <= textRect.height { break }
        size -= 2
    } while size > 30
    drawText(ctx, title, in: textRect)

    // Author line.
    ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.55))
    ctx.fill(CGRect(x: 56, y: 118, width: 90, height: 3))
    let author = NSAttributedString(string: book.author.uppercased(), attributes: [
        .font: NSFont.systemFont(ofSize: 30, weight: .semibold),
        .foregroundColor: NSColor(white: 1, alpha: 0.92),
        .kern: 3.0
    ])
    drawText(ctx, author, in: CGRect(x: 56, y: 52, width: w - 56 - 30, height: 56))
    return ctx
}

// MARK: - Logo mark (open book on a navy-to-blue tile)

func drawLogoMark(_ ctx: CGContext, in rect: CGRect, rounded: Bool) {
    ctx.saveGState()
    if rounded {
        ctx.addPath(CGPath(roundedRect: rect, cornerWidth: rect.width * 0.2237, cornerHeight: rect.width * 0.2237, transform: nil))
        ctx.clip()
    }
    linearGradient(ctx, from: CGPoint(x: rect.minX, y: rect.maxY), to: CGPoint(x: rect.maxX, y: rect.minY),
                   [cgColor(0x1A2E4A), cgColor(0x2A6DD9)])

    // Unit coordinates, (0,0) = top-left of the tile.
    func p(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + u * rect.width, y: rect.maxY - v * rect.height)
    }
    func page(mirrored: Bool) -> CGPath {
        func q(_ u: CGFloat, _ v: CGFloat) -> CGPoint { p(mirrored ? 1 - u : u, v) }
        let path = CGMutablePath()
        path.move(to: q(0.495, 0.30))
        path.addCurve(to: q(0.17, 0.34), control1: q(0.40, 0.24), control2: q(0.27, 0.25))
        path.addLine(to: q(0.17, 0.69))
        path.addCurve(to: q(0.495, 0.75), control1: q(0.28, 0.66), control2: q(0.40, 0.68))
        path.closeSubpath()
        return path
    }

    // Soft shadow under the book.
    ctx.setShadow(offset: CGSize(width: 0, height: -rect.height * 0.02), blur: rect.height * 0.04,
                  color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.35))
    ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
    ctx.addPath(page(mirrored: false)); ctx.fillPath()
    ctx.addPath(page(mirrored: true)); ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)

    // Text lines on the pages.
    ctx.setStrokeColor(cgColor(0x2A6DD9, 0.35))
    ctx.setLineWidth(rect.width * 0.014)
    ctx.setLineCap(.round)
    for (i, v) in [0.43, 0.51, 0.59].enumerated() {
        let shorten: CGFloat = i == 2 ? 0.06 : 0
        for mirrored in [false, true] {
            let a = p(mirrored ? 1 - 0.27 : 0.27, CGFloat(v) + 0.012 * CGFloat(i))
            let b = p(mirrored ? 1 - (0.44 - shorten) : 0.44 - shorten, CGFloat(v) - 0.006 + 0.012 * CGFloat(i))
            ctx.move(to: a); ctx.addLine(to: b)
        }
    }
    ctx.strokePath()

    // Spine.
    ctx.setStrokeColor(cgColor(0x1A2E4A, 0.55))
    ctx.setLineWidth(rect.width * 0.012)
    ctx.move(to: p(0.5, 0.30)); ctx.addLine(to: p(0.5, 0.75)); ctx.strokePath()

    // Amber bookmark ribbon.
    ctx.setFillColor(cgColor(0xF5A623))
    ctx.move(to: p(0.60, 0.255)); ctx.addLine(to: p(0.69, 0.255)); ctx.addLine(to: p(0.69, 0.47))
    ctx.addLine(to: p(0.645, 0.42)); ctx.addLine(to: p(0.60, 0.47)); ctx.closePath(); ctx.fillPath()
    ctx.restoreGState()
}

// MARK: - Output

let outputRoot = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Bookstore/Assets.xcassets")

writeJSON(["info": assetInfo], to: outputRoot.appendingPathComponent("Contents.json"))

// Book covers
for book in books {
    let folder = outputRoot.appendingPathComponent("cover_\(book.id).imageset")
    writePNG(drawCover(book), to: folder.appendingPathComponent("cover_\(book.id).png"))
    writeJSON([
        "images": [["filename": "cover_\(book.id).png", "idiom": "universal", "scale": "3x"]],
        "info": assetInfo
    ], to: folder.appendingPathComponent("Contents.json"))
}

// App icon: single 1024 pt opaque image (iOS rounds the corners itself).
do {
    let folder = outputRoot.appendingPathComponent("AppIcon.appiconset")
    let ctx = makeContext(1024, 1024, opaque: true)
    drawLogoMark(ctx, in: CGRect(x: 0, y: 0, width: 1024, height: 1024), rounded: false)
    writePNG(ctx, to: folder.appendingPathComponent("icon-1024.png"))
    writeJSON([
        "images": [["filename": "icon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"]],
        "info": assetInfo
    ], to: folder.appendingPathComponent("Contents.json"))
}

// Launch screen: navy background colour + centred logo with wordmark.
do {
    let colorFolder = outputRoot.appendingPathComponent("LaunchBackground.colorset")
    writeJSON([
        "colors": [[
            "color": ["color-space": "srgb",
                      "components": ["red": "0.102", "green": "0.180", "blue": "0.290", "alpha": "1.000"]],
            "idiom": "universal"
        ]],
        "info": assetInfo
    ], to: colorFolder.appendingPathComponent("Contents.json"))

    let folder = outputRoot.appendingPathComponent("LaunchLogo.imageset")
    var entries: [[String: String]] = []
    for scale in 1...3 {
        let s = CGFloat(scale)
        let width = Int(220 * s), height = Int(250 * s)
        let ctx = makeContext(width, height, opaque: false)
        let mark = CGRect(x: 30 * s, y: height.cg - 160 * s, width: 160 * s, height: 160 * s)
        drawLogoMark(ctx, in: mark, rounded: true)
        let word = NSAttributedString(string: "Bookstore", attributes: [
            .font: serifBold(34 * s), .foregroundColor: NSColor.white
        ])
        let wordWidth = word.size().width
        drawText(ctx, word, in: CGRect(x: (CGFloat(width) - wordWidth) / 2, y: 22 * s, width: wordWidth + 4, height: 50 * s))
        let tagline = NSAttributedString(string: "READ  ·  DISCOVER  ·  ENJOY", attributes: [
            .font: NSFont.systemFont(ofSize: 10 * s, weight: .medium),
            .foregroundColor: NSColor(white: 1, alpha: 0.6), .kern: 1.6 * s
        ])
        // Positioned under the wordmark (bottom-left origin => smaller y is lower).
        let tagWidth = tagline.size().width
        drawText(ctx, tagline, in: CGRect(x: (CGFloat(width) - tagWidth) / 2, y: 2 * s, width: tagWidth + 4, height: 18 * s))
        let name = scale == 1 ? "LaunchLogo.png" : "LaunchLogo@\(scale)x.png"
        writePNG(ctx, to: folder.appendingPathComponent(name))
        entries.append(["filename": name, "idiom": "universal", "scale": "\(scale)x"])
    }
    writeJSON(["images": entries, "info": assetInfo], to: folder.appendingPathComponent("Contents.json"))
}

print("Generated assets in \(outputRoot.path)")

extension Int { var cg: CGFloat { CGFloat(self) } }
