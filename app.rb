require 'sinatra'
require 'httparty'
require 'json'


get '/' do
  erb :show
end

## Receive post at '/gateway' and send to repo_url
post '/gateway' do
  message = params[:text].gsub(params[:trigger_word], '').strip

  action, repo = message.split('_').map {|c| c.strip.downcase }
  repo_url = "https://api.github.com/repos/#{repo}"

  case action
    when 'issues'
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message "There are #{resp['open_issues_count']} open issues on #{repo}."
    when 'forks'
      respond_message "There are #{resp['forks']} forks on #{repo}."
    else
      respond_message "Say 'issues' or 'forks', ya moron!"
    end
  end

def respond_message message
  content_type :json
  {:text => message}.to_json
end
