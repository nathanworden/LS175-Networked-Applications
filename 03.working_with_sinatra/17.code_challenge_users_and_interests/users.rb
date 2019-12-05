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

  def count_interests
    num_interests = []
    @users.each do |name, info|
      num_interests << @users[name][:interests].count
    end

    num_interests.sum
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






