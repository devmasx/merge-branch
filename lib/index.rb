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

  page_number = 1
  merge_success = []
  merge_failure = []

  while (page = @client.branches(@repository, page: page_number)).length.positive?
    page.each do |branch|
      if branch.name.match?(inputs[:target_branch])
        puts "Running perform merge target_branch: #{branch.name} @head_to_merge: #{@head_to_merge}}"

        if @client.merge(@repository, branch.name, @head_to_merge, ENV['INPUT_MESSAGE'] ? {commit_message: ENV['INPUT_MESSAGE']} : {})&.key?(sha)
          puts "Completed: Finish merge branch #{@head_to_merge} to #{branch.name}"
          merge_success << branch.name
        else
          puts "Error: Failed to merge branch #{@head_to_merge} to #{branch.name}"
          merge_failure << branch.name
        end
      end
    end
    page_number += 1
  end

  # github uses an env file for passing values as environment variables between concurrent job steps
  File.open(ENV['GITHUB_ENV'], 'a') do |env|
    env << "MERGE_SUCCESS=#{merge_success.join(', ')}"
    env << "MERGE_FAILURE=#{merge_failure.join(', ')}"
  end

  return merge_failure.length.positive? ? 1 : 0
else
  puts "Neutral: skip merge target_branch: #{inputs[:target_branch]} @head_to_merge: #{@head_to_merge}"
end
