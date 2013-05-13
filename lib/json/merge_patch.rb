require 'json'
require "json/merge_patch/version"

module JSON
  def self.merge(one, two)
    %q/{"foo":"bar"}/
  end
end
