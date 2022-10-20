require 'json'
require 'octokit'
require_relative './services/merge_branch_service'

def presence(value)
  return nil if value == ""
  value
end

Octokit.configure do |c|
  c.api_endpoint = ENV['GITHUB_API_URL']
end

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
@head_to_merge = presence(ENV['INPUT_HEAD_TO_MERGE']) || presence(ENV['INPUT_FROM_BRANCH']) || presence(ENV['GITHUB_SHA']) # or brach name
@repository = ENV['GITHUB_REPOSITORY']
@github_token = presence(ENV['INPUT_GITHUB_TOKEN']) || presence(ENV['GITHUB_TOKEN'])

inputs = {
  type: presence(ENV['INPUT_TYPE']) || MergeBrachService::TYPE_LABELED, # labeled | comment | now
  label_name: ENV['INPUT_LABEL_NAME'],
  target_branch: ENV['INPUT_TARGET_BRANCH']
}

MergeBrachService.validate_inputs!(inputs)
service = MergeBrachService.new(inputs, @event)

if service.valid?
  @client = Octokit::Client.new(access_token: @github_token)

  comparison = @client.compare(@repository, inputs[:target_branch], @head_to_merge)
  if comparison.status == 'identical' && presence(ENV['INPUT_DISABLE_FASTFORWARDS']) && ENV['INPUT_DISABLE_FASTFORWARDS'] == "true"
    puts "Neutral: skip fastforward merge target_branch: #{inputs[:target_branch]} @head_to_merge: #{@head_to_merge}"
  else
    puts "Running perform merge target_branch: #{inputs[:target_branch]} @head_to_merge: #{@head_to_merge}}"
    @client.merge(@repository, inputs[:target_branch], @head_to_merge, ENV['INPUT_MESSAGE'] ? {commit_message: ENV['INPUT_MESSAGE']} : {})
    puts "Completed: Finish merge branch #{@head_to_merge} to #{inputs[:target_branch]}"
  end
else
  puts "Neutral: skip merge target_branch: #{inputs[:target_branch]} @head_to_merge: #{@head_to_merge}"
end
