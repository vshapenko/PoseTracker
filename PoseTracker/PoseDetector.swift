import Vision
import AVFoundation
import UIKit
import SwiftUI

class PoseDetector: NSObject, ObservableObject {
    @Published var isDetectingPose = false
    @Published var accuracy: Double = 0.0
    @Published var feedback: String?
    @Published var repCount = 0
    @Published var currentExercise: Exercise = .squats

    private var detectionRequest: VNDetectHumanBodyPoseRequest?
    private var previousPoseObservation: VNHumanBodyPoseObservation?
    private var exercisePhase: ExercisePhase = .neutral
    private var jointAngles: [JointAngle] = []

    override init() {
        super.init()
        setupPoseDetection()
    }

    private func setupPoseDetection() {
        detectionRequest = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            if let observation = request.results?.first as? VNHumanBodyPoseObservation {
                self?.processPoseObservation(observation)
            }
        }
    }

    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let detectionRequest = detectionRequest else { return }

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        do {
            try requestHandler.perform([detectionRequest])
        } catch {
            print("Failed to perform pose detection: \(error)")
        }
    }

    private func processPoseObservation(_ observation: VNHumanBodyPoseObservation) {
        DispatchQueue.main.async {
            self.isDetectingPose = true
            self.analyzePose(observation)
            self.previousPoseObservation = observation
        }
    }

    private func analyzePose(_ observation: VNHumanBodyPoseObservation) {
        guard let joints = try? observation.recognizedPoints(.all) else { return }

        switch currentExercise {
        case .squats:
            analyzeSquat(joints)
        case .pushups:
            analyzePushup(joints)
        case .plank:
            analyzePlank(joints)
        case .lunges:
            analyzeLunge(joints)
        case .jumpingJacks:
            analyzeJumpingJack(joints)
        }
    }

    private func analyzeSquat(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftAnkle = joints[.leftAnkle],
              let rightHip = joints[.rightHip],
              let rightKnee = joints[.rightKnee],
              let rightAnkle = joints[.rightAnkle],
              leftHip.confidence > 0.5,
              leftKnee.confidence > 0.5,
              leftAnkle.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let leftKneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: leftAnkle.location
        )
        let rightKneeAngle = calculateAngle(
            point1: rightHip.location,
            vertex: rightKnee.location,
            point2: rightAnkle.location
        )

        let avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2

        if avgKneeAngle < 100 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good depth! Now push up"
                accuracy = 0.9
            }
        } else if avgKneeAngle > 160 {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Great rep! Keep going"
                accuracy = 0.95
            } else {
                feedback = "Lower down slowly"
                accuracy = 0.7
            }
        } else {
            feedback = "Keep moving smoothly"
            accuracy = 0.8
        }
    }

    private func analyzePushup(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftShoulder = joints[.leftShoulder],
              let leftElbow = joints[.leftElbow],
              let leftWrist = joints[.leftWrist],
              let rightShoulder = joints[.rightShoulder],
              let rightElbow = joints[.rightElbow],
              let rightWrist = joints[.rightWrist],
              leftElbow.confidence > 0.5,
              rightElbow.confidence > 0.5 else {
            feedback = "Position your upper body in frame"
            accuracy = 0.0
            return
        }

        let leftElbowAngle = calculateAngle(
            point1: leftShoulder.location,
            vertex: leftElbow.location,
            point2: leftWrist.location
        )
        let rightElbowAngle = calculateAngle(
            point1: rightShoulder.location,
            vertex: rightElbow.location,
            point2: rightWrist.location
        )

        let avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2

        if avgElbowAngle < 90 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good depth! Push back up"
                accuracy = 0.9
            }
        } else if avgElbowAngle > 160 {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Excellent pushup!"
                accuracy = 0.95
            } else {
                feedback = "Lower your chest to the ground"
                accuracy = 0.7
            }
        } else {
            feedback = "Maintain steady movement"
            accuracy = 0.8
        }
    }

    private func analyzePlank(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftShoulder = joints[.leftShoulder],
              let leftHip = joints[.leftHip],
              let leftAnkle = joints[.leftAnkle],
              let rightShoulder = joints[.rightShoulder],
              let rightHip = joints[.rightHip],
              let rightAnkle = joints[.rightAnkle],
              leftShoulder.confidence > 0.4,
              leftHip.confidence > 0.4 else {
            feedback = "Position your full body in frame sideways"
            accuracy = 0.0
            return
        }

        let leftAlignment = abs(leftShoulder.location.y - leftHip.location.y)
        let rightAlignment = abs(rightShoulder.location.y - rightHip.location.y)
        let avgAlignment = (leftAlignment + rightAlignment) / 2

        if avgAlignment < 0.1 {
            feedback = "Perfect plank position! Hold it"
            accuracy = 0.95
            if exercisePhase != .down {
                exercisePhase = .down
                repCount += 1
            }
        } else if avgAlignment < 0.2 {
            feedback = "Good form, keep your body straight"
            accuracy = 0.8
        } else {
            feedback = "Align your shoulders and hips"
            accuracy = 0.6
        }
    }

    private func analyzeLunge(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftAnkle = joints[.leftAnkle],
              let rightHip = joints[.rightHip],
              let rightKnee = joints[.rightKnee],
              let rightAnkle = joints[.rightAnkle],
              leftKnee.confidence > 0.5,
              rightKnee.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let leftKneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: leftAnkle.location
        )
        let rightKneeAngle = calculateAngle(
            point1: rightHip.location,
            vertex: rightKnee.location,
            point2: rightAnkle.location
        )

        let frontKneeAngle = min(leftKneeAngle, rightKneeAngle)
        let backKneeAngle = max(leftKneeAngle, rightKneeAngle)

        if frontKneeAngle < 100 && backKneeAngle > 140 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Great lunge depth!"
                accuracy = 0.9
            }
        } else if frontKneeAngle > 160 && backKneeAngle > 160 {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Good rep! Switch legs"
                accuracy = 0.95
            } else {
                feedback = "Step forward and lower down"
                accuracy = 0.7
            }
        } else {
            feedback = "Keep front knee at 90 degrees"
            accuracy = 0.75
        }
    }

    private func analyzeJumpingJack(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let head = joints[.nose],
              leftWrist.confidence > 0.5,
              rightWrist.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let armSpread = abs(leftWrist.location.x - rightWrist.location.x)
        let legSpread = abs(leftAnkle.location.x - rightAnkle.location.x)
        let armsAboveHead = (leftWrist.location.y < head.location.y) && (rightWrist.location.y < head.location.y)

        if armSpread > 0.5 && legSpread > 0.3 && armsAboveHead {
            if exercisePhase != .up {
                exercisePhase = .up
                feedback = "Arms up, legs apart!"
                accuracy = 0.9
            }
        } else if armSpread < 0.2 && legSpread < 0.15 {
            if exercisePhase == .up {
                exercisePhase = .down
                repCount += 1
                feedback = "Great jumping jack!"
                accuracy = 0.95
            } else {
                feedback = "Jump and spread arms and legs"
                accuracy = 0.7
            }
        } else {
            feedback = "Coordinate arms and legs"
            accuracy = 0.75
        }
    }

    private func calculateAngle(point1: CGPoint, vertex: CGPoint, point2: CGPoint) -> Double {
        let v1 = CGPoint(x: point1.x - vertex.x, y: point1.y - vertex.y)
        let v2 = CGPoint(x: point2.x - vertex.x, y: point2.y - vertex.y)

        let dotProduct = v1.x * v2.x + v1.y * v2.y
        let magnitude1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let magnitude2 = sqrt(v2.x * v2.x + v2.y * v2.y)

        let cosAngle = dotProduct / (magnitude1 * magnitude2)
        let angleRadians = acos(min(max(cosAngle, -1), 1))
        return angleRadians * 180 / .pi
    }

    func startSession() {
        repCount = 0
        exercisePhase = .neutral
    }
}

enum ExercisePhase {
    case neutral
    case up
    case down
}

struct JointAngle {
    let joint: VNHumanBodyPoseObservation.JointName
    let angle: Double
}