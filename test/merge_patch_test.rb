require 'test_helper'

require 'json/merge_patch'

describe "README example" do
  it "works properly" do
    document = <<-JSON
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

    merge_patch = <<-JSON
{
  "title": "Hello!",
    "phoneNumber": "+01-123-456-7890",
    "author": {
      "familyName": null
    },
    "tags": ["example"]
}
JSON

    expected = <<-JSON
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
