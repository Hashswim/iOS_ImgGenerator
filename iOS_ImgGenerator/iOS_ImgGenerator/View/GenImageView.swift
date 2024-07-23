
import SwiftUI

struct GenImageView: View {

    @EnvironmentObject var imageGenerator: ImageGenerator

    @Binding var isGenerating: Bool
    @Binding var isSaved: Bool
    var isT2I: Bool

    var body: some View {
        VStack {
            if isGenerating {
                HStack {
                    Text("Generated Image")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                    Spacer()
                }

                if let generatedImages = getGeneratedImages() {
                    ForEach(generatedImages.images) { image in
                        Image(uiImage: image.uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    }
                    Button(action: {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: generatedImages.images.first!.uiImage)
                        isSaved = true
                    }, label: {
                        Text(!isSaved ? "Save" : "Complete!")
                            .foregroundStyle(Color.white)
                            .font(.title)
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(MySpecialColors.accentDeepRed)
                    .disabled(isSaved)
                } else {
                    CircularProgressView(progress: (Double(imageGenerator.steps) / 28.1))

                    Button(action: {
                        print("")
                        imageGenerator.isCancelled = true
                        isGenerating = false
                    }, label: {
                        Text("Cancel")
                            .font(.title)
                    })
                    .buttonStyle(.borderedProminent)
                    .opacity(0.8)
                    .tint(MySpecialColors.accentDeepRed)
                }
            }
        }.padding()
    }

    private func getGeneratedImages() -> ImageGenerator.GeneratedImages? {
        if isT2I {
            return imageGenerator.t2iGeneratedImages
        } else {
            return imageGenerator.i2iGeneratedImages
        }
    }
}
