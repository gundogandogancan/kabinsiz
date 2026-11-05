import BodyGeometry
import CoreGraphics
import Foundation
import GarmentPattern
import ProductCapture
import SelfModel

// V37 tools over the readers other work packages added (V37-01 SelfModel, V37-03 FlatGarmentMeasurer,
// V37-04 PatternDrafter).
// Each is one `MCPTool` value listed in `ToolTable.all`.

extension ToolTable {
    static func rgb(_ v: SIMD3<Double>) -> JSONValue { .array([round(v.x), round(v.y), round(v.z)]) }

    static let measureFlatGarment = MCPTool(
        name: "measure_flat_garment",
        title: "Flat-lay garment measurement (A4 reference)",
        description: "Measures a garment lying flat next to a white A4 sheet: length and widths in cm with ± uncertainty, from the sheet's scale. A photo estimate, not a tape measure. Refuses (with a reason) when the sheet is missing, not A4, too small or the photo too tilted. No network.",
        inputSchema: [
            "type": "object",
            "properties": [
                "path": pathSchema,
                "layout": ["type": "string", "enum": ["TOP", "BOTTOM"], "description": "Optional; decided from the outline when absent."],
                "useVision": ["type": "boolean", "description": "Use Vision for the sheet and the garment mask (default true)."],
            ],
            "required": ["path"],
            "additionalProperties": false,
        ],
        run: { arguments, context in
            try rejectUnknown(arguments, allowed: ["path", "layout", "useVision"])
            var layout: FlatGarmentLayout?
            if let raw = arguments["layout"] {
                guard let text = raw.stringValue, let value = FlatGarmentLayout(rawValue: text) else {
                    throw InvalidArguments(description: "layout must be TOP or BOTTOM")
                }
                layout = value
            }
            let (image, path) = try loadImage(arguments, context)
            let m: FlatGarmentMeasurement
            do {
                let useVision = arguments["useVision"]?.boolValue ?? true, chosen = layout
                m = try await VisionLane.run { try FlatGarmentMeasurer.measure(image, useVision: useVision, layout: chosen) }
            } catch let failure as FlatGarmentMeasurer.Failure {
                throw ToolFailure(description: "\(failure): \(failure.reason)")
            } catch {
                throw ToolFailure(description: "measurement failed: \(error)")
            }
            return [
                "path": .string(path),
                "source": .string(m.source.rawValue),
                "layout": .string(m.layout.rawValue),
                "values": .array(m.values.map {
                    ["kind": .string($0.kind.rawValue), "name": .string($0.name), "cm": round($0.cm, 10), "uncertaintyCm": round($0.uncertaintyCm, 10)]
                }),
                "sheet": ["method": .string(m.sheet.method.rawValue), "measuredRatio": round(m.sheet.measuredRatio),
                          "perspectiveIndex": round(m.sheet.perspectiveIndex), "shortSidePx": round(m.sheet.shortSidePx, 10)],
                "maskMethod": .string(m.maskMethod.rawValue),
                "limitations": .array(m.limitations.map(JSONValue.string)),
                "summaryLines": .array(m.summaryLines.map(JSONValue.string)),
            ]
        }
    )

