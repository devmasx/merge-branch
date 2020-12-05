# frozen_string_literal: true

require 'json'
require 'octokit'
require_relative './constans'
require_relative './services/merge_branch_service'
require_relative './services/label_merged_branch_service'

def presence(value)
  return nil if value == ""
  value
end

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
@head_to_merge = presence(ENV['INPUT_HEAD_TO_MERGE']) || presence(ENV['INPUT_FROM_BRANCH']) || presence(ENV['GITHUB_SHA']) # or brach name
@repository = ENV['GITHUB_REPOSITORY']
@github_token = presence(ENV['INPUT_GITHUB_TOKEN']) || presence(ENV['GITHUB_TOKEN'])

puts "@head_to_merge: #{@head_to_merge}, empty: #{@head_to_merge == ''}, default: #{ENV['GITHUB_SHA']}"

inputs = {
  type: presence(ENV['INPUT_TYPE']) || Constans::TYPE_LABELED,
  label_name: ENV['INPUT_LABEL_NAME'],
  target_branch: ENV['INPUT_TARGET_BRANCH']
}

@client = Octokit::Client.new(access_token: @github_token)
if inputs[:type] == Constans::TYPE_MERGED_LABEL
  LabelMergedBranchService.new(@client, {
    sha: @head_to_merge,
    label_name: inputs[:label_name],
    repo: @repository
  }).run
else
  MergeBrachService.validate_inputs!(inputs)
  service = MergeBrachService.new(inputs, @event)

  if service.valid?
    @client.merge(@repository, inputs[:target_branch], @head_to_merge)
    puts "Finish merge branch to #{inputs[:target_branch]}"
  else
    puts 'Skip'
  end
end
