# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter do |source_file|
    source_file.filename =~ /test/
  end
end

require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'

def pending
  yield
  raise 'OMG pending test passed.'
rescue MiniTest::Assertion
  skip 'Still pending'
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.send(:size) || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
