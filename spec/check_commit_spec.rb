require 'pry'
require_relative '../lib/check_commit'

commit_sha = '9f7b8529087fc8ea011a37b1c768960235438795'

puts CheckCommit.new(commit_sha).in_branch?('origin/master')
