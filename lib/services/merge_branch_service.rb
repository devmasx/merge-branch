require_relative '../adapters/labeled_adapter'
require_relative '../adapters/push_adapter'

class MergeBrachService

  def initialize(inputs)
    @inputs = inputs
  end

  def ensure_target_branch
    adapter = build_adapter
    return nil unless adapter.valid?

    adapter.target_branch.tap do |target_branch|
      raise 'Could not find branch name' unless target_branch || target_branch.empty?
    end
  end

  private

  def build_adapter
    case @inputs[:type]
    when 'push'
      PushAdapter.new(@inputs[:event], @inputs[:target_branch])
    when 'labeled'
      LabeledAdapter.new(@inputs[:event], @inputs[:target_branch], @inputs[:label_name])
    end
  end
end
