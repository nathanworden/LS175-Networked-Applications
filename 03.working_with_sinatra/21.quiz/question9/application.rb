require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/course/:course/instructor/:instructor" do |course, instructor|
  @course_id = params[:course]
  @instructor_id = params[:instructor]
  erb :index, layout: :index
end

get "/update" do
  @course_id = "WOWieZowie!"
  redirect "/new/page?"
end

post "/new/page" do
  @course_id = "this is new"
  erb :index
end

# not_found do
#   @instructor_id = "dog"
#   erb :index
# end

# error do
#     @instructor_id = "cat"
#   erb :index
# end

# default do
#   @instructor_id = "bat"
#   erb :index
# end

# post "/bad" do
#   @instructor_id = "bat"
#   erb :index
# end




