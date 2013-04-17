require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  test "tokenizer" do
    search = Search.new "Lorem ipsum sit dolor amet"
    assert_equal search.tokens.length, 5
  end
  test "tokenizer strip puncuation" do
    search = Search.new "Lorem, ipsum sit - dolor amet..."
    assert_equal search.tokens.first, "lorem"
    assert_equal search.tokens.last, "amet"
    assert_equal search.tokens.length, 5
  end
  test "tokenizer don't strip slovene characters" do
    search = Search.new "Šola, je bela"
    assert_equal search.tokens.first, "Šola"
    assert_equal search.tokens.last, "bela"
    assert_equal search.tokens.length, 3
  end
end