    /// The self-model readers composed in the same order as `SelfModelPipeline` (pose → mask → appearance,
    /// body, worn garments), without the Octopus run and without any face crop or face box: this tool
    /// returns colours, classes and estimates only. Identity is never read.
    static let analyzePersonPhoto = MCPTool(
        name: "analyze_person_photo",
        title: "Self-model reading of a person photo (no identity)",
        description: "Reads a FIXTURE photo of one person on this Mac: skin and hair colour, hair-length class and head ratio (no identity, no face template, no face crop), body-width estimates in cm with ranges (only when userHeightCm is given; an estimate, not a measurement), and the colours/kinds of the garments worn. Body form, sex and age are never inferred. No network.",
        inputSchema: [
            "type": "object",
            "properties": [
                "path": pathSchema,
                "userHeightCm": ["type": "number", "description": "The person's typed height in cm; the only source of scale."],
                "useVision": ["type": "boolean", "description": "Use the Vision person mask (default true)."],
            ],
            "required": ["path"],
            "additionalProperties": false,
        ],
        run: { arguments, context in
            try rejectUnknown(arguments, allowed: ["path", "userHeightCm", "useVision"])
            var height: Double?
            if let raw = arguments["userHeightCm"] {
                guard case .number(let h) = raw else { throw InvalidArguments(description: "userHeightCm must be a number") }
                height = h
            }
            let (image, path) = try loadImage(arguments, context)
            let keypoints: BodyKeypoints
            // Vision work runs on VisionLane, off the cooperative pool (see VisionSerial).
            do { keypoints = try await VisionLane.run { try PoseReader.read(image) } } catch { throw ToolFailure(description: "pose: \(error)") }
            let mask: PersonMask
            let maskMethod: PersonMaskReader.Method
            do {
                let useVision = arguments["useVision"]?.boolValue ?? true
                (mask, maskMethod) = try await VisionLane.run { try PersonMaskReader.read(image, useVision: useVision, keypoints: keypoints) }
            } catch {
                throw ToolFailure(description: "person mask: \(error)")
            }
            var out: [String: JSONValue] = ["path": .string(path), "maskMethod": .string(maskMethod.rawValue),
                                            "evidence": "ON_DEVICE_ESTIMATE_NOT_CONFIRMED"]
            var skin: SIMD3<Double>?
            do {
                let a = try AppearanceReader.read(image, keypoints: keypoints, mask: mask)
                skin = a.skinRGB
                out["appearance"] = [
                    "skinRGB": rgb(a.skinRGB), "skinToneStep": .number(Double(a.skinToneStep)),
                    "hairRGB": a.hairRGB.map(rgb) ?? .null, "hairColourName": a.hairColourName.map(JSONValue.string) ?? .null,
                    "hairLength": .string(a.hairLength.rawValue), "headAspect": round(a.headAspect),
                    "limitations": .array(a.limitations.map(JSONValue.string)),
                ]
            } catch {
                out["appearance"] = ["error": .string("\(error)")]
            }
            do {
                let b = try BodyProportionReader.read(keypoints: keypoints, mask: mask, userHeightCm: height)
                out["body"] = [
                    "label": "fotoğraftan tahmin · ölçü değil",
                    "heightUsedCm": round(b.heightUsedCm, 10),
                    "estimates": .array(b.estimates.map {
                        ["parameter": .string($0.parameter.rawValue), "cm": round($0.centimeters, 10),
                         "rangeCm": .array([round($0.low, 10), round($0.high, 10)]), "basis": .string($0.basis)]
                    }),
                    "shoulderToHip": round(b.shoulderToHip), "waistToHip": round(b.waistToHip),
                    "limitations": .array(b.limitations.map(JSONValue.string)),
                ]
            } catch {
                out["body"] = ["error": .string("\(error)")]
            }
            if let skin {
                do {
                    let w = try await VisionLane.run { try WornGarmentReader.read(image, keypoints: keypoints, mask: mask, skin: skin) }
                    out["worn"] = [
                        "garments": .array(w.garments.map {
                            ["slot": .string($0.slot.rawValue), "category": .string($0.category.rawValue), "form": .string($0.form),
                             "colourName": .string($0.colourName), "colourRGB": rgb($0.colourRGB), "basis": .string($0.basis),
                             "needsUserChoice": .bool($0.needsUserChoice)]
                        }),
                        "limitations": .array(w.limitations.map(JSONValue.string)),
                    ]
                } catch {
                    out["worn"] = ["error": .string("\(error)")]
                }
            } else {
                out["worn"] = ["error": "skipped: worn garments need the skin colour to separate sleeves from arms"]
            }
            return .object(out)
        }
    )

