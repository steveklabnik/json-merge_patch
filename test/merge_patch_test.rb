# frozen_string_literal: true

require 'test_helper'

require 'json/merge_patch'

describe 'Section 1' do
  # 1.  If either the root of the JSON data provided in the payload or
  #     the root of the target resource are JSON Arrays, the target
  #     resource is to be replaced, in whole, by the provided data.  Any
  #     object member contained in the provided data whose value is
  #     explicitly null is to be treated as if the member was undefined.

  describe 'if the root of the data provided is an array' do
    let(:merge_patch) { '["foo"]' }

    it 'replaces the root whole' do
      document = '{"foo":"bar"}'

      expected = '["foo"]'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe 'if the root of the target resource is an array' do
    let(:document) { '["foo"]' }

    it 'replaces the root whole' do
      merge_patch = '{"foo":"bar","bar":null}'

      expected = '{"foo":"bar"}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end
end

describe 'section 2' do
  # 2.  If the root of the JSON data provided in the payload is an
  #        Object, for each distinct member specified within that object:

  describe 'part 1' do
    # *  If the member is currently undefined within the target
    #    resource, and the given value is not null, the member and the
    #    value are to be added to the target.  Any object member
    #    contained in the provided data whose value is explicitly null
    #    is to be treated as if the member were undefined.
    it 'adds members' do
      document = '{"foo":"bar"}'

      merge_patch = '{"foo":"bar","baz":"quxx"}'

      expected = '{"foo":"bar","baz":"quxx"}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe 'part 2' do
    # *  If the value is explicitly set to null and that member is
    #    currently defined within the target resource, the existing
    #    member is removed.
    it 'removes members' do
      document = '{"foo":"bar"}'

      merge_patch = '{"foo":null}'

      expected = '{}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe 'part 3' do
    # *  If the value is either a non-null JSON primitive or an Array
    #    and that member is currently defined within the target
    #    resource, the existing value for that member is to be replaced
    #    with that provided.  Any object member contained in the
    #    provided data whose value is explicitly null is to be treated
    #    as if the member were undefined.
    describe 'object' do
      it 'replaces members' do
        document = '{"foo":"bar"}'

        merge_patch = '{"foo":"baz"}'

        expected = '{"foo":"baz"}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end
  end

  describe 'part 4' do
    # *  If the value is a JSON object and that member is currently
    #    defined for the target resource and the existing value is a
    #    JSON primitive or Array, the existing value is to be replaced
    #    in whole by the object provided.  Any object member contained
    #    in the provided data whose value is explicitly null is to be
    #    treated as if the member was undefined.
    describe 'patch has a primitive' do
      it 'replaces members' do
        document = '{"foo":{"bar":"baz"}}'

        merge_patch = '{"foo":2}'

        expected = '{"foo":2}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end

    describe 'patch has an array' do
      it 'replaces members' do
        document = '{"foo":{"bar":"baz"}}'

        merge_patch = '{"foo":["bar"]}'

        expected = '{"foo":["bar"]}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end
  end

  describe 'part 5' do
    # *  If the value is a JSON object and that member is currently
    #    defined within the target resource and the existing value is
    #    also a JSON object, then recursively apply Rule #2 to each
    #    object.
    describe 'nested objects' do
      it 'recursively ' do
        document = '{"foo":{"bar":"baz"}}'

        merge_patch = '{"foo":{"bar":{"baz":"qux","dev":null}}}'

        expected = '{"foo":{"bar":{"baz":"qux"}}}'

        assert_equal expected, JSON.merge(document, merge_patch)
      end
    end

    it 'recursive removal' do
      document = '{"foo":{"bar":"baz"}}'

      merge_patch = '{"foo":{"bar":null}}'

      expected = '{"foo":{}}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end

  describe 'part 6' do
    # *  Any member currently defined within the target resource that
    #    does not explicitly appear within the patch is to remain
    #    untouched and unmodified.
    it 'leaves well enough alone!' do
      document = '{"content": "This will be unchanged"}'

      merge_patch = '{}'

      expected = '{"content":"This will be unchanged"}'

      assert_equal expected, JSON.merge(document, merge_patch)
    end
  end
end

describe 'missing coverage' do
  it 'deals with a nil patch' do
    document = '{"foo":"bar"}'
    expected = '{"foo":"bar"}'

    assert_equal expected, JSON::MergePatch.new(document, nil).call
  end

  it 'handles primitive true' do
    document = '{"foo":"bar"}'
    patch = '{"foo":true}'
    expected = '{"foo":true}'

    assert_equal expected, JSON.merge(document, patch)
  end

  it 'handles primitive false' do
    document = '{"foo":"bar"}'
    patch = '{"foo":false}'
    expected = '{"foo":false}'

    assert_equal expected, JSON.merge(document, patch)
  end
end

describe 'README example' do
  it 'works properly' do
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

    expected = '{"title":"Hello!","author":{"givenName":"John"},"tags":["example"],"content":"This will be unchanged","phoneNumber":"+01-123-456-7890"}'

    assert_equal expected, JSON.merge(document, merge_patch)
  end
end

describe 'errors' do
  it 'throws an error when stuff goes wrong' do
    assert_raises(JSON::MergeError) do
      JSON.merge(nil, nil)
    end
  end
end
