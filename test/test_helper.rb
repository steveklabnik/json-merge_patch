require 'minitest/autorun'

def pending
  begin
    yield
    fail "OMG pending test passed."
  rescue MiniTest::Assertion
    skip "Still pending"
  end
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.send(:size) || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
