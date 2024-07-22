
import SwiftUI

struct GenImageView: View {
    @Binding var isGenerating: Bool
    @Binding var isSaved: Bool
    var isT2I: Bool
    @EnvironmentObject var imageGenerator: ImageGenerator

    var body: some View {
        VStack {
            if isGenerating {
                if isT2I {
                    HStack {
                        Text("Generated Image")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Spacer()
                    }

                    if let generatedImages = imageGenerator.t2iGeneratedImages {
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
//                            if !isSaved {
//                                Text("Save")
//                                    .font(.title)
//                            } else {
//                                Text("Complete!")
//                                    .foregroundStyle(Color.white)
//                                    .font(.title)
//                            }
                            Text(!isSaved ? "Save" : "Complete!")
                                .foregroundStyle(Color.white)
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
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
                } else {
                    HStack {
                        Text("Generated Image")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Spacer()
                    }

                    if let generatedImages = imageGenerator.i2iGeneratedImages {
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
                                .font(.title)
                        })
                        .buttonStyle(.borderedProminent)
                        .tint(MySpecialColors.accentDeepRed)
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
        }.padding()
    }
}
