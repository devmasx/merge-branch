class LabeledAdapter
  def initialize(github_event, base_branch, label_name)
    @event = github_event
    @base_branch = base_branch
    @label_name = label_name
  end

  def valid?
    @event&.dig('action') == 'labeled' &&
      @event&.dig('label', 'name') == @label_name
  end

  def base_branch
    @base_branch
  end
end
