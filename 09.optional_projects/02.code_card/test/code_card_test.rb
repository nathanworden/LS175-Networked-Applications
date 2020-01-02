ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../code_card.rb"

class CodeCardTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Cards"
    assert_includes last_response.body, "Practice"
    assert_includes last_response.body, "Add Card"
  end

  def test_viewing_text_document
    get "/card1.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "polymorphism"
  end
end


