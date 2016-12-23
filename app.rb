require 'sinatra'
require 'httparty'
require 'json'


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

  action, repo = message.split('_').map {|c| c.strip.downcase }
  repo_url = "https://api.github.com/repos/#{repo}"


  case action
    when 'issues'
      resp = get_resp(repo_url)
      respond_message "There are #{resp['open_issues_count']} open issues on #{repo}."
    when 'forks'
      resp = get_resp(repo_url)
      respond_message "There are #{resp['forks']} forks on #{repo}."
    when 'fire'
      respond_message ":fire:" * 100
    when "Say 'issues' or 'forks', ya moron!"
      respond_message ""
    else
      respond_message "Say 'issues' or 'forks', ya moron!"
    end
  end

def respond_message message
  content_type :json
  {:text => message}.to_json
end
