import Foundation

struct PullRequestResponse: Decodable {
    let values: [PullRequest]
}

struct PullRequest: Decodable {
    let type: String?
    let links: PullRequestLinks?
    let id: Int
    let title: String?
    let state: String?
    let author: User?
    let mergeCommit: MergeCommit?
    let commentCount: Int
    let taskCount: Int?
    let createdOn: String?
    let updatedOn: String?
    let reviewers: [User]?
    let participants: [Participant]?
}

struct PullRequestLinks: Decodable {
    let html: Link?
    let commits: Link?
    let approve: Link?
    let diff: Link?
    let diffstat: Link?
    let comments: Link?
    let activity: Link?
    let merge: Link?
    let decline: Link?
}

struct Link: Decodable {
    let href: String
    let name: String?
}

struct User: Decodable {
    let type: String?
    let displayName: String?
    let links: UserLinks?
    let uuid: String?
    let accountId: String?
    let nickname: String?
}

struct Participant: Decodable {
    let type: String?
    let user: User
    let role: String?
    let approved: Bool
    let state: String?
    let participatedOn: String?
}


struct UserLinks: Decodable {
    let avatar: Link?
    let html: Link?
}


struct MergeCommit: Decodable {
    let hash: String?
}
