import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    let poseDetector: PoseDetector

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.poseDetector = poseDetector
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var poseDetector: PoseDetector?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInitiated)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: videoQueue)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            videoOutput = output

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = .portrait
            view.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer

            captureSession = session

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        } catch {
            print("Failed to setup camera: \(error)")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        poseDetector?.processFrame(sampleBuffer)
    }
}