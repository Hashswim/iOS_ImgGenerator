
import SwiftUI
import PhotosUI

struct ImageToImageView: View {
    static let prompt = "happy smile snow winter"
    static let negativePrompt =
"""
lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits,
 cropped, worst quality, low quality, normal quality, jpeg artifacts, blurry, multiple legs, malformation
"""
    @State private var resizedImage: UIImage? = nil

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    @EnvironmentObject var imageGenerator: ImageGenerator
    @State private var generationParameter: ImageGenerator.GenerationParameter =
    ImageGenerator.GenerationParameter(mode: .imageToImage,
                                       prompt: prompt,
                                       negativePrompt: negativePrompt,
                                       guidanceScale: 8.0,
                                       seed: 1_000_000,
                                       stepCount: 20,
                                       imageCount: 1, disableSafety: false,
                                       startImage: UIImage().cgImage,
                                       strength: 0.5)

    @State var isGenerating2: Bool = false
    @EnvironmentObject var ImgSaver: ImageSaver
    @State var isSaved: Bool = false

    @Namespace var topID
    @Namespace var imgTopID

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text("draw an animation-style picture with prompt and photo\n (512, 512) pixel size is best quality")
                        .foregroundColor(MySpecialColors.guideTextGray)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .padding(.bottom)

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            VStack {
                                if let resizedImage {
                                    Image(uiImage: resizedImage)
                                        .resizable()
                                        .frame(width: 160, height: 160)
                                } else {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.largeTitle)
                                }
                                Text("select base photo in library")
                            }/*.padding(EdgeInsets(top: 40, leading: 68, bottom: 40, trailing: 68))*/
                            .tint(MySpecialColors.accentDeepRed)
                            .padding(40)
                            .frame(maxWidth: .infinity)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(MySpecialColors.accentDeepRed,
                                                      style: StrokeStyle(lineWidth: 4, dash: [8]))
                                })
                        }.onChange(of: selectedItem, { oldValue, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {

                                    resizedImage = uiImage
                                    generationParameter.startImage = uiImage.cgImage?.resize(size: CGSize(width: 512, height: 512))
                                }
                            }
                        }).padding(.bottom, 8)
                        .padding(.horizontal)

                    PromptView(parameter: $generationParameter)
                        .disabled(imageGenerator.generationState != .idle)

                    if imageGenerator.generationState == .idle {
                        Button(action: {
                            Task {
                                generate()
                                isGenerating2 = true
                                imageGenerator.i2iGeneratedImages = nil
                                imageGenerator.steps = 0
                                withAnimation {
                                    proxy.scrollTo(imgTopID, anchor: .top)
                                }
                            }
                            isSaved = false
                        }) {
                            Text("Generate").font(.title)
                                .foregroundStyle(Color.white)
                        }.buttonStyle(.borderedProminent)
                            .tint(MySpecialColors.accentDeepRed)

                    } else {
                        if imageGenerator.isCancelled {
                            Button(action: {}) {
                                Text("Canceling..")
                                    .font(.title)
                                    .foregroundStyle(Color.white)
                            }.buttonStyle(.borderedProminent)
                                .tint(MySpecialColors.progressBarRed)
                                .disabled(true)
                        } else {
                            Button(action: {}) {
                                Text("Generating..")
                                    .font(.title)
                                    .foregroundStyle(Color.white)
                            }.buttonStyle(.borderedProminent)
                                .tint(MySpecialColors.progressBarRed)
                                .disabled(true)
                        }
                    }

                    GenImageView(isGenerating: $isGenerating2,
                                 isSaved: $isSaved,
                                 isT2I: false)
                    .id(imgTopID)
                }
            }
        }
    }

    func generate() {
        imageGenerator.generateImages(generationParameter)
    }
}

extension CGImage {
    func resize(size: CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: self.bitsPerComponent, bytesPerRow: destBytesPerRow, space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else { return nil }

        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}

struct ImageToImageView_Previews: PreviewProvider {
//    static let imageGenerator = ImageGenerator()
    static var previews: some View {
        ImageToImageView()
    }
}
