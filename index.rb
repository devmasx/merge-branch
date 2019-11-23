require 'json'
require 'octokit'

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
puts @event

@repository = ENV['GITHUB_REPOSITORY']
@base_brach = ENV['INPUT_BASE_BRACH'] || 'develop'
@head_to_merge = ENV['GITHUB_SHA'] # or brach name
@github_token = ENV['GITHUB_TOKEN']

def merge_to(base_branch_name)
  @client = Octokit::Client.new(access_token: @github_token)
  @client.merge(@repository, base_branch_name, @head_to_merge)
  puts "Finish merge brach #{@head_to_merge}"
end

merge_to(@base_brach)