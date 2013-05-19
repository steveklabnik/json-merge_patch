# JSON::MergePatch

[![Build Status](https://travis-ci.org/steveklabnik/json-merge_patch.png)](https://travis-ci.org/steveklabnik/json-merge_patch) [![Code Climate](https://codeclimate.com/github/steveklabnik/json-merge_patch.png)](https://codeclimate.com/github/steveklabnik/json-merge_patch) [![Coverage Status](https://coveralls.io/repos/steveklabnik/json-merge_patch/badge.png)](https://coveralls.io/r/steveklabnik/json-merge_patch)

This gem augments Ruby's built-in JSON library to support merging JSON blobs
in accordance with the [draft-snell-merge-patch
draft](http://tools.ietf.org/html/draft-snell-merge-patch-08).

As far as I know, it is a complete implementation of the draft. If you find
something that's not compliant, please let me know.

## Installation

Add this line to your application's Gemfile:

    gem 'json-merge_patch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-merge_patch

## Usage

First, require the gem:

```ruby
require 'json/merge_patch'
```

Then, use it:

```ruby
# The example from http://tools.ietf.org/html/draft-snell-merge-patch-08#section-2

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

JSON.merge(document, merge_patch)
# => 
{
  "title": "Hello!",
  "phoneNumber": "+01-123-456-7890",
  "author" : {
    "givenName" : "John",
  },
  "tags":["example"],
  "content": "This will be unchanged"
}
```

If you'd prefer to operate on pure Ruby objects rather than JSON strings, you
can construct a `MergePatch` object instead.

```
JSON::MergePatch.new({}, {"foo" => "bar"}).call
=> {"foo"=>"bar"}
```

Also check out [http://json-merge-patch.herokuapp.com/](http://json-merge-patch.herokuapp.com/),
which is a Rails app that serves up `json-merge-patch` responses.

### Use in Rails

JSON::MergePatch provides a Railtie that registers the proper MIME type with
Rails. To use it, do something like this:

```
def update
  safe_params = params.require(:merge).permit(:original, :patch)

  @result = JSON::MergePatch.new(
    safe_params[:original],
    safe_params[:patch]
  ).call

  respond_to do |format|
    format.json_merge_patch do
      render :json => @result
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
