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
      if @patch.nil?
        return @orig
      elsif @patch.kind_of?(Array) || @orig.kind_of?(Array)
        @orig = purge_nils(@patch)
      elsif is_primitive?(@patch) || is_primitive?(@orig)
        @orig = @patch
      elsif @patch.kind_of?(Hash)
        @patch.each_key do |m|
          patch_key(m)
        end
      end
      @orig
    end

    private

    def patch_key(m)
      if @patch[m].nil? && @orig.has_key?(m)
        @orig.delete(m) 
      else
        @orig[m] = self.class.new(@orig[m], @patch[m]).call
      end
    end

    def is_primitive?(val)
      [String,    Fixnum,
       TrueClass, FalseClass].include?(val.class)
    end

    def purge_nils(obj)
      return nil if obj.nil?
      return obj.compact if obj.kind_of?(Array)
      return obj if is_primitive?(obj)

      obj.delete_if {|k, v| v.nil? }
    end
  end
end
