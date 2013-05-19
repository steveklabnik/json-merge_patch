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

  describe "if the root of the data provided is an array" do
    let(:merge_patch) { %q'["foo"]' }

    it "replaces the root whole" do
      document = %q'{"foo":"bar"}'

      expected = %q'["foo"]'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe "if the root of the target resource is an array" do
    let(:document) { %q'["foo"]' }

    it "replaces the root whole" do
      merge_patch = %q'{"foo":"bar","bar":null}'

      expected = %q'{"foo":"bar"}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
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
    it "adds members" do
      document = %q'{"foo":"bar"}'

      merge_patch = %q'{"foo":"bar","baz":"quxx"}'

      expected = %q'{"foo":"bar","baz":"quxx"}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe "part 2" do
=begin
*  If the value is explicitly set to null and that member is
   currently defined within the target resource, the existing
   member is removed.
=end
    it "removes members" do
      document = %q'{"foo":"bar"}'

      merge_patch = %q'{"foo":null}'

      expected = %q'{}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
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
    describe "object" do
      it "replaces members" do
        document = %q'{"foo":"bar"}'

        merge_patch = %q'{"foo":"baz"}'

        expected = %q'{"foo":"baz"}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end
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
    describe "patch has a primitive" do
      it "replaces members" do
        document = %q'{"foo":{"bar":"baz"}}'

        merge_patch = %q'{"foo":2}'

        expected = %q'{"foo":2}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end

    describe "patch has an array" do
      it "replaces members" do
        document = %q'{"foo":{"bar":"baz"}}'

        merge_patch = %q'{"foo":["bar"]}'

        expected = %q'{"foo":["bar"]}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end
  end

  describe "part 5" do
=begin
*  If the value is a JSON object and that member is currently
   defined within the target resource and the existing value is
   also a JSON object, then recursively apply Rule #2 to each
   object.
=end
    describe "nested objects" do
      it "recursively " do
        document = %q'{"foo":{"bar":"baz"}}'

        merge_patch = %q'{"foo":{"bar":{"baz":"qux","dev":null}}}'

        expected = %q'{"foo":{"bar":{"baz":"qux"}}}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end

    it "recursive removal" do
      document = %q'{"foo":{"bar":"baz"}}'

      merge_patch = %q'{"foo":{"bar":null}}'

      expected = %q'{"foo":{}}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe "part 6" do
=begin
*  Any member currently defined within the target resource that
   does not explicitly appear within the patch is to remain
   untouched and unmodified.
=end
    it "leaves well enough alone!" do
      document = %q'{"content": "This will be unchanged"}'

      merge_patch = %q'{}'

      expected = %q'{"content":"This will be unchanged"}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end
end

describe "missing coverage" do
  it "deals with a nil patch" do
    document = %q'{"foo":"bar"}'
    expected = %q'{"foo":"bar"}'

    assert_equal expected, JSON::MergePatch.new(document, nil).call
  end

  it "handles primitive true" do
    document = %q'{"foo":"bar"}'
    patch = %q'{"foo":true}'
    expected = %q'{"foo":true}'

    assert_equal expected, JSON.merge(document, patch)
  end

  it "handles primitive false" do
    document = %q'{"foo":"bar"}'
    patch = %q'{"foo":false}'
    expected = %q'{"foo":false}'

    assert_equal expected, JSON.merge(document, patch)
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

    expected = %q'{"title":"Hello!","author":{"givenName":"John"},"tags":["example"],"content":"This will be unchanged","phoneNumber":"+01-123-456-7890"}'

    assert_equal expected, JSON.merge(document, merge_patch)
  end
end

describe "errors" do
  it "throws an error when stuff goes wrong" do
    assert_raises(JSON::MergeError) do
      JSON.merge(nil, nil)
    end
  end
end
