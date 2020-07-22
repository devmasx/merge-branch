require 'json'
require 'octokit'
require_relative './services/merge_branch_service'

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
@head_to_merge = ENV['INPUT_HEAD_TO_MERGE'] || ENV['INPUT_FROM_BRANCH'] || ENV['GITHUB_SHA'] # or brach name
@repository = ENV['GITHUB_REPOSITORY']
@github_token = ENV['INPUT_GITHUB_TOKEN'] || ENV['GITHUB_TOKEN']

inputs = {
  type: ENV['INPUT_TYPE'] || MergeBrachService::TYPE_LABELED, # labeled | comment | now
  label_name: ENV['INPUT_LABEL_NAME'],
  target_branch: ENV['INPUT_TARGET_BRANCH']
}

MergeBrachService.validate_inputs!(inputs)
service = MergeBrachService.new(inputs, @event)

if service.valid?
  @client = Octokit::Client.new(access_token: @github_token)
  @client.merge(@repository, inputs[:target_branch], @head_to_merge)
  puts "Finish merge branch to #{inputs[:target_branch]}"
else
  puts 'Skip'
end
