import Foundation
import SwiftUI

struct BitBucketView: View {
    @ObservedObject var viewModel: BitBucketViewModel
    
    init(viewModel: BitBucketViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            credentialView
            
            Divider()
            
            ScrollView {
                if let pullRequests = viewModel.pullRequestResponse?.values {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(pullRequests, id: \.id) { pr in
                            HStack {
                                Button(action: {
                                    if let href = pr.links?.html?.href, let url = URL(string: href) {
                                        NSWorkspace.shared.open(url)
                                    }
                                }) {
                                    Text(pr.title ?? "")
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                                .buttonStyle(.plain)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                let approved = viewModel.gotApproved(participants: pr.participants)
                                if approved {
                                    Image(systemName: "checkmark.circle")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(.green)
                                }
                                
                                Text(String(pr.commentCount))
                                    .frame(width: 22, height: 22)
                                    .background(Color.mint)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.trailing, 12)
                } else {
                    Text("Keine offenen Pull Requests")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .scrollIndicators(.visible)
        }
    }
    
    @ViewBuilder
    var credentialView: some View {
        Button(action: {
            withAnimation {
                viewModel.toggleCredentials()
            }
        }) {
            HStack {
                Text("Credentials")
                viewModel.areCredentialsVisible ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
                Spacer()
                if viewModel.showLoadingIndicator {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .clipShape(Rectangle())
        
        if viewModel.areCredentialsVisible {
            Form {
                TextField(text: $viewModel.username) {
                    Text("Username")
                }
                .disableAutocorrection(true)
                
                TextField(text: $viewModel.appPassword) {
                    Text("Password")
                }
                .disableAutocorrection(true)
                
                TextField(text: $viewModel.workspace) {
                    Text("Workspace")
                }
                .disableAutocorrection(true)
                
                TextField(text: $viewModel.repoSlug) {
                    Text("Repo")
                }
                .disableAutocorrection(true)
            }
            .textFieldStyle(.roundedBorder)
            
            HStack {
                Spacer()
                Toggle(isOn: $viewModel.showOnlyAuthorsPRs) {
                    Text("only my PRs")
                }
                Button(action: {
                    viewModel.submit()
                }) {
                    Text("save")
                        .frame(width: 56)
                }
            }
        }
    }
}
