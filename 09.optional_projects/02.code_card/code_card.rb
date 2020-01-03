require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

get "/" do
  pattern = File.join(data_path, "*")
  directory = Dir.glob(pattern).map do |file_path|
    file_contents = File.read(file_path)
    File.basename(file_path)
  end

  @directory = directory.select {|file| file.include?("question")}

  session[:current_card_num] = rand(@directory.size)
  @start = session[:current_card_num]

  erb :home
end

get "/aboutpage" do
  erb :aboutpage
end

get "/cards" do
  # root = File.expand_path("../data/*", __FILE__)
  pattern = File.join(data_path, "*")
  @directory = Dir.glob(pattern).map do |file_path|
    file_contents = File.read(file_path)
    [File.basename(file_path), markdown.render(file_contents)]
  end

  erb :cards
end

get "/addcard" do
  erb :addquestion
end

post "/addquestion" do
  pattern = File.join(data_path, "*")
  @directory = Dir.glob(pattern).map do |file_path|
    File.basename(file_path)
  end

  questions = @directory.select {|filename| filename.include?("question")}.sort
  last_question_num = questions[-1].scan(/\d/)
  new_question_num = (last_question_num[0].to_i + 1).to_s
  new_question_name = "question" + new_question_num[0] + ".md"

  session[:new_question_num] = new_question_num # This is to be used in the 'post "/addanswer" route below.

  file_path = File.join(data_path, new_question_name)
  File.write(file_path, params[:add_question])

  question_file_contents = File.read(file_path)
  @question_contents = markdown.render(question_file_contents)

  session[:message] = "A new card has been created. (number #{new_question_num})"
  
  erb :addanswer
end

post "/addanswer" do
  pattern = File.join(data_path, "*")
  @directory = Dir.glob(pattern).map do |file_path|
    File.basename(file_path)
  end

  new_answer_num = session[:new_question_num]
  new_answer_name = "answer" + new_answer_num + ".md"

  file_path = File.join(data_path, new_answer_name)
  File.write(file_path, params[:add_answer])

session[:message] = "A new card has been created."

  redirect "/cards"
end


post "/practice/nextcard/:current_card_num" do
  pattern = File.join(data_path, "*")
  @directory = Dir.glob(pattern).map do |file_path|
    [file_path, File.basename(file_path), 10]
  end

  questions = @directory.select {|filename| filename[1].include?("question")}
  current_card_num = (params[:current_card_num].to_i + 1) % questions.size

  "#{questions} random string, and current_card_num: #{current_card_num} "
  
  redirect "/practice/#{current_card_num}"
end

get "/practice/:cardnum" do
  # root = File.expand_path("../data/*", __FILE__)
  pattern = File.join(data_path, "*")
  @directory = Dir.glob(pattern).map do |path|
    File.basename(path)
  end

  questions = @directory.select {|filename| filename.include?("question")}.sort
  @answers = @directory.select {|filename| filename.include?("answer")}.sort
  @match_answer = @answers.select {|file| (file.scan(/\d/).join.to_i - 1).to_s  == params[:cardnum]}

  card_index = params[:cardnum].to_i
  @card_index = card_index
  cardname = questions[card_index]
  
  question_file_path = File.expand_path("../data/#{cardname}", __FILE__)
  question_file_contents = File.read(question_file_path)
  @question_contents = markdown.render(question_file_contents)

  answer_file_path = File.expand_path("../data/#{@match_answer[0]}", __FILE__)
  answer_file_contents = File.read(answer_file_path)
  @answer_contents = markdown.render(answer_file_contents)

  erb :viewcard
end

get "/:cardname" do
  cardname = params[:cardname]
  file_path = File.expand_path("../data/#{cardname}", __FILE__)
  # file_path = File.join(data_path, params[:cardname])

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

post "/:cardname" do
  cardname = params[:cardname]
  # file_path = File.expand_path("../data/#{cardname}", __FILE__)
  file_path = File.join(data_path, params[:cardname])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:cardname]} has been updated."
  redirect "/"
end

get "/:cardname/edit" do
  cardname = params[:cardname]

  answer_card_name = "answer" + cardname.scan(/\d/).join + ".md"
  @answer_cardname = answer_card_name
  @answer_card_num = cardname.scan(/\d/).join

  # question_file_path = File.expand_path("../data/#{cardname}", __FILE__)
  # answer_file_path = File.expand_path("../data/#{answer_card_name}", __FILE__)
  question_file_path = File.join(data_path, params[:cardname])
  answer_file_path = File.join(data_path, answer_card_name)

  @question_cardname_display = cardname.scan(/\d/).join
  @question_cardname = params[:cardname]

  @question_content = File.read(question_file_path)
  @answer_content = File.read(answer_file_path)

  erb :editcard
end




