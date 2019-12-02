require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  # @files = Dir.glob("public/*.*").map {|file| File.basename(file)}.sort
  @files = Dir.glob("public/*").select {|file| File.ftype(file) == "file" }
  @files.map! {|file| File.basename(file) }.sort
  @files.reverse! if params[:sort] == "desc"
  erb :list
end