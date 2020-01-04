require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

# before do
#   session[:num] = "dog"
# end

get "/" do
  session[:num] ||= "dog"
  @session_num = session[:num]
  p "session"
  p session

  erb :home
end

get "/aboutpage" do
  p "about page session"
  session[:num] = session[:num] + "cat"
  p session
  @session_num = session[:num] 

  erb :aboutpage
end





