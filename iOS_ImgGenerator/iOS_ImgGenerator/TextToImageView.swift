
import SwiftUI

struct TextToImageView: View {

    @ObservedObject var imageGenerator: ImageGenerator
    @State private var generationParameter =
    ImageGenerator.GenerationParameter(mode: .textToImage,
                                       prompt: "a photo of an astronaut riding a horse on mars",
                                       negativePrompt: """
lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits,
 cropped, worst quality, low quality, normal quality, jpeg artifacts, blurry, multiple legs, malformation
""",
                                       guidanceScale: 8.0,
                                       seed: 1_000_000,
                                       stepCount: 20,
                                       imageCount: 1,
                                       disableSafety: false,
                                       strength: 1.0)

    @State var isGenerating: Bool = false
    @EnvironmentObject var ImgSaver: ImageSaver

    @Namespace var topID
    @Namespace var imgTopID

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text("draw an animation-style picture with prompt")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    PromptView(parameter: $generationParameter)
                        .disabled(imageGenerator.generationState != .idle)

                    if imageGenerator.generationState == .idle {
                        Button(action: {
                            Task {
                                generate()
                                isGenerating = true
                                imageGenerator.generatedImages = nil
                                imageGenerator.steps = 0
                                withAnimation {
                                    proxy.scrollTo(imgTopID, anchor: .top)
                                }
                            }
                        }) {
                            Text("Generate").font(.title)
                        }.buttonStyle(.borderedProminent)
                    } else {
                        if imageGenerator.isCancelled {
                            Text("Canceling..").font(.title)
                        } else {
                            Text("Generating..").font(.title)
                        }
                    }

                    VStack {
                        if isGenerating {
                            if let generatedImages = imageGenerator.generatedImages {
                                ForEach(generatedImages.images) {
                                    Image(uiImage: $0.uiImage)
                                        .resizable()
                                        .scaledToFit()
                                }
                                Button(action: {
                                    let imageSaver = ImageSaver()
                                    imageSaver.writeToPhotoAlbum(image: generatedImages.images.first!.uiImage)
                                }, label: {
                                    Text("Save")
                                        .font(.title)
                                })
                                .buttonStyle(.borderedProminent)
                            } else {
                                Image("gen_image")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolEffect(.variableColor.cumulative, options: .repeating.speed(1.5))
                                ProgressView(value: ((Double(imageGenerator.steps) / 28.0)))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                                    .padding()

                                Button(action: {
                                    print("")
                                    imageGenerator.isCancelled = true
                                    isGenerating = false
                                }, label: {
                                    Text("Cancel")
                                        .font(.title)
                                })
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }.padding()
                    .id(imgTopID)
                }
            }
        }
    }

    
    func generate() {
        imageGenerator.generateImages(generationParameter)
    }
}

struct TextToImageView_Previews: PreviewProvider {
    static let imageGenerator = ImageGenerator()
    static var previews: some View {
        TextToImageView(imageGenerator: imageGenerator)
    }
}
