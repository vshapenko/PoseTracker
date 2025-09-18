import Foundation

enum Exercise: String, CaseIterable {
    case squats
    case pushups
    case plank
    case lunges
    case jumpingJacks

    var displayName: String {
        switch self {
        case .squats:
            return "Squats"
        case .pushups:
            return "Push-ups"
        case .plank:
            return "Plank"
        case .lunges:
            return "Lunges"
        case .jumpingJacks:
            return "Jumping Jacks"
        }
    }

    var description: String {
        switch self {
        case .squats:
            return "Lower your hips from a standing position and then stand back up"
        case .pushups:
            return "Lower your body to the ground and push back up using your arms"
        case .plank:
            return "Hold your body in a straight line, supporting yourself on forearms and toes"
        case .lunges:
            return "Step forward and lower your hips until both knees are bent at 90 degrees"
        case .jumpingJacks:
            return "Jump while spreading your legs and raising your arms overhead"
        }
    }

    var targetAngles: [String: ClosedRange<Double>] {
        switch self {
        case .squats:
            return [
                "knee_down": 70...100,
                "knee_up": 160...180,
                "hip_down": 60...90,
                "hip_up": 160...180
            ]
        case .pushups:
            return [
                "elbow_down": 60...90,
                "elbow_up": 160...180,
                "shoulder_alignment": 70...110
            ]
        case .plank:
            return [
                "body_alignment": 160...180,
                "elbow": 85...95
            ]
        case .lunges:
            return [
                "front_knee": 85...95,
                "back_knee": 85...95,
                "hip": 160...180
            ]
        case .jumpingJacks:
            return [
                "arm_spread": 150...180,
                "leg_spread": 40...60
            ]
        }
    }
}