require 'test_helper'

require 'json/merge_patch'

describe "Section 1" do
=begin
1.  If either the root of the JSON data provided in the payload or
    the root of the target resource are JSON Arrays, the target
    resource is to be replaced, in whole, by the provided data.  Any
    object member contained in the provided data whose value is
    explicitly null is to be treated as if the member was undefined.
=end
  it "replaces the root whole if the payload root is an array" do
    document = <<-JSON.strip_heredoc.chomp
    ["foo"]
    JSON

    merge_patch = <<-JSON.strip_heredoc.chomp
    {"foo":"bar"}
    JSON

    expected = <<-JSON.strip_heredoc.chomp
    {"foo":"bar"}
    JSON

    assert_equal expected, JSON.merge(document, merge_patch)
  end
end

describe "README example" do
  it "works properly" do
    document = <<-JSON.strip_heredoc.chomp
    {
      "title": "Goodbye!",
        "author" : {
          "givenName" : "John",
          "familyName" : "Doe"
        },
        "tags":["example","sample"],
        "content": "This will be unchanged"
    }
    JSON

    merge_patch = <<-JSON.strip_heredoc.chomp
    {
      "title": "Hello!",
        "phoneNumber": "+01-123-456-7890",
        "author": {
          "familyName": null
        },
        "tags": ["example"]
    }
    JSON

    expected = <<-JSON.strip_heredoc.chomp
    {
      "title": "Goodbye!",
      "author" : {
      "phoneNumber": "+01-123-456-7890",
      "givenName" : "John",
      },
      "tags":["example"],
      "content": "This will be unchanged"
    }
    JSON

    pending do 
      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end
end
