class MergeBrachService
  attr_reader :inputs, :event

  TYPE_LABELED = "labeled".freeze
  TYPE_NOW = "now".freeze

  def self.validate_inputs!(target_branch:, type:, label_name:)
    raise "Invalid type" unless [TYPE_LABELED, TYPE_NOW].include?(type)
    raise "Empty target branch" if target_branch.nil? || target_branch.empty?
    if type == TYPE_LABELED
      raise "Empty target label name" if label_name.nil? || label_name.empty?
    end
  end

  def initialize(inputs, github_event)
    @inputs = inputs
    @event = github_event
  end

  def valid?
    case inputs[:type]
    when TYPE_LABELED
      labeled_valid?
    when TYPE_NOW
      true
    end
  end

  def labeled_valid?
    @event&.dig('action') == TYPE_LABELED &&
    @event&.dig('label', 'name') == inputs[:label_name]
  end
end
