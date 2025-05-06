import Foundation

#if DEBUG
extension PullRequest {
    static let mockPullRequests = [
        PullRequest(
            type: "pullrequest",
            links: PullRequestLinks(
                html: Link(href: "https://bitbucket.org/example/pr/1", name: nil),
                commits: nil,
                approve: nil,
                diff: nil,
                diffstat: nil,
                comments: nil,
                activity: nil,
                merge: nil,
                decline: nil
            ),
            id: 1,
            title: "Feature: Add new dashboard",
            state: "OPEN",
            author: User(
                type: "user",
                displayName: "John Doe",
                links: nil,
                uuid: "{123e4567-e89b-12d3-a456-426614174000}",
                accountId: "123456",
                nickname: "johndoe"
            ),
            mergeCommit: nil,
            commentCount: 5,
            taskCount: 2,
            createdOn: "2024-03-20T10:00:00.000Z",
            updatedOn: "2024-03-20T11:00:00.000Z",
            reviewers: [],
            participants: [
                Participant(
                    type: "participant",
                    user: User(
                        type: "user",
                        displayName: "Jane Smith",
                        links: nil,
                        uuid: "{123e4567-e89b-12d3-a456-426614174001}",
                        accountId: "123457",
                        nickname: "janesmith"
                    ),
                    role: "REVIEWER",
                    approved: true,
                    state: "approved",
                    participatedOn: "2024-03-20T10:30:00.000Z"
                )
            ]
        ),
        PullRequest(
            type: "pullrequest",
            links: PullRequestLinks(
                html: Link(href: "https://bitbucket.org/example/pr/2", name: nil),
                commits: nil,
                approve: nil,
                diff: nil,
                diffstat: nil,
                comments: nil,
                activity: nil,
                merge: nil,
                decline: nil
            ),
            id: 2,
            title: "Fix: Update authentication flow",
            state: "OPEN",
            author: User(
                type: "user",
                displayName: "Alice Johnson",
                links: nil,
                uuid: "{123e4567-e89b-12d3-a456-426614174002}",
                accountId: "123458",
                nickname: "alicej"
            ),
            mergeCommit: nil,
            commentCount: 3,
            taskCount: 0,
            createdOn: "2024-03-19T15:00:00.000Z",
            updatedOn: "2024-03-20T09:00:00.000Z",
            reviewers: [],
            participants: [
                Participant(
                    type: "participant",
                    user: User(
                        type: "user",
                        displayName: "Bob Wilson",
                        links: nil,
                        uuid: "{123e4567-e89b-12d3-a456-426614174003}",
                        accountId: "123459",
                        nickname: "bobw"
                    ),
                    role: "REVIEWER",
                    approved: false,
                    state: "pending",
                    participatedOn: "2024-03-19T16:00:00.000Z"
                )
            ]
        )
    ]
}
#endif
