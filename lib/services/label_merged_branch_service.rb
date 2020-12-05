# frozen_string_literal: true

class LabelMergedBranchService
  def initialize(client, sha:, label_name:, repo:)
    @client = client
    @commit_sha = sha
    @label_name = label_name
    @repo = repo
  end

  def run
    all_commits = @client.commits(@repo, @sha)
    if is_merged_commit?(all_commits.first)
      sha_commit = all_commits[1].sha
    end

    pull_requests = @client.pull_requests(@repo, :state => 'open')
    if pull_request = pull_requests.find{ |item| sha_commit == item.head.sha }
      puts "Create label #{@label_name} on #{pull_request.number}"
      @client.add_labels_to_an_issue(@repo, pull_request.number, [@label_name])
    else
      puts "No pull request found"
    end
  end

  def is_merged_commit?(commit)
    commit.parents.count >= 2
  end
end
