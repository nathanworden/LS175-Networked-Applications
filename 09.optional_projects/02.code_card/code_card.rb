require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

get "/" do
  erb :home
end

# get "/cards" do
#   root = File.expand_path("../data/*", __FILE__)
#   @directory = Dir.glob(root).map do |path|
#     File.basename(path)
#   end
#   erb :cards
# end

get "/cards" do
  root = File.expand_path("../data/*", __FILE__)
  @directory = Dir.glob(root).map do |file_path|
    file_contents = File.read(file_path)
    [File.basename(file_path), markdown.render(file_contents)]
  end

  erb :cards
end

get "/practice/:cardnum" do
  root = File.expand_path("../data/*", __FILE__)
  @directory = Dir.glob(root).map do |path|
    File.basename(path)
  end

  card_index = params[:cardnum].to_i
  cardname = @directory[card_index]

  @current_card_index = card_index
  
  file_path = File.expand_path("../data/#{cardname}", __FILE__)
  file_contents = File.read(file_path)
  @contents = markdown.render(file_contents)

  erb :viewcard
end

get "/:cardname" do
  cardname = params[:cardname]
  file_path = File.expand_path("../data/#{cardname}", __FILE__)

  if File.file?(file_path)
    # headers["Content-Type"] = "text/plain"
    file_contents = File.read(file_path)
    @contents = markdown.render(file_contents)
  else
    session[:message] = "#{params[:cardname]} does not exist."
    redirect "/"
  end

  erb :viewcard
end

