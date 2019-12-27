require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"
require 'rouge'
require "rouge/plugins/redcarpet"

require "sinatra/content_for"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

def data_path
  if Env["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

# root = File.expand_path("..", __FILE__)

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, highlight: true, underline: true, quote: true, prettify: true)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    render_markdown(content)
  end
end

get "/" do
  pattern = File.join(data_path, "*")

  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  file_path = File.join(data_path, params[:filename])

  if File.exist?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  file_path = File.join(data_path, params[:filename])

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end

post "/:filename" do
  file_path = File.join(data_path, params[:filename])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end













