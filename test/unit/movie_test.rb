require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test "Should not save empty movies" do
    assert ! Movie.new.save
  end
end
