# frozen_string_literal: true

class LabelMergedBranchService
  CHECK_BASE_NAME = "merge-branch"

  def initialize(client, sha:, label_name:, repo:)
    @client = client
    @sha = sha
    @label_name = label_name
    @repo = repo
  end

  def run
    if pull_request
      create_label
    else
      puts "Not Pull request found"
    end
    create_check_run
  end

  def commit_sha
    return @commit_sha if @commit_sha

    all_commits = @client.commits(@repo, @sha)
    if is_merged_commit?(all_commits.first)
      @commit_sha = all_commits[1].sha
      # puts "Commit sha (no merge) #{@commit_sha}"
    else
      @commit_sha = @sha
    end
  end

  def pull_request
    return @pull_request if @pull_request

    all_commits = @client.commits(@repo, @sha)
    pull_requests = @client.pull_requests(@repo, :state => 'open')
    @pull_request = pull_requests&.find{ |item| commit_sha == item.head.sha }
  end

  def create_label
    puts "Create label #{@label_name} on #{pull_request.number}"
    @client.add_labels_to_an_issue(@repo, pull_request.number, [@label_name])
  end

  def create_check_run
    url = "/repos/#{@repo}/check-runs"
    @client.post(url, {
      name: "#{CHECK_BASE_NAME}: #{@label_name}",
      head_sha: commit_sha,
      status: 'completed',
      started_at: Time.now.iso8601,
      conclusion: "success",
      output: {
        title: "#{CHECK_BASE_NAME}: #{@label_name}",
        summary: "#{CHECK_BASE_NAME}: #{@label_name}",
        annotations: []
      }
    })
  end

  def is_merged_commit?(commit)
    commit.parents.count >= 2
  end
end
