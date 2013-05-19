require 'json'
require "json/merge_patch/version"

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
          if @orig.has_key?(m)
            if @patch[m].nil?
              @orig.delete(m)
            else
              if is_primitive?(@patch[m])
                @orig[m] = @patch[m]
              else
                if @orig[m].kind_of?(Array)
                  @orig[m] = purge_nils(@patch[m])
                else
                  @orig[m] = self.class.new(@orig[m], @patch[m]).call
                end
              end
            end
          elsif !(@patch[m].nil?)
            @orig[m] = purge_nils(@patch[m])
          end
        end
      end
      @orig
    end

    private

    def is_primitive?(val)
      case val
      when String
        true
      when Fixnum
        true
      when TrueClass
        true
      when FalseClass
        true
      else
        false
      end
    end

    def purge_nils(obj)
      return nil if obj.nil?
      return obj.compact if obj.kind_of?(Array)
      return obj if is_primitive?(obj)

      obj.each do |m|
        if obj[m].nil?
          obj.delete(m)
        end
      end
      obj
    end
  end
end
