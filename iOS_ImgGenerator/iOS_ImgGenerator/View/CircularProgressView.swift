import SwiftUI

struct CircularProgressView: View {
  let progress: Double

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 20)
        .opacity(0.1)
        .foregroundColor(MySpecialColors.accentDeepRed)

      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(
                style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
        .foregroundColor(MySpecialColors.accentDeepRed)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress)

        VStack {
            Image("gen_image")
                .resizable()
                .scaledToFit()
                .symbolEffect(.variableColor.cumulative, options: .repeating.speed(1.0))
                .foregroundStyle(Color.white)

            Text("\(Int(progress * 100))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
        }.frame(width: 120, height: 120)
    }.frame(width: 240, height: 240)
          .padding()
  }
}
