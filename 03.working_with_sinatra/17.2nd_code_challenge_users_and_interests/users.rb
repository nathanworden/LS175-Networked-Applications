require 'yaml'

require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @users = YAML.load_file("users.yaml")
  @num_users = @users.count
end

helpers do
  def not_last(interest)
    interest != @interests.last
  end

  def count_interests(users)
    users.reduce(0) do |acc, (key, value)|
      acc + value[:interests].size
    end
  end
end

get "/" do
  @title = "Homehome"
  @contents

  erb :home
end

get "/:name" do

  @title = "Frwinds"
  @name = params[:name].to_sym

  redirect "/" unless @users[@name]

  @info = @users[@name]
  @email = @info[:email]
  @interests = @info[:interests]

  erb :user
end






