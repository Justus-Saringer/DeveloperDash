import Foundation
import SwiftUI
import Combine

final class BitBucketViewModel: ObservableObject {
    @Published var areCredentialsVisible: Bool = false
    @Published var username: String = ""
    @Published var appPassword: String = ""
    @Published var workspace: String = ""
    @Published var repoSlug: String = ""
    @Published var showLoadingIndicator: Bool = false
    @Published var showOnlyAuthorsPRs: Bool = false
    
    @Published var pullRequestResponse: PullRequestResponse?
    
    func toggleCredentials() {
        areCredentialsVisible.toggle()
    }
    
    init(pullRequestResponse: PullRequestResponse? = nil) {
        self.pullRequestResponse = pullRequestResponse
        prefillData()
    }

    func submit() {
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "bitbucket_username")
        defaults.set(appPassword, forKey: "bitbucket_app_password")
        defaults.set(workspace, forKey: "bitbucket_workspace")
        defaults.set(repoSlug, forKey: "bitbucket_repo_slug")
        defaults.set(showOnlyAuthorsPRs, forKey: "bitbucket_show_only_authors_prs")
        
        Task {
            await fetchOpenPullRequests()
            await MainActor.run {
                withAnimation {
                    areCredentialsVisible = false
                }
            }
        }
    }
    
    func gotApproved(participants: [Participant]?) -> Bool {
        guard let participants = participants else { return false }
        return participants.contains { $0.approved }
    }
    
    func fetchOpenPullRequests() async {
        await setIndicatorVisibility(to: true)
        
        guard let request = createPRRequest() else {
            print("Failed to create request")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Could not convert data to string")
                return
            }
            print("Received JSON: \(jsonString)")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(PullRequestResponse.self, from: data)
            
            await MainActor.run {
                self.pullRequestResponse = decodedResponse
            }
            
            await setIndicatorVisibility(to: false)
        } catch {
            print("Error: \(error)")
            if let error = error as? URLError {
                print("URL Error: \(error.code), \(error.localizedDescription)")
            }
            
            if let httpResponse = try? await URLSession.shared.data(for: request).1 as? HTTPURLResponse {
                print("HTTP Status Code on error: \(httpResponse.statusCode)")
            }
            
            await resetPullRequests()
            
            await setIndicatorVisibility(to: false)
        }
    }
    
    private func createPRRequest() -> URLRequest? {
        let queries = createQueries()
        let urlString = "https://api.bitbucket.org/2.0/repositories/\(workspace)/\(repoSlug)/pullrequests" + queries
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let credentials = "\(username):\(appPassword)"
        guard let credentialData = credentials.data(using: .utf8) else { return nil }
        let base64Credentials = credentialData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createQueries() -> String {
        let authorQuery = showOnlyAuthorsPRs ? "?q=author.username=\"\(username)\" AND state=\"OPEN\"" : ""
        
        let appendSign = showOnlyAuthorsPRs ? "&" : "?"
        let valuesQuery = "fields=values.type,values.links,values.id,values.title," +
        "values.state,values.author,values.merge_commit,values.comment_count," +
        "values.task_count,values.created_on,values.updated_on,values.reviewers,values.participants"
        
        return authorQuery + appendSign + valuesQuery
    }
    
    private func prefillData() {
        let defaults = UserDefaults.standard
        if let savedUsername = defaults.string(forKey: "bitbucket_username") {
            username = savedUsername
        }
        if let savedAppPassword = defaults.string(forKey: "bitbucket_app_password") {
            appPassword = savedAppPassword
        }
        if let savedWorkspace = defaults.string(forKey: "bitbucket_workspace") {
            workspace = savedWorkspace
        }
        if let savedRepoSlug = defaults.string(forKey: "bitbucket_repo_slug") {
            repoSlug = savedRepoSlug
        }
        let savedShowOnlyAuthorsPRs = defaults.bool(forKey: "bitbucket_show_only_authors_prs")
        showOnlyAuthorsPRs = savedShowOnlyAuthorsPRs
    }
    
    private func resetPullRequests() async {
        await MainActor.run {
            pullRequestResponse = nil
        }
    }
    
    private func setIndicatorVisibility(to visible: Bool) async {
        await MainActor.run {
            self.showLoadingIndicator = visible
        }
    }
}
