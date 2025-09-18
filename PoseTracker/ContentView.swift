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
                        .onChange(of: selectedExercise) { _, newValue in
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
            ForEach(Exercise.allCases, id: \.self) { exercise in
                Button(exercise.displayName) {
                    selectedExercise = exercise
                }
            }
        } label: {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                Text(selectedExercise.displayName)
                Image(systemName: "chevron.down")
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
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