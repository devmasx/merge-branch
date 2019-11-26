require_relative './labeled_adapter'
require_relative './push_adapter'

class MergeBrachService

  def initialize(inputs)
    @inputs = inputs
  end

  def ensure_base_branch
    adapter = build_adapter
    return nil unless adapter.valid?

    adapter.base_branch.tap do |base_branch|
      raise 'Could not find branch name' unless base_branch || base_branch.empty?
    end
  end

  private

  def build_adapter
    case @inputs[:type]
    when 'push'
      PushAdapter.new(@inputs[:event], @inputs[:base_branch])
    when 'labeled'
      LabeledAdapter.new(@inputs[:event], @inputs[:base_branch], @inputs[:label_name])
    end
  end
end
