class MergeBrachService
  attr_reader :inputs, :event

  TYPE_LABELED = "labeled".freeze
  TYPE_NOW = "now".freeze

  def self.validate_inputs!(target_branch:, type:, label_name:)
    raise "Invalid type" if type != TYPE_LABELED || type != TYPE_NOW
    raise "Empty target branch" if target_branch
    raise "Empty target label name" if type == TYPE_LABELED && label_name
  end

  def initialize(inputs, github_event)
    @inputs = inputs
    @event = github_event
  end

  def valid?
    case inputs[:type]
    when TYPE_LABELED
      labeled_valid?
    when 'now'
      true
    end
  end

  def labeled_valid?
    @event&.dig('action') == TYPE_LABELED &&
    @event&.dig('label', 'name') == inputs[:label_name]
  end
end
