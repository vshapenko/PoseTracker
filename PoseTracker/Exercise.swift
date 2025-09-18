import Foundation

enum Exercise: String, CaseIterable {
    case squats
    case pushups
    case plank
    case lunges
    case jumpingJacks
    case burpees
    case deadlifts
    case kettlebellSwings
    case boxJumps
    case wallBalls
    case thrusters
    case cleanAndJerk
    case snatches
    case doubleUnders
    case pullUps

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
        case .burpees:
            return "Burpees"
        case .deadlifts:
            return "Deadlifts"
        case .kettlebellSwings:
            return "Kettlebell Swings"
        case .boxJumps:
            return "Box Jumps"
        case .wallBalls:
            return "Wall Balls"
        case .thrusters:
            return "Thrusters"
        case .cleanAndJerk:
            return "Clean & Jerk"
        case .snatches:
            return "Snatches"
        case .doubleUnders:
            return "Double Unders"
        case .pullUps:
            return "Pull-ups"
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
        case .burpees:
            return "Drop to plank, perform pushup, jump feet to hands, jump up with arms overhead"
        case .deadlifts:
            return "Lift weight from ground to hip level, keeping back straight"
        case .kettlebellSwings:
            return "Swing kettlebell between legs and up to shoulder height using hip drive"
        case .boxJumps:
            return "Jump onto elevated platform and step or jump back down"
        case .wallBalls:
            return "Squat with medicine ball, then throw it to target on wall"
        case .thrusters:
            return "Front squat into overhead press in one fluid motion"
        case .cleanAndJerk:
            return "Lift barbell from ground to shoulders, then overhead"
        case .snatches:
            return "Lift weight from ground to overhead in one motion"
        case .doubleUnders:
            return "Jump rope passes under feet twice per jump"
        case .pullUps:
            return "Pull body up until chin is over the bar"
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
        case .burpees:
            return [
                "plank_position": 160...180,
                "squat_knee": 70...100,
                "jump_extension": 160...180
            ]
        case .deadlifts:
            return [
                "hip_hinge": 70...90,
                "knee_bend": 140...160,
                "back_angle": 160...180
            ]
        case .kettlebellSwings:
            return [
                "hip_hinge": 60...90,
                "arm_extension": 150...180,
                "knee_slight_bend": 140...170
            ]
        case .boxJumps:
            return [
                "squat_prep": 80...110,
                "jump_extension": 160...180,
                "landing_absorption": 90...120
            ]
        case .wallBalls:
            return [
                "squat_depth": 70...100,
                "arm_extension": 160...180,
                "catch_position": 90...120
            ]
        case .thrusters:
            return [
                "squat_depth": 70...100,
                "overhead_extension": 170...180,
                "elbow_rack": 45...75
            ]
        case .cleanAndJerk:
            return [
                "pull_position": 120...150,
                "rack_position": 45...75,
                "overhead_lockout": 170...180
            ]
        case .snatches:
            return [
                "pull_position": 120...150,
                "overhead_squat": 70...100,
                "overhead_lockout": 170...180
            ]
        case .doubleUnders:
            return [
                "arm_position": 75...105,
                "jump_height": 160...180,
                "wrist_rotation": 90...120
            ]
        case .pullUps:
            return [
                "arm_extension_down": 160...180,
                "arm_flexion_up": 30...60,
                "shoulder_engagement": 120...150
            ]
        }
    }
}