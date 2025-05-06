import SwiftUI

struct SettingsView: View {
    @ObservedObject var bitbucketViewModel: BitBucketViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newRepoName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                Section("BitBucket Credentials") {
                    TextField(text: $bitbucketViewModel.username) {
                        Text("Username")
                    }
                    .disableAutocorrection(true)
                    
                    TextField(text: $bitbucketViewModel.appPassword) {
                        Text("Password")
                    }
                    .disableAutocorrection(true)
                    
                    TextField(text: $bitbucketViewModel.workspace) {
                        Text("Workspace")
                    }
                    .disableAutocorrection(true)
                }
                
                Section("Repositories") {
                    ForEach(bitbucketViewModel.repositories, id: \.self) { repo in
                        HStack {
                            Text(repo)
                            Spacer()
                            Button {
                                withAnimation {
                                    bitbucketViewModel.repositories.removeAll(where: { $0 == repo })
                                    bitbucketViewModel.persistRepositories()
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    
                    HStack {
                        TextField("new repository", text: $newRepoName)
                            .disableAutocorrection(true)
                        Button(action: {
                            withAnimation {
                                bitbucketViewModel.repositories.append(newRepoName)
                                bitbucketViewModel.persistRepositories()
                                newRepoName = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }.disabled(newRepoName.isEmpty)
                    }
                }
                
                Section {
                    Toggle(isOn: $bitbucketViewModel.showAuthorsPRs) {
                        Text("Only show my PRs")
                    }
                }
            }
            .frame(width: 400)
            .formStyle(.grouped)
            .padding()
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

#if DEBUG
#Preview {
    SettingsView(bitbucketViewModel: BitBucketViewModel())
}
#endif
