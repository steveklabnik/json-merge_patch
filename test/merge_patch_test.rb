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

  it "replaces the root whole if the target root is an array" do
    document = <<-JSON.strip_heredoc.chomp
    {"foo":"bar"}
    JSON

    merge_patch = <<-JSON.strip_heredoc.chomp
    ["foo"]
    JSON

    expected = <<-JSON.strip_heredoc.chomp
    ["foo"]
    JSON

    assert_equal expected, JSON.merge(document, merge_patch)
  end
end

describe "section 2" do
=begin
2.  If the root of the JSON data provided in the payload is an
       Object, for each distinct member specified within that object:
=end

  describe "part 1" do
=begin
*  If the member is currently undefined within the target
   resource, and the given value is not null, the member and the
   value are to be added to the target.  Any object member
   contained in the provided data whose value is explicitly null
   is to be treated as if the member were undefined.
=end
  end

  describe "part 2" do
=begin
*  If the value is explicitly set to null and that member is
   currently defined within the target resource, the existing
   member is removed.
=end
  end

  describe "part 3" do
=begin
*  If the value is either a non-null JSON primitive or an Array
   and that member is currently defined within the target
   resource, the existing value for that member is to be replaced
   with that provided.  Any object member contained in the
   provided data whose value is explicitly null is to be treated
   as if the member were undefined.
=end
  end

  describe "part 4" do
=begin
*  If the value is a JSON object and that member is currently
   defined for the target resource and the existing value is a
   JSON primitive or Array, the existing value is to be replaced
   in whole by the object provided.  Any object member contained
   in the provided data whose value is explicitly null is to be
   treated as if the member was undefined.
=end
  end

  describe "part 5" do
=begin
*  If the value is a JSON object and that member is currently
   defined within the target resource and the existing value is
   also a JSON object, then recursively apply Rule #2 to each
   object.
=end
  end

  describe "part 6" do
=begin
*  Any member currently defined within the target resource that
   does not explicitly appear within the patch is to remain
   untouched and unmodified.
=end
    it "leaves well enough alone!" do
      document = <<-JSON.strip_heredoc.chomp
      {
        "content": "This will be unchanged"
      }
      JSON

      merge_patch = <<-JSON.strip_heredoc.chomp
      {
      }
      JSON

      expected = <<-JSON.strip_heredoc.chomp
      {"content":"This will be unchanged"}
      JSON

      assert_equal expected, JSON.merge(document, merge_patch)
    end
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

describe "errors" do
  it "throws an error when stuff goes wrong" do
    assert_raises(JSON::MergeError) do
      JSON.merge(nil, nil)
    end
  end
end
