class LabeledAdapter
  def initialize(github_event, target_branch, label_name)
    @event = github_event
    @target_branch = target_branch
    @label_name = label_name
  end

  def valid?
    @event&.dig('action') == 'labeled' &&
      @event&.dig('label', 'name') == @label_name
  end

  def target_branch
    @target_branch
  end
end
