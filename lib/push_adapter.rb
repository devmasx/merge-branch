class PushAdapter
  def initialize(github_event, base_branch)
    @event = github_event
    @base_branch = base_branch
  end

  def valid?
    true
  end

  def base_branch
    @base_branch
  end
end
