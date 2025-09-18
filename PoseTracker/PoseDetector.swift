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
        case .burpees:
            analyzeBurpee(joints)
        case .deadlifts:
            analyzeDeadlift(joints)
        case .kettlebellSwings:
            analyzeKettlebellSwing(joints)
        case .boxJumps:
            analyzeBoxJump(joints)
        case .wallBalls:
            analyzeWallBall(joints)
        case .thrusters:
            analyzeThruster(joints)
        case .cleanAndJerk:
            analyzeCleanAndJerk(joints)
        case .snatches:
            analyzeSnatch(joints)
        case .doubleUnders:
            analyzeDoubleUnder(joints)
        case .pullUps:
            analyzePullUp(joints)
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

    private func analyzeBurpee(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftShoulder = joints[.leftShoulder],
              let leftWrist = joints[.leftWrist],
              let head = joints[.nose],
              leftHip.confidence > 0.4,
              leftShoulder.confidence > 0.4 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let bodyAlignment = abs(leftShoulder.location.y - leftHip.location.y)
        let handsNearGround = leftWrist.location.y > 0.7
        let isStanding = leftHip.location.y < 0.5

        if handsNearGround && bodyAlignment < 0.2 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good plank position!"
                accuracy = 0.85
            }
        } else if isStanding && leftWrist.location.y < head.location.y {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Excellent burpee!"
                accuracy = 0.95
            } else {
                feedback = "Drop down to plank"
                accuracy = 0.7
            }
        } else {
            feedback = "Transition smoothly"
            accuracy = 0.75
        }
    }

    private func analyzeDeadlift(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftShoulder = joints[.leftShoulder],
              let rightHip = joints[.rightHip],
              let rightKnee = joints[.rightKnee],
              leftHip.confidence > 0.5,
              leftKnee.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let hipHingeAngle = calculateAngle(
            point1: leftShoulder.location,
            vertex: leftHip.location,
            point2: leftKnee.location
        )
        let kneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: CGPoint(x: leftKnee.location.x, y: leftKnee.location.y + 0.3)
        )

        if hipHingeAngle < 90 && kneeAngle > 140 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good hip hinge! Keep back straight"
                accuracy = 0.9
            }
        } else if hipHingeAngle > 150 {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Strong lift! Maintain form"
                accuracy = 0.95
            } else {
                feedback = "Hinge at hips, slight knee bend"
                accuracy = 0.7
            }
        } else {
            feedback = "Keep back straight, drive through hips"
            accuracy = 0.8
        }
    }

    private func analyzeKettlebellSwing(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftShoulder = joints[.leftShoulder],
              let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              leftHip.confidence > 0.5,
              leftShoulder.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let armHeight = (leftWrist.location.y + rightWrist.location.y) / 2
        let shoulderHeight = leftShoulder.location.y
        let hipPosition = leftHip.location.y

        if armHeight > hipPosition && armHeight > shoulderHeight * 0.8 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good backswing position"
                accuracy = 0.85
            }
        } else if armHeight < shoulderHeight {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Powerful hip drive!"
                accuracy = 0.95
            } else {
                feedback = "Swing between legs"
                accuracy = 0.7
            }
        } else {
            feedback = "Use hip drive, not arms"
            accuracy = 0.75
        }
    }

    private func analyzeBoxJump(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftAnkle = joints[.leftAnkle],
              leftHip.confidence > 0.5,
              leftKnee.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let kneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: leftAnkle.location
        )
        let verticalPosition = leftHip.location.y

        if kneeAngle < 110 && verticalPosition > 0.5 {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good squat prep!"
                accuracy = 0.85
            }
        } else if verticalPosition < 0.3 {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Great jump! Land softly"
                accuracy = 0.95
            }
        } else {
            feedback = "Prep, explode up, land soft"
            accuracy = 0.75
        }
    }

    private func analyzeWallBall(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let head = joints[.nose],
              leftKnee.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let kneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: CGPoint(x: leftKnee.location.x, y: leftKnee.location.y + 0.3)
        )
        let armsUp = (leftWrist.location.y < head.location.y) && (rightWrist.location.y < head.location.y)

        if kneeAngle < 100 && !armsUp {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good squat depth!"
                accuracy = 0.85
            }
        } else if kneeAngle > 160 && armsUp {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Nice throw! Catch and repeat"
                accuracy = 0.95
            } else {
                feedback = "Squat with ball at chest"
                accuracy = 0.7
            }
        } else {
            feedback = "Squat deep, throw high"
            accuracy = 0.75
        }
    }

    private func analyzeThruster(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftShoulder = joints[.leftShoulder],
              let leftElbow = joints[.leftElbow],
              let leftWrist = joints[.leftWrist],
              leftKnee.confidence > 0.5,
              leftElbow.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let kneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: CGPoint(x: leftKnee.location.x, y: leftKnee.location.y + 0.3)
        )
        let armExtension = leftWrist.location.y < leftShoulder.location.y

        if kneeAngle < 100 && !armExtension {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good front squat position"
                accuracy = 0.85
            }
        } else if kneeAngle > 160 && armExtension {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Explosive thruster!"
                accuracy = 0.95
            } else {
                feedback = "Squat down with bar racked"
                accuracy = 0.7
            }
        } else {
            feedback = "One fluid motion from squat to press"
            accuracy = 0.8
        }
    }

    private func analyzeCleanAndJerk(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftShoulder = joints[.leftShoulder],
              let leftElbow = joints[.leftElbow],
              let leftWrist = joints[.leftWrist],
              leftShoulder.confidence > 0.5,
              leftElbow.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let elbowAngle = calculateAngle(
            point1: leftShoulder.location,
            vertex: leftElbow.location,
            point2: leftWrist.location
        )
        let overhead = leftWrist.location.y < leftShoulder.location.y - 0.2

        if elbowAngle < 75 && !overhead {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good rack position"
                accuracy = 0.85
            }
        } else if overhead && elbowAngle > 170 {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Strong jerk! Lock it out"
                accuracy = 0.95
            }
        } else {
            feedback = "Clean to shoulders, then jerk overhead"
            accuracy = 0.75
        }
    }

    private func analyzeSnatch(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftHip = joints[.leftHip],
              let leftKnee = joints[.leftKnee],
              let leftShoulder = joints[.leftShoulder],
              let leftWrist = joints[.leftWrist],
              leftHip.confidence > 0.5,
              leftShoulder.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let kneeAngle = calculateAngle(
            point1: leftHip.location,
            vertex: leftKnee.location,
            point2: CGPoint(x: leftKnee.location.x, y: leftKnee.location.y + 0.3)
        )
        let overhead = leftWrist.location.y < leftShoulder.location.y - 0.2

        if kneeAngle < 100 && overhead {
            if exercisePhase != .down {
                exercisePhase = .down
                feedback = "Good overhead squat position"
                accuracy = 0.9
            }
        } else if kneeAngle > 160 && overhead {
            if exercisePhase == .down {
                exercisePhase = .up
                repCount += 1
                feedback = "Powerful snatch!"
                accuracy = 0.95
            } else {
                feedback = "Pull and catch in overhead squat"
                accuracy = 0.7
            }
        } else {
            feedback = "One explosive motion to overhead"
            accuracy = 0.75
        }
    }

    private func analyzeDoubleUnder(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftElbow = joints[.leftElbow],
              leftAnkle.confidence > 0.5 else {
            feedback = "Position your full body in frame"
            accuracy = 0.0
            return
        }

        let feetTogether = abs(leftAnkle.location.x - rightAnkle.location.x) < 0.15
        let jumpHeight = (leftAnkle.location.y + rightAnkle.location.y) / 2
        let wristsLow = leftWrist.location.y > leftElbow.location.y

        if jumpHeight < 0.7 && feetTogether && wristsLow {
            if exercisePhase != .up {
                exercisePhase = .up
                repCount += 1
                feedback = "Good jump! Fast wrist rotation"
                accuracy = 0.9
            }
        } else if jumpHeight > 0.8 {
            if exercisePhase == .up {
                exercisePhase = .down
                feedback = "Keep wrists low and fast"
                accuracy = 0.85
            }
        } else {
            feedback = "Jump higher, rotate wrists faster"
            accuracy = 0.7
        }
    }

    private func analyzePullUp(_ joints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let leftShoulder = joints[.leftShoulder],
              let leftElbow = joints[.leftElbow],
              let leftWrist = joints[.leftWrist],
              let head = joints[.nose],
              leftElbow.confidence > 0.5,
              leftShoulder.confidence > 0.5 else {
            feedback = "Position your upper body in frame"
            accuracy = 0.0
            return
        }

        let elbowAngle = calculateAngle(
            point1: leftShoulder.location,
            vertex: leftElbow.location,
            point2: leftWrist.location
        )
        let chinAboveBar = head.location.y < leftWrist.location.y

        if elbowAngle < 60 && chinAboveBar {
            if exercisePhase != .up {
                exercisePhase = .up
                repCount += 1
                feedback = "Chin over bar! Great pull-up"
                accuracy = 0.95
            }
        } else if elbowAngle > 160 {
            if exercisePhase == .up {
                exercisePhase = .down
                feedback = "Full extension, pull again"
                accuracy = 0.85
            } else {
                feedback = "Pull up to get chin over bar"
                accuracy = 0.7
            }
        } else {
            feedback = "Pull through elbows, chin to bar"
            accuracy = 0.75
        }
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