class CommentAdapter
  COMMENT_REGEXP = /\/merge to/
  BRANCH_REGEXP = /\merge to ([0-9a-zA-Z'-\/]+)/
  COMMAND_NAME = "/merge"

  def initialize(github_event)
    @event = github_event
    @comment_message = @event&.dig('comment', 'body')
  end

  def valid?
    @comment_message && @comment_message =~ COMMENT_REGEXP
  end

  def branch_name
    match_branch_name(@comment_message)
  rescue StandardError => e
    raise "Could not find branch name, #{e.message}"
  end

  def match_branch_name(str)
    arr = str.split(/\s+/)
    index = arr.index(COMMAND_NAME)
    arr[index + 2]
  end

end