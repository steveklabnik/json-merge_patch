# Json::MergePatch

This gem augments Ruby's built-in JSON library to support merging JSON blobs
in accordance with the [draft-snell-merge-patch
draft](http://tools.ietf.org/html/draft-snell-merge-patch-08).

## Installation

Add this line to your application's Gemfile:

    gem 'json-merge_patch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-merge_patch

## Usage

First, require the gem:

```
require 'json/merge_patch'
```

Then, use it:

```
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
  "title": "Goodbye!",
  "author" : {
    "phoneNumber": "+01-123-456-7890",
    "givenName" : "John",
  },
  "tags":["example"],
  "content": "This will be unchanged"
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
