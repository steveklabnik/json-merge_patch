require 'minitest/autorun'

def pending
  begin
    yield
    fail "OMG pending test passed."
  rescue MiniTest::Assertion
    skip "Still pending"
  end
end
