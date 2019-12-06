require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

get "/" do 
  redirect "/lists"
end

# GET  /lists       -> view all lists
# GET  /lists/new   -> new list form
# POST /lists       -> create new list
# GET /lists/1      -> view a single list
# GET /users
# GET /users/1



# View list of lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

get "/lists/new" do
  erb :new_list, layout: :layout
end

# Render the new list form
get "/lists/delete" do
  session[:lists].pop
  redirect "/lists"
end

# Create a new list
post "/lists" do
  session[:lists] <<{name: params[:list_name], todos:[]}
  redirect "/lists"
end





