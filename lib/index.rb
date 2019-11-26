require 'json'
require 'octokit'
require_relative './merge_branch_service'

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
@head_to_merge = ENV['GITHUB_SHA'] # or brach name
@repository = ENV['GITHUB_REPOSITORY']
@github_token = ENV['GITHUB_TOKEN']
@target_branch = ENV['INPUT_TARGET_BRANCH']
@label_name = ENV['INPUT_LABEL_NAME']
@type = ENV['INPUT_TYPE'] || 'labeled' # labeled | comment | push

service = MergeBrachService.new(
  event: @event, type: @type, target_branch: @target_branch, label_name: @label_name
)
service_target_branch = service.ensure_target_branch

if service_target_branch
  @client = Octokit::Client.new(access_token: @github_token)
  @client.merge(@repository, service_target_branch, @head_to_merge)
  puts "Finish merge brach #{service_target_branch}"
else
  puts 'Skip'
end