    /// A basic block from start values or typed measurements, as a 1:1 SVG (mm). Returned inline: the
    /// server writes no files.
    static let draftPatternSVG = MCPTool(
        name: "draft_pattern_svg",
        title: "Basic sewing block as a 1:1 SVG",
        description: "Drafts a basic sewing block (not a brand pattern, not a fit promise) for a garment kind from a body form's start values, overridden by any typed body measurements (cm), plus wearing ease. Returns the SVG text (millimetre units, 10 cm check square) and a piece summary. No network, no files written.",
        inputSchema: [
            "type": "object",
            "properties": [
                "kind": ["type": "string", "enum": .array(GarmentKind.allCases.map { .string($0.rawValue) })],
                "form": ["type": "string", "enum": .array(BodyForm.allCases.map { .string($0.rawValue) }), "description": "Default NEUTRAL; always the user's choice."],
                "measurementsCm": [
                    "type": "object",
                    "description": "Typed body measurements in cm; keys are BodyParameter values.",
                    "properties": .object(Dictionary(uniqueKeysWithValues: BodyParameter.allCases.map { ($0.rawValue, ["type": "number"] as JSONValue) })),
                    "additionalProperties": false,
                ],
                "easeCm": [
                    "type": "object",
                    "properties": ["chestCm": ["type": "number"], "waistCm": ["type": "number"], "hipCm": ["type": "number"]],
                    "required": ["chestCm", "waistCm", "hipCm"],
                    "additionalProperties": false,
                ],
            ],
            "required": ["kind"],
            "additionalProperties": false,
        ],
        run: { arguments, _ in
            try rejectUnknown(arguments, allowed: ["kind", "form", "measurementsCm", "easeCm"])
            guard let kind = GarmentKind(rawValue: try requiredString("kind", arguments)) else {
                throw InvalidArguments(description: "kind must be one of \(GarmentKind.allCases.map(\.rawValue).joined(separator: ", "))")
            }
            var form = BodyForm.neutral
            if let raw = arguments["form"] {
                guard let text = raw.stringValue, let value = BodyForm(rawValue: text) else { throw InvalidArguments(description: "form is not a BodyForm") }
                form = value
            }
            var profile = BodyProfile.neutral(form: form)
            for (key, value) in arguments["measurementsCm"]?.objectValue ?? [:] {
                guard let parameter = BodyParameter(rawValue: key), case .number(let cm) = value else {
                    throw InvalidArguments(description: "measurementsCm.\(key) is not a BodyParameter with a number")
                }
                do { profile = try profile.applying(.measured(parameter, cm, .centimeters)) } catch {
                    throw ToolFailure(description: "measurement \(key)=\(cm) refused: \(error)")
                }
            }
            var ease: PatternEase?
            if let e = arguments["easeCm"]?.objectValue {
                guard case .number(let c)? = e["chestCm"], case .number(let w)? = e["waistCm"], case .number(let h)? = e["hipCm"] else {
                    throw InvalidArguments(description: "easeCm needs chestCm, waistCm and hipCm numbers")
                }
                ease = PatternEase(chestCm: c, waistCm: w, hipCm: h)
            }
            let pattern: SewingPattern
            do { pattern = try PatternDrafter.block(for: profile, kind: kind, ease: ease) } catch {
                throw ToolFailure(description: "drafting failed: \(error)")
            }
            let sheet = pattern.layout()
            return [
                "kind": .string(kind.rawValue),
                "form": .string(form.rawValue),
                "provenance": .string(pattern.provenance),
                "ease": pattern.ease.map { ["chestCm": .number($0.chestCm), "waistCm": .number($0.waistCm), "hipCm": .number($0.hipCm)] } ?? .null,
                "pieces": .array(pattern.pieces.map {
                    ["name": .string($0.name), "role": .string($0.role.rawValue), "cutCount": .number(Double($0.cutCount)),
                     "mirror": .bool($0.mirror), "seamAllowanceCm": .number($0.seamAllowanceCm), "areaCm2": round(abs($0.areaCm2), 10)]
                }),
                "sheetMm": ["width": round(sheet.widthMm, 10), "height": round(sheet.heightMm, 10)],
                "label": "temel blok · marka kalıbı değil · uyum vaadi değil",
                "svg": .string(pattern.svg()),
            ]
        }
    )
}
