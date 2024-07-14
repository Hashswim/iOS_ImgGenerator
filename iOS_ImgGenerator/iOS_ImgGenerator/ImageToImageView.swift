
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

    @ObservedObject var imageGenerator: ImageGenerator
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

    var body: some View {
        ScrollView {
            VStack {
                Text("Image to image").font(.title3).bold().padding(6)
                Text("guide text")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.bottom)

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Select a photo")
                    }.onChange(of: selectedItem, { oldValue, newValue in
                        Task {
                            // Retrieve selected asset in the form of Data
                            if let data = try? await newValue?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {

                                resizedImage = uiImage
                                generationParameter.startImage = uiImage.cgImage?.resize(size: CGSize(width: 512, height: 512))
                            }
                        }
                    })

                if let resizedImage {
                    Image(uiImage: resizedImage)
                        .resizable()
                        .frame(width: 256, height: 256)
                }

                PromptView(parameter: $generationParameter)
                    .disabled(imageGenerator.generationState != .idle)

                if imageGenerator.generationState == .idle {
                    Button(action: generate) {
                        Text("Generate").font(.title)
                    }.buttonStyle(.borderedProminent)
                } else {
                    ProgressView()
                }

                if let generatedImages = imageGenerator.generatedImages {
                    ForEach(generatedImages.images) {
                        Image(uiImage: $0.uiImage)
                            .resizable()
                            .scaledToFit()
                    }
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
    static let imageGenerator = ImageGenerator()
    static var previews: some View {
        ImageToImageView(imageGenerator: imageGenerator)
    }
}
