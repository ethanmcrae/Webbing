import SwiftUI

struct HUDView: View {
  let number: Int
  var body: some View {
    ZStack {
      Circle().fill(.black.opacity(0.7))
      Text("\(number)")
        .font(.system(size: 42, weight: .bold))
        .foregroundColor(.white)
    }
    .frame(width: 80, height: 80)
  }
}
