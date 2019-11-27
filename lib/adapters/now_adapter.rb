class NowAdapter
  def initialize(github_event, target_branch)
    @event = github_event
    @target_branch = target_branch
  end

  def valid?
    true
  end

  def target_branch
    @target_branch
  end
end
