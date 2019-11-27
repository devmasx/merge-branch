require_relative '../adapters/labeled_adapter'
require_relative '../adapters/now_adapter'

class MergeBrachService

  def initialize(inputs)
    @inputs = inputs
    @inputs[:type] = 'labeled' unless @inputs[:type]
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
    when 'now'
      NowAdapter.new(@inputs[:event], @inputs[:target_branch])
    when 'labeled'
      LabeledAdapter.new(@inputs[:event], @inputs[:target_branch], @inputs[:label_name])
    else
      raise "Invalid type #{@inputs[:type]}"
    end
  end
end
