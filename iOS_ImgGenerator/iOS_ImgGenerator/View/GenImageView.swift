import SwiftUI
import Photos

struct GenImageView: View {
    @EnvironmentObject var imageGenerator: ImageGenerator

    @Binding var isGenerating: Bool
    @Binding var isSaved: Bool
    @State var showAlert: Bool = false

    var isT2I: Bool

    @StateObject private var imageSaver = ImageSaver()

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
                        imageSaver.writeToPhotoAlbum(image: generatedImages.images.first!.uiImage)
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
        }
        .padding()
        .onReceive(imageSaver.$isSaved) { saved in
            isSaved = saved
        }
        .onReceive(imageSaver.$showAlert) { show in
            showAlert = show
        }
        .alert(imageSaver.alertMessage.0, isPresented: $showAlert) {
            if imageSaver.alertMessage.1 {
                Button("Setting") {
                    showAlert = false
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                Button("Confirm") {
                    showAlert = false
                }
            } else {
                Button("Confirm", role: .cancel) {
                    showAlert = false
                }
            }

        }
    }

    private func getGeneratedImages() -> ImageGenerator.GeneratedImages? {
        if isT2I {
            return imageGenerator.t2iGeneratedImages
        } else {
            return imageGenerator.i2iGeneratedImages
        }
    }
}
