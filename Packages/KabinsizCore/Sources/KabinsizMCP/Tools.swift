import BodyGeometry
import CoreGraphics
import DomainContracts
import Foundation
import ProductCapture

/// One MCP tool. Adding a tool is one `MCPTool` value appended to `ToolTable.all`.
struct MCPTool: Sendable {
    let name: String
    let title: String
    let description: String
    /// JSON Schema for `arguments`.
    let inputSchema: JSONValue
    let run: @Sendable (_ arguments: [String: JSONValue], _ context: ToolContext) async throws -> JSONValue

    var listing: JSONValue {
        ["name": .string(name), "title": .string(title), "description": .string(description), "inputSchema": inputSchema]
    }
}

struct ToolContext: Sendable {
    let paths: PathGuard
}

/// The caller sent arguments the schema does not allow: a JSON-RPC `-32602`.
struct InvalidArguments: Error, CustomStringConvertible {
    let description: String
}

/// The tool ran and failed (unreadable image, path refused): returned as `isError: true` so the
/// calling agent can read why.
struct ToolFailure: Error, CustomStringConvertible {
    let description: String
}

enum ToolTable {
    static let all: [MCPTool] = [
        analyzeGarmentPhoto, readProductLabel, bodyProfileDefaults,
        // V37 readers (Tools+V37.swift).
        measureFlatGarment, analyzePersonPhoto, draftPatternSVG,
    ]

    static func named(_ name: String) -> MCPTool? { all.first { $0.name == name } }

    // MARK: Shared argument helpers

    static let pathSchema: JSONValue = [
        "type": "string",
        "description": "Absolute path to a JPEG/PNG/HEIC file under the Kabinsiz repository or the system temp directory. Fixtures only, not personal photos.",
    ]

    static func requiredString(_ key: String, _ arguments: [String: JSONValue]) throws -> String {
        guard let value = arguments[key]?.stringValue, !value.isEmpty else { throw InvalidArguments(description: "'\(key)' (string) is required") }
        return value
    }

    static func rejectUnknown(_ arguments: [String: JSONValue], allowed: Set<String>) throws {
        let extra = Set(arguments.keys).subtracting(allowed)
        guard extra.isEmpty else { throw InvalidArguments(description: "unknown argument(s): \(extra.sorted().joined(separator: ", "))") }
    }

    /// Checks the path, reads the bytes and decodes a downsampled, upright bitmap (EXIF dropped).
    static func loadImage(_ arguments: [String: JSONValue], _ context: ToolContext) throws -> (CGImage, String) {
        let raw = try requiredString("path", arguments)
        let path: String
        do { path = try context.paths.check(raw) } catch { throw ToolFailure(description: error.description) }
        guard let data = FileManager.default.contents(atPath: path), let image = ProductLabelReader.image(from: data) else {
            throw ToolFailure(description: "not a readable image: \(path)")
        }
        return (image, path)
    }

    static func round(_ value: Double, _ places: Double = 1000) -> JSONValue { .number((value * places).rounded() / places) }

    // MARK: Tools

