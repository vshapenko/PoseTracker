import SwiftUI

struct ContentView: View {
    @StateObject private var poseDetector = PoseDetector()
    @State private var selectedExercise: Exercise = .squats

    var body: some View {
        ZStack {
            CameraView(poseDetector: poseDetector)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    ExerciseSelector(selectedExercise: $selectedExercise)
                        .onChange(of: selectedExercise) { newValue in
                            poseDetector.currentExercise = newValue
                        }
                    Spacer()
                }
                .padding()

                Spacer()

                FeedbackView(poseDetector: poseDetector)
                    .padding()
            }
        }
        .onAppear {
            poseDetector.startSession()
            poseDetector.currentExercise = selectedExercise
        }
    }
}

struct ExerciseSelector: View {
    @Binding var selectedExercise: Exercise

    var body: some View {
        Menu {
            Section("Basic Exercises") {
                ForEach([Exercise.squats, .pushups, .plank, .lunges, .jumpingJacks], id: \.self) { exercise in
                    Button(exercise.displayName) {
                        selectedExercise = exercise
                    }
                }
            }
            Section("CrossFit") {
                ForEach([Exercise.burpees, .thrusters, .wallBalls, .boxJumps, .doubleUnders, .pullUps], id: \.self) { exercise in
                    Button(exercise.displayName) {
                        selectedExercise = exercise
                    }
                }
            }
            Section("Olympic Lifts") {
                ForEach([Exercise.deadlifts, .cleanAndJerk, .snatches, .kettlebellSwings], id: \.self) { exercise in
                    Button(exercise.displayName) {
                        selectedExercise = exercise
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: iconForExercise(selectedExercise))
                Text(selectedExercise.displayName)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    private func iconForExercise(_ exercise: Exercise) -> String {
        switch exercise {
        case .squats, .lunges, .boxJumps:
            return "figure.strengthtraining.functional"
        case .pushups, .plank, .burpees:
            return "figure.core.training"
        case .deadlifts, .cleanAndJerk, .snatches, .kettlebellSwings:
            return "figure.strengthtraining.traditional"
        case .pullUps:
            return "figure.climbing"
        case .jumpingJacks, .doubleUnders:
            return "figure.jumprope"
        case .thrusters, .wallBalls:
            return "figure.highintensity.intervaltraining"
        }
    }
}

struct FeedbackView: View {
    @ObservedObject var poseDetector: PoseDetector

    var body: some View {
        VStack(spacing: 10) {
            if poseDetector.isDetectingPose {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Pose Detected")
                        .fontWeight(.semibold)
                }

                Text("Accuracy: \(Int(poseDetector.accuracy * 100))%")
                    .font(.title2)

                if let feedback = poseDetector.feedback {
                    Text(feedback)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Text("Reps: \(poseDetector.repCount)")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.yellow)
                    Text("Position yourself in frame")
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}