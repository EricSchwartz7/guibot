require 'sinatra'
require 'httparty'
require 'json'
require 'pry'


get '/' do
  erb :show
end

def get_resp(repo_url)
  resp = HTTParty.get(repo_url)
  JSON.parse resp.body
end


## Receive post at '/gateway' and send to repo_url
post '/gateway' do
  message = params[:text]
  # .gsub(params[:trigger_word], '').strip

  # We could also use a space instead of an underscore, and it works fine

  action, repo = message.split(' ').map {|c| c.strip.downcase }
  repo_url = "https://api.github.com/repos/#{repo}"
  got_url = "http://www.anapioficeandfire.com/api/characters/#{repo}"

  case action

    when 'issues'
      resp = get_resp(repo_url)
      respond_message "There are #{resp['open_issues_count']} open issues on #{repo}."
    when 'forks'
      resp = get_resp(repo_url)
      respond_message "There are #{resp['forks']} forks on #{repo}."
    when 'fire'
      respond_message ":fire:" * 100
    when 'got'
      resp = get_resp(got_url)
      respond_message "#{resp['name']}"

    # This was not firing because the input is being downcased and we were checking for
    # a string that had the first letter capitalized
    when "say 'issues' or 'forks', ya moron!"
      respond_message " "
    else
      respond_message "Say 'issues' or 'forks', ya moron!"

    end
  end

def respond_message message
  content_type :json
  {:text => message}.to_json
end
