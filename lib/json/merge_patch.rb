require 'json'
require "json/merge_patch/version"

require 'json/merge_patch/railtie' if defined?(Rails)

module JSON
  # This represents an error that occurs during merging.
  MergeError = Class.new(StandardError)

  # Merges a patch into the existing JSON document.
  #
  # @param document [String] the original JSON document.
  # @param merge_patch [Symbol] the merge-patch JSON document.
  # @return [String] the final document after applying the patch
  def self.merge(document, merge_patch)
    orig = JSON.parse(document)
    patch = JSON.parse(merge_patch)
    JSON.dump(MergePatch.new(orig, patch).call)
  rescue
    raise MergeError
  end

  # This class represents a merge patch.
  class MergePatch

    # Sets up a MergePatch.
    #
    # @param orig [Object] the original document
    # @param patch [Object] the patch document
    def initialize(orig, patch)
      @orig = orig
      @patch = patch
    end

    # Applies the patch the original object.
    #
    # @return [Object] the document after applying the patch.
    def call
      return @orig if @patch.nil?

      merge @orig, @patch
    end

    private

    def merge(orig, patch)
      if is_array_or_primitive?(orig) || is_array_or_primitive?(patch)
        orig = patch
      else
        patch.each_key { |key| orig[key] = merge(orig[key], patch[key]) }
      end

      purge_nils orig
    end

    def is_array_or_primitive?(obj)
      obj.kind_of?(Array) || is_primitive?(obj)
    end

    def is_primitive?(val)
      [ String, Fixnum,
        TrueClass, FalseClass,
        NilClass, Float
      ].include?(val.class)
    end

    def purge_nils(obj)
      return obj if is_primitive?(obj)
      return obj.compact if obj.kind_of?(Array)

      obj.delete_if {|k, v| v.nil? }
    end
  end
end
