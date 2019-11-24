require 'json'
require 'octokit'

COMMENT_REGEXP = /\/merge to/
BRANCH_REGEXP = /\merge to ([0-9a-zA-Z'-\/]+)/
COMMAND_NAME = "/merge"

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))

@head_to_merge = ENV['GITHUB_SHA'] # or brach name
@repository = ENV['GITHUB_REPOSITORY']
@github_token = ENV['GITHUB_TOKEN']

def match_branch_name(str)
  arr = str.split(/\s+/)
  index = arr.index(COMMAND_NAME)
  arr[index + 2]
end

def base_branch
  comment_message = @event&.dig('comment', 'body')
  base_branch_name =
    if comment_message && comment_message =~ COMMENT_REGEXP
      match_branch_name(comment_message)
    else
      ENV['INPUT_BASE_BRACH']
    end
  raise unless base_branch_name

  base_branch_name
rescue StandardError => e
  raise "Could not find branch name, #{e.message}"
end

def merge_to(base_branch_name)
  @client = Octokit::Client.new(access_token: @github_token)
  @client.merge(@repository, base_branch_name, @head_to_merge)
  puts "Finish merge brach #{base_branch_name}"
end

merge_to(base_branch)
