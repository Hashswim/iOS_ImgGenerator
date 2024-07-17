
import SwiftUI

struct GenImageView: View {
    @Binding var isGenerating: Bool
    @Binding var isSaved: Bool
    var isT2I: Bool
    @ObservedObject var imageGenerator: ImageGenerator

    var body: some View {
        VStack {
            if isGenerating {
                if isT2I {
                    HStack {Text("Generated Image"); Spacer() }

                    if let generatedImages = imageGenerator.t2iGeneratedImages {
                        ForEach(generatedImages.images) { image in
                            Image(uiImage: image.uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                        Button(action: {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: generatedImages.images.first!.uiImage)
                            isSaved = true
                        }, label: {
                            Text(!isSaved ? "Save" : "Complete!")
                                .font(.title)
                        })
                        .buttonStyle(.borderedProminent)
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
                        .disabled(isSaved)
                    }
                } else {
                    HStack {Text("Generated Image"); Spacer() }

                    if let generatedImages = imageGenerator.i2iGeneratedImages {
                        ForEach(generatedImages.images) { image in
                            Image(uiImage: image.uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                        Button(action: {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: generatedImages.images.first!.uiImage)
                            isSaved = true
                        }, label: {
                            Text(!isSaved ? "Save" : "Complete!")
                                .font(.title)
                        })
                        .buttonStyle(.borderedProminent)
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
                        .disabled(isSaved)
                    }
                }

            }
        }.padding()
    }
}

