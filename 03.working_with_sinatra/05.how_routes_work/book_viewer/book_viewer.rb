require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover?(number)

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end



# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter(query)
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")

    paragraphs = contents.split("\n\n").map do |paragraph|
      "<p>#{paragraph}</p>"
    end

    paragraphs.select! do |paragraph|
      paragraph.include?(query)
    end

    paragraphs.each do |paragraph|
      yield(number, name, contents, paragraph)
    end
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter(query) do |number, name, contents, paragraph|
    results << {number: number, name: name, paragraph: paragraph} if contents.include?(query)
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map do |paragraph| 
      "<p>#{paragraph}</p>"
    end.join
  end
end

get "/show/:name" do
  params[:name]
end

not_found do
  redirect "/"
end





