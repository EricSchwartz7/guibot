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

  got_url = "http://www.anapioficeandfire.com/api/"
  action, repo = message.split(' ').map {|c| c.strip.downcase }
  repo_url = "https://api.github.com/repos/#{repo}"
  resp = get_resp(repo_url)


  case action

    when 'issues'
      respond_message "There are #{resp['open_issues_count']} open issues on #{repo}."
    when 'forks'
      respond_message "There are #{resp['forks']} forks on #{repo}."
    when 'fire'
      respond_message ":fire:" * 100
    when 'charbynum'
      resp = get_resp("#{got_url}characters/#{repo}")
      respond_message "#{resp['name']}"
    when 'house'
      resp = get_resp("#{got_url}houses/#{repo}")
      names = resp['swornMembers'].collect do |char|
        get_resp("#{char}")['name']
      end.join("\n")
      # binding.pry
      respond_message "There are #{resp['swornMembers'].count} members in #{resp['name']}. Their names are as follows:\n#{names}"

    # This was not firing because the input is being downcased and we were checking for
    # a string that had the first letter capitalized
    # when "say 'issues' or 'forks', ya moron!"
    #   respond_message " "
    # else
    #   respond_message "Say 'issues' or 'forks', ya moron!"

    end
  end

def respond_message message
  content_type :json
  {:text => message}.to_json
end
