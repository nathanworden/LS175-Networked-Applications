require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"
require "coderay"

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

def toggle_show_today(params, card_name)
  if params.key?("hard")
    session[:questions][card_name][:show_today] = true
  elsif params.key?("medium")
    session[:questions][card_name][:show_today] = false
  elsif params.key?("easy")
    session[:questions][card_name][:show_today] = false
  end
end

before do
  pattern = File.join(data_path, "*")
  directory = Dir.glob(pattern).map do |file_path|
    [File.basename(file_path), {show_today: true, times_shown: 0}]
  end.to_h

  session[:num] = 1
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

class CodeRayify < Redcarpet::Render::HTML
  def block_code(code, language)
    CodeRay.scan(code, language).div#(:line_numbers => :table)
  end
end

def markdown_ruby(text)
  coderayified = CodeRayify.new(:filter_html => true,
                                :hard_wrap => true)
  options = {
    :fenced_code_blocks => true,
    :no_intra_emphasis => true,
    :autolink => true,
    :strikethrough => true,
    :lax_html_blocks => true,
    :superscript => true
  }
  markdown_to_html = Redcarpet::Markdown.new(coderayified, options)
  markdown_to_html.render(text)
end

get "/" do
  pattern = File.join(data_path, "*")
  directory = Dir.glob(pattern).map do |file_path|
    file_contents = File.read(file_path)
    File.basename(file_path)
  end

  @directory = directory.select {|file| file.include?("question")}

  session[:current_card_num] = rand(@directory.size)
  @start = session[:current_card_num]

  puts session[:num]
  @session_num = session[:num]
  p "session"
  p session

  erb :home
end

get "/aboutpage" do
  puts session[:num]
  @session_num = session[:num] 
  p "about page session"
  p session
  session[:num] += 1
  p session

  erb :aboutpage
end

get "/cards" do
  # root = File.expand_path("../data/*", __FILE__)
  pattern = File.join(data_path, "*")
  @directory = Dir.glob(pattern).map do |file_path|
    file_contents = File.read(file_path)
    [File.basename(file_path), markdown.render(file_contents)]
  end

  @linespacer = markdown.render("---")

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
  card_name = "question" + (params[:current_card_num].to_i + 1).to_s + ".md"

  session[:questions][card_name][:times_shown] += 1
  session[:testing] += 1
  toggle_show_today(params, card_name)

  today_cards = session[:questions].select {|question, data| data[:show_today] }
  if today_cards.empty?
    redirect "/finishstudy"
  end

  lowest_rank = today_cards.values.map {|card_data| card_data[:times_shown] }.min
  next_card = today_cards.select {|_, card| card[:times_shown] == lowest_rank }.first

  current_card_num = (next_card[0].scan(/\d/)[0].to_i - 1).to_s # 1 needs to be subtracted because we added 1 to get the card name, which aren't 0 indexed.

  # "#{session[:questions]}"
  redirect "/practice/#{current_card_num}"
end

get "/finishstudy" do
  "Congratulations! You have finished this deck for now."
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

  @answer_contents = markdown_ruby(answer_file_contents)

  @linespacer = markdown.render("---")

  @session_questions = session[:questions]  # testing

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




