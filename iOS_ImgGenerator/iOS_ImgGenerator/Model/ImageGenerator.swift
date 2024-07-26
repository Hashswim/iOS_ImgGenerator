import UIKit
import StableDiffusion
import CoreML

@MainActor
final class ImageGenerator: ObservableObject {
    enum GenerationMode {
        case textToImage, imageToImage
    }

    struct GenerationParameter {
        let mode: GenerationMode
        var prompt: String
        var negativePrompt: String
        var guidanceScale: Float
        var seed: Int
        var stepCount: Int
        var imageCount: Int
        var disableSafety: Bool
        var startImage: CGImage?
        var strength: Float
    }

    struct GeneratedImage: Identifiable {
        let id: UUID = UUID()
        let uiImage: UIImage
    }

    struct GeneratedImages {
        let prompt: String
        let negativePrompt: String
        let guidanceScale: Float
        let imageCount: Int
        let stepCount: Int
        let seed: Int
        let disableSafety: Bool
        let images: [GeneratedImage]
    }

    enum GenerationState: Equatable {
        case idle
        case generating(progressStep: Int)
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, idle): return true
            case (.generating(let step1), .generating(let step2)):
                if step1 == step2 { return true
                } else { return false }
            default:
                return false
            }
        }
    }

    @Published var generationState: GenerationState = .idle
    @Published var t2iGeneratedImages: GeneratedImages?
    @Published var i2iGeneratedImages: GeneratedImages?

    @Published var isPipelineCreated = false
    @Published var isCancelled: Bool = false
    @Published var steps: Int = 0

    private var sdPipeline: StableDiffusionPipeline?

    init() {
    }

    func setState(_ state: GenerationState) { // for actor isolation
        generationState = state
    }

    func setPipeline(_ pipeline: StableDiffusionPipeline) { // for actor isolation
        sdPipeline = pipeline
        isPipelineCreated = true
    }

    func setT2IGeneratedImages(_ images: GeneratedImages?) { // for actor isolation
        t2iGeneratedImages = images
    }

    func setI2IGeneratedImages(_ images: GeneratedImages?) { // for actor isolation
        i2iGeneratedImages = images
    }

    // swiftlint:disable function_body_length
    func generateImages(_ parameter: GenerationParameter) {
        guard generationState == .idle else { return }
        isCancelled = false
        Task.detached(priority: .high) {
            await self.setState(.generating(progressStep: 0))

            if await self.sdPipeline == nil {
                guard let path = Bundle.main.path(forResource: "CoreMLModels", ofType: nil, inDirectory: nil) else {
                    fatalError("Fatal error: failed to find the CoreML models.")
                }
                let resourceURL = URL(fileURLWithPath: path)

                let config = MLModelConfiguration()

                let reduceMemory = ProcessInfo.processInfo.isiOSAppOnMac ? false : true
                if let pipeline = try? StableDiffusionPipeline(resourcesAt: resourceURL, controlNet: [],
                                                               configuration: config,
                                                               reduceMemory: reduceMemory) {
                    await self.setPipeline(pipeline)
                } else {
                    fatalError("Fatal error: failed to create the Stable-Diffusion-Pipeline.")
                }
            }

            if let sdPipeline = await self.sdPipeline {
                do {
                    var configuration = StableDiffusionPipeline.Configuration(prompt: parameter.prompt)
                    configuration.negativePrompt = parameter.negativePrompt
                    configuration.imageCount = 1
                    configuration.stepCount = 28
                    configuration.seed = UInt32.random(in: 0...UInt32.max)
                    configuration.guidanceScale = 7.5
                    configuration.disableSafety = parameter.disableSafety

                    switch parameter.mode {
                    case .textToImage:
                        configuration.strength = 1.0
                    case .imageToImage:
                        configuration.startingImage = parameter.startImage
                        configuration.strength = parameter.strength
                    }

                    let cgImages = try sdPipeline.generateImages(configuration: configuration, progressHandler: self.handleProgress)

                    print("images were generated.")
                    let uiImages = cgImages.compactMap { image in
                        if let cgImage = image { return UIImage(cgImage: cgImage)
                        } else { return nil }
                    }

                    let generatedImages = GeneratedImages(prompt: parameter.prompt,
                                                          negativePrompt: parameter.negativePrompt,
                                                          guidanceScale: parameter.guidanceScale,
                                                          imageCount: parameter.imageCount,
                                                          stepCount: parameter.stepCount,
                                                          seed: parameter.seed,
                                                          disableSafety: parameter.disableSafety,
                            images: uiImages.map { uiImage in GeneratedImage(uiImage: uiImage) })

                    if await !self.isCancelled {
                        switch parameter.mode {
                        case .textToImage:
                            await self.setT2IGeneratedImages(generatedImages)
                        case .imageToImage:
                            await self.setI2IGeneratedImages(generatedImages)
                        }
                    } else {
                        switch parameter.mode {
                        case .textToImage:
                            await self.setT2IGeneratedImages(nil)
                        case .imageToImage:
                            await self.setI2IGeneratedImages(nil)
                        }
                    }
                } catch {
                    print("failed to generate images.")
                }
            }
            await self.setState(.idle)
        }
    }

    @MainActor
    private func handleProgress(_ progress: StableDiffusionPipeline.Progress) -> Bool {
        DispatchQueue.main.async {
            self.steps = progress.step
        }

        return !isCancelled
    }
}
