require 'json'
require 'octokit'
require_relative './labeled_adapter'
require_relative './push_adapter'

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
@head_to_merge = ENV['GITHUB_SHA'] # or brach name
@repository = ENV['GITHUB_REPOSITORY']
@github_token = ENV['GITHUB_TOKEN']
@base_branch = ENV['INPUT_BASE_BRANCH']
@label_name = ENV['INPUT_LABEL_NAME']
@type = ENV['INPUT_TYPE'] || 'push' # labeled | push

def merge_to(base_branch_name)
  @client = Octokit::Client.new(access_token: @github_token)
  @client.merge(@repository, base_branch_name, @head_to_merge)
  puts "Finish merge brach #{base_branch_name}"
end

def build_adapter
  case @type
  when 'push'
    PushAdapter.new(@event, @base_branch)
  when 'labeled'
    LabeledAdapter.new(@event, @base_branch, @label_name)
  end
end

def run
  adapter = build_adapter
  unless adapter.valid?
    puts 'Skip'
    return 'Skip'
  end

  adapter.base_branch.tap do |base_branch|
    raise 'Could not find branch name' unless base_branch

    merge_to(base_branch)
  end
end

run
