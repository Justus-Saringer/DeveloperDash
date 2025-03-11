import SwiftUI

struct ContentView: View {
    let bitbucketViewModel: BitBucketViewModel
    
    var body: some View {
        VStack {
            BitBucketView(viewModel: bitbucketViewModel)
                .frame(maxWidth: .infinity)
        }
        .frame(width: 300, height: 300, alignment: .topLeading)
        .padding()
    }
}

#Preview {
    let bitBucketViewModel = BitBucketViewModel()
    ContentView(bitbucketViewModel: bitBucketViewModel)
}