    static let analyzeGarmentPhoto = MCPTool(
        name: "analyze_garment_photo",
        title: "Garment photo analysis (on device)",
        description: "Cuts a garment out of a photo on this Mac with Apple Vision (or a plain-background fallback) and suggests a colour name and a category. Suggestions only: the app asks the user to confirm. No network.",
        inputSchema: [
            "type": "object",
            "properties": [
                "path": pathSchema,
                "useVision": ["type": "boolean", "description": "Use the Vision foreground mask (default true). False forces the plain-background method."],
            ],
            "required": ["path"],
            "additionalProperties": false,
        ],
        run: { arguments, context in
            try rejectUnknown(arguments, allowed: ["path", "useVision"])
            let (image, path) = try loadImage(arguments, context)
            let analysis: GarmentPhotoAnalysis
            do {
                let useVision = arguments["useVision"]?.boolValue ?? true
                analysis = try await VisionLane.run { try GarmentPhotoAnalyzer.analyze(image, useVision: useVision) }
            } catch {
                throw ToolFailure(description: "analysis failed: \(error)")
            }
            var category: JSONValue = .null
            if let c = analysis.categorySuggestion {
                category = ["category": .string(c.category.rawValue), "displayName": .string(c.category.displayName),
                            "source": .string(c.visionLabel), "confidence": round(Double(c.confidence))]
            }
            let b = analysis.bounds
            return [
                "path": .string(path),
                "imageSize": ["width": .number(Double(image.width)), "height": .number(Double(image.height))],
                "colour": ["name": .string(analysis.colour.name), "isNeutral": .bool(analysis.colour.isNeutral),
                           "rgb": .array([round(analysis.colourRGB.x), round(analysis.colourRGB.y), round(analysis.colourRGB.z)])],
                "categorySuggestion": category,
                "cutoutMethod": .string(analysis.method.rawValue),
                "coverage": round(analysis.coverage),
                "bounds": ["x": round(b.minX, 1), "y": round(b.minY, 1), "width": round(b.width, 1), "height": round(b.height, 1)],
                "summaryLine": .string(analysis.summaryLine),
                "evidence": "ON_DEVICE_SUGGESTION_NOT_CONFIRMED",
            ]
        }
    )

    static let readProductLabel = MCPTool(
        name: "read_product_label",
        title: "Product label reader (on device)",
        description: "Reads barcodes (EAN/UPC/Code128/QR/…) and printed text from a label photo with Apple Vision on this Mac. Payloads are returned as text and never opened. No network.",
        inputSchema: [
            "type": "object",
            "properties": ["path": pathSchema],
            "required": ["path"],
            "additionalProperties": false,
        ],
        run: { arguments, context in
            try rejectUnknown(arguments, allowed: ["path"])
            let (image, path) = try loadImage(arguments, context)
            let reading: ProductLabelReading
            do { reading = try await ProductLabelReader.read(image) } catch {
                throw ToolFailure(description: "label reading failed: \(error)")
            }
            return [
                "path": .string(path),
                "barcodes": .array(reading.barcodes.map { ["payload": .string($0.payload), "symbology": .string($0.symbology)] }),
                "textLines": .array(reading.textLines.map(JSONValue.string)),
                "unreadParts": .array(reading.unreadParts.map { .string($0.rawValue) }),
            ]
        }
    )

    static let bodyProfileDefaults = MCPTool(
        name: "body_profile_defaults",
        title: "Body form start values",
        description: "Start values for a new figure of the chosen body form (FEMININE, MASCULINE, NEUTRAL). Drawing starting points, not measurements, norms or targets. The form is always the user's choice (ADR-017), never inferred.",
        inputSchema: [
            "type": "object",
            "properties": [
                "form": ["type": "string", "enum": .array(BodyForm.allCases.map { .string($0.rawValue) })],
            ],
            "required": ["form"],
            "additionalProperties": false,
        ],
        run: { arguments, _ in
            try rejectUnknown(arguments, allowed: ["form"])
            let raw = try requiredString("form", arguments)
            guard let form = BodyForm(rawValue: raw) else {
                throw InvalidArguments(description: "form must be one of \(BodyForm.allCases.map(\.rawValue).joined(separator: ", "))")
            }
            let profile = BodyProfile.neutral(form: form)
            let values: [JSONValue] = BodyParameter.allCases.map { p in
                [
                    "parameter": .string(p.rawValue),
                    "label": .string(form.label(p)),
                    "startCm": .number(profile[p].length.centimeters),
                    "safeRangeCm": .array([.number(p.safeRange.lowerBound), .number(p.safeRange.upperBound)]),
                    "source": .string(profile[p].source.rawValue),
                ]
            }
            return [
                "form": .string(form.rawValue),
                "displayName": .string(form.displayName),
                "values": .array(values),
                "note": "Başlangıç (ölçü değil): a drawing start, not a measurement",
            ]
        }
    )
}
