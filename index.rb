require 'octokit'

@event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
puts @event

# @repository = ENV['GITHUB_REPOSITORY']
# @base_brach = ENV['INPUT_BASE_BRACH'] || 'develop'
# @head_to_merge = ENV['GITHUB_SHA'] # or brach name
# @github_token = ENV['GITHUB_TOKEN']

# @client = Octokit::Client.new(access_token: @github_token)

# @client.merge(@repository, @base_brach, @head_to_merge)
