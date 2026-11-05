import BodyGeometry
import Foundation

/// What the user accepted from the self-model for the 3D figure: skin, hair and, only with its own opt-in,
/// the face texture. Stored in the Vault (body domain, LOCAL_SENSITIVE); one tap deletes it and the figure
/// goes back to the neutral form. Nothing here can identify the person in another photo.
public struct PersonalLook: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public var skinRGB: SIMD3<Double>
    public var hairRGB: SIMD3<Double>?
    public var hairLength: HairLength
    /// The face crop for the head (opaque PNG, edge blended to `skinRGB`). `nil` = no face on the figure.
    public var faceTexturePNG: Data?
    /// The user tapped "bu bana benziyor" (v3.5 §D). Without it the face texture is never drawn.
    public var confirmedLikeness: Bool
    public var acceptedAt: Date

    public init(skinRGB: SIMD3<Double>, hairRGB: SIMD3<Double>?, hairLength: HairLength, faceTexturePNG: Data?,
                confirmedLikeness: Bool, acceptedAt: Date) {
        self.skinRGB = skinRGB
        self.hairRGB = hairRGB
        self.hairLength = hairLength
        self.faceTexturePNG = faceTexturePNG
        self.confirmedLikeness = confirmedLikeness
        self.acceptedAt = acceptedAt
    }

    /// The face is drawn only when there is a texture and the user confirmed the likeness.
    public var drawsFace: Bool { faceTexturePNG != nil && confirmedLikeness }
}

public extension SelfModelProposal {
    /// The look the user accepts. `withFace` is the separate face opt-in.
    func look(withFace: Bool, confirmedLikeness: Bool, at date: Date = Date()) -> PersonalLook? {
        guard let a = appearance else { return nil }
        return PersonalLook(skinRGB: a.skinRGB, hairRGB: a.hairRGB, hairLength: a.hairLength,
                            faceTexturePNG: withFace ? faceTexturePNG : nil, confirmedLikeness: withFace && confirmedLikeness,
                            acceptedAt: date)
    }

    /// Body edits for the rows the user ticked. Height is the user's own typed value (a measurement);
    /// everything else is a photo estimate that shapes the figure and never feeds size advice.
    func bodyEdits(accepting parameters: Set<BodyParameter>) -> [BodyEdit] {
        guard let body else { return [] }
        return body.estimates.filter { parameters.contains($0.parameter) }.map { e in
            BodyEdit(e.parameter, BodyLength(e.centimeters, .centimeters), source: e.parameter == .height ? .userMeasured : .photoEstimated)
        }
    }
}
