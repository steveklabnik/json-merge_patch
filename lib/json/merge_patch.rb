require 'json'
require "json/merge_patch/version"

module JSON
  MergeError = Class.new(StandardError)

  def self.merge(document, merge_patch)
    document = JSON.parse(document)
    merge_patch = JSON.parse(merge_patch)

    if merge_patch.is_a? Array
      return JSON.dump(merge_patch)
    end

    if document.is_a? Array
      return JSON.dump(merge_patch)
    end

    if merge_patch.is_a? Hash
      document.merge!(merge_patch)
      document.delete_if {|k, v| v.nil? }
      return JSON.dump(document)
    end
  rescue 
    raise MergeError
  end
end
