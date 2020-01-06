require "sinatra"
require "sinatra/reloader" if development?
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

def today_cards
  session[:questions].select {|question, data| data[:show_today] }
end

def lowest_rank
  today_cards.values.map {|card_data| card_data[:times_shown] }.min
end

def next_card
  today_cards.select {|_, card| card[:times_shown] == lowest_rank }.first
end

def card_name_from_card_num(current_card_num)
  "question" + params[:current_card_num] + ".md"
end

before do
  pattern = File.join(data_path, "*")
  directory = Dir.glob(pattern).map do |file_path|
    [File.basename(file_path), {show_today: true, times_shown: 0}]
  end.to_h

  session[:questions] ||= directory.select {|card| card.include?("question")}
  session[:answers] ||= directory.select {|card| card.include?("answer")}
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

class CodeRayify < Redcarpet::Render::HTML
  def block_code(code, language)
    CodeRay.scan(code, language).div(:line_numbers => :table)
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

  session[:current_card_num] ||= rand(@directory.size) + 1

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
  card_name = card_name_from_card_num(params[:current_card_num])
  toggle_show_today(params, card_name)
  session[:questions][card_name][:times_shown] += 1

  redirect "/finishstudy" if today_cards.empty?

  current_card_num = (next_card[0].scan(/\d/)[0]) 

  session[:current_card_num] = current_card_num

  redirect "/practice"
end

get "/finishstudy" do
  @congrats = "Congratulations! You have finished this deck for now."

  erb :congrats
end

get "/practice" do
  redirect "/finishstudy" if today_cards.empty?

  questions = session[:questions]#.keys.sort
  answers = session[:answers].keys.sort

  @match_answer = answers.select {|file| (file.scan(/\d/).join)  == session[:current_card_num].to_s}

  card_index = session[:current_card_num]
  @card_index = card_index

  @cardname = questions.select {|key, value| key.scan(/\d/).join == card_index.to_s }.keys[0]
  
  question_file_path = File.expand_path("../data/#{@cardname}", __FILE__)
  question_file_contents = File.read(question_file_path)
  @question_contents = markdown.render(question_file_contents)

  answer_file_path = File.expand_path("../data/#{@match_answer[0]}", __FILE__)
  answer_file_contents = File.read(answer_file_path)

  # @answer_contents = markdown_ruby(answer_file_contents)
  @linespacer = markdown.render("---")

  no_code, @code_block = answer_file_contents.split("```ruby")

  @answer_contents = markdown_ruby(no_code)

  "#{no_code} ----DARLING, I PACKED YOU LUNCH ---- #{@code_block}"
  # erb :viewcard
end

# get "/:cardname" do
#   cardname = params[:cardname]
#   file_path = File.expand_path("../data/#{cardname}", __FILE__)
#   # file_path = File.join(data_path, params[:cardname])

#   if File.file?(file_path)
#     # headers["Content-Type"] = "text/plain"
#     file_contents = File.read(file_path)
#     @contents = markdown.render(file_contents)
#   else
#     session[:message] = "#{params[:cardname]} does not exist."
#     redirect "/"
#   end

#   erb :viewcard
# end

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




