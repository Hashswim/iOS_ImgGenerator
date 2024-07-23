
import SwiftUI
import TipKit

struct PromptView: View {
    @Binding var parameter: ImageGenerator.GenerationParameter

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Prompt")
                    .font(.headline)
                    .foregroundStyle(Color.white)
//                Image(systemName: "questionmark.circle")
//                    .font(.subheadline)
//                    .popoverTip(PromptTooltip.prompt(title: "Prompt", message: "using \",\" or sentence to what you add to picture"),
//                                arrowEdge: .bottom)
                Spacer()
            }

            TextField("Prompt:", text: $parameter.prompt, prompt: Text("Enter what you want to draw"),  axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1...30)
                .padding(.bottom)

            HStack {
                Text("Negative Prompt")
                    .font(.headline)
                    .foregroundStyle(Color.white)
//                Button (action: {
//                    PromptTooltip.show.toggle()
//                }) {
//                    Image(systemName: "questionmark.circle")
//                        .font(.subheadline)
//                }
//                .popoverTip(PromptTooltip.prompt(title: "Negative Prompt", message: "using \",\" or sentence to what you subtract to picture"),
//                                 arrowEdge: .bottom)
                Spacer()
            }

            TextField("Negative Prompt:", text: $parameter.negativePrompt, prompt:  Text("Enter what you substract from image"),axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...30)
                .padding(.bottom)

            if parameter.mode == .imageToImage {
                HStack {
                    Text("Strength: \(parameter.strength, specifier: "%.1f")")
                        .foregroundStyle(Color.white)
                        .font(.headline)
//                    Image(systemName: "questionmark.circle")
//                        .font(.subheadline)
//                        .popoverTip(PromptTooltip.prompt(title: "Strength", message: "How close to the base image you're going to draw"),
//                                    arrowEdge: .bottom)
                    Spacer()
                }
                Slider(
                    value: $parameter.strength,
                    in: 0.0...0.9,
                    step: 0.1
                ).tint(MySpecialColors.accentDeepRed)
            }
        }.padding(.horizontal)
    }
}

struct PromptView_Previews: PreviewProvider {
    @State static var param = ImageGenerator.GenerationParameter(mode: .imageToImage,
                                                          prompt: "a prompt",
                                                          negativePrompt: "a negative prompt",
                                                          guidanceScale: 0.5,
                                                          seed: 1_000,
                                                          stepCount: 20,
                                                          imageCount: 1,
                                                          disableSafety: false,
                                                          strength: 0.5)
    static var previews: some View {
        PromptView(parameter: $param)
    }
}
