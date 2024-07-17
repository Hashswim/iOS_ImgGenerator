//
//  GenImageView.swift
//  iOS_ImgGenerator
//
//  Created by 서수영 on 7/17/24.
//

import SwiftUI

struct GenImageView: View {
    @Binding var isGenerating: Bool
    @Binding var isSaved: Bool
    @ObservedObject var imageGenerator: ImageGenerator

    var body: some View {
        VStack {
            if isGenerating {
                if let generatedImages = imageGenerator.generatedImages {
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
        }.padding()
    }
}

