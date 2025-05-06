import Foundation
import SwiftUI

struct BitBucketView: View {
    @ObservedObject var viewModel: BitBucketViewModel
    
    init(viewModel: BitBucketViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            filterView
                .frame(maxWidth: 300)
            
            Divider()
            
            pullRequestList
        }
    }
    
    @ViewBuilder
    var pullRequestList: some View {
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
                Text("No open pull requests")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .scrollIndicators(.visible)
    }
    
    @ViewBuilder
    var filterView: some View {
        Button(action: {
            withAnimation {
                viewModel.toggleCredentials()
            }
        }) {
            HStack {
                Text("Filter")
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
                Picker("repo", selection: $viewModel.selectedRepo) {
                    ForEach(viewModel.repositories, id: \.self) { repo in
                        Text(repo)
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
            
            HStack {
                Spacer()
                Toggle(isOn: $viewModel.showAuthorsPRs) {
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

#Preview {
    let viewModel = BitBucketViewModel(pullRequestResponse: PullRequestResponse(
            values: PullRequest.mockPullRequests
        ))
    
    BitBucketView(viewModel: viewModel)
        .frame(width: 480, height: 300)
}
