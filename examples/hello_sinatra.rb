# myapp.rb
require 'sinatra'

get '/' do
  'Hello world!'
end

get "/emacs" do
  redirect to("/vim")
end

get "/vim" do
  "vim rules"
end


post '/foo' do
  puts request.env
  "done"
end


post "/api/v1/datapoints" do
  puts request.env
  "done"
end
