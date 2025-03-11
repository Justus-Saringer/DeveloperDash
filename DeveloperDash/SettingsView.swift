import SwiftUI

struct SettingsView: View {
    @ObservedObject var bitbucketViewModel: BitBucketViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    TextField(text: $bitbucketViewModel.repoSlug) {
                        Text("Repo")
                    }
                    .disableAutocorrection(true)
                }
                
                Section {
                    Toggle(isOn: $bitbucketViewModel.showOnlyAuthorsPRs) {
                        Text("Only show my PRs")
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            
            HStack {
                Spacer()
                Button("Save") {
                    bitbucketViewModel.submit()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal)
        }
        .frame(minWidth: 400, minHeight: 300)
    }
} 