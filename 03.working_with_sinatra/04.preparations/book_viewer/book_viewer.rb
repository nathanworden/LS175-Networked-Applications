require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @title = "Los Tiburones de Senior Sherlock"
  erb :home
end
