# frozen_string_literal: true

class LabelMergedBranchService
  def initialize(client, sha:, label_name:, repo:)
    @client = client
    @commit_sha = sha
    @label_name = label_name
    @repo = repo
  end

  def run
    create_label(find_pull_request)
  end

  def find_pull_request
    all_commits = @client.commits(@repo, @commit_sha)
    if is_merged_commit?(all_commits.first)
      commit_sha = all_commits[1].sha
      # puts "Real commit (no merge) #{commit_sha}"
    end

    pull_requests = @client.pull_requests(@repo, :state => 'open')
    pull_requests&.find{ |item| commit_sha == item.head.sha }
  end

  def create_label(pull_request)
    puts "Create label #{@label_name} on #{pull_request.number}"
    @client.add_labels_to_an_issue(@repo, pull_request.number, [@label_name])
  end

  def is_merged_commit?(commit)
    commit.parents.count >= 2
  end
end
