require_relative './command'

class CheckCommit
  include Command

  def initialize(commit_sha)
    @commit_sha = commit_sha
  end

  def in_branch?(branch_name)
    contains_in_branches.include?(branch_name)
  end

  def contains_in_branches
    response = execute_branch_contains
    return nil if command_error?(response)
    command_to_list(response)
  end

  def execute_branch_contains
    `git branch -r --contains #{@commit_sha}`
  end
end
