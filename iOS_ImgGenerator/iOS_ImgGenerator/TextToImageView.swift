
import SwiftUI

struct TextToImageView: View {
    static let prompt = "a photo of an astronaut riding a horse on mars"
    static let negativePrompt =
"""
lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits,
 cropped, worst quality, low quality, normal quality, jpeg artifacts, blurry, multiple legs, malformation
"""

    @ObservedObject var imageGenerator: ImageGenerator
    @State private var generationParameter =
        ImageGenerator.GenerationParameter(mode: .textToImage,
                                           prompt: prompt,
                                           negativePrompt: negativePrompt,
                                           guidanceScale: 8.0,
                                           seed: 1_000_000,
                                           stepCount: 20,
                                           imageCount: 1,
                                           disableSafety: false,
                                           strength: 1.0)

    @State var isGenerating: Bool = false

    @Namespace var topID
    @Namespace var imgTopID

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text("Text to image").font(.title3).bold().padding(6)
                        .id(topID)
                    Text("guide text")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.bottom)

                    PromptView(parameter: $generationParameter)
                        .disabled(imageGenerator.generationState != .idle)

                    if imageGenerator.generationState == .idle {
                        Button(action: {
                            generate()
                            isGenerating = true
                            imageGenerator.generatedImages = nil
                            withAnimation {
                                proxy.scrollTo(imgTopID, anchor: .top)
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

                    Spacer().id(imgTopID)

                    if isGenerating {
                        if let generatedImages = imageGenerator.generatedImages {
                            ForEach(generatedImages.images) {
                                Image(uiImage: $0.uiImage)
                                    .resizable()
                                    .scaledToFit()
                            }
                            Button(action: {
                                print("")
                                UIImageWriteToSavedPhotosAlbum(generatedImages.images.first!.uiImage, nil, nil, nil)
                            }, label: {
                                Text("Save")
                                    .font(.title)
                            })
                            .buttonStyle(.borderedProminent)
                        } else {
                            VStack {
                                Image("gen_image")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolEffect(.variableColor.cumulative, options: .repeating.speed(1.5))
                                    .id(imgTopID)

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
                            }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                        }
                    }
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