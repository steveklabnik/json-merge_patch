require 'json'
require "json/merge_patch/version"

module JSON
  MergeError = Class.new(StandardError)

  def self.merge(document, merge_patch)
    orig = JSON.parse(document)
    patch = JSON.parse(merge_patch)
    JSON.dump(apply(orig,patch))
  rescue
    raise MergeError
  end

  def self.apply(orig, patch)
    if patch.nil?
      return orig
    elsif patch.kind_of?(Array) || orig.kind_of?(Array)
      orig = purge_nils(patch)
    elsif is_primitive?(patch) || is_primitive?(orig)
      orig = patch
    elsif patch.kind_of?(Hash)
      patch.each_key do |m|
        if orig.has_key?(m)
          if patch[m].nil?
            orig.delete(m)
          else
            if is_primitive?(patch[m])
              orig[m] = patch[m]
            else
              if orig[m].kind_of?(Array)
                result = purge_nils(patch[m])
                if result.nil?
                  orig.delete(m)
                else
                  orig[m] = result
                end
              else
                orig[m] = apply(orig[m], patch[m])
              end
            end
          end
        elsif !(patch[m].nil?)
          result = purge_nils(patch[m])
          if result.nil?
            orig.delete(m)
          else
            orig[m] = result
          end
        end
      end
    end
    orig
  end

  def self.is_primitive?(val)
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

  def self.purge_nils(obj)
    return nil if obj.nil?
    return obj.compact if obj.kind_of?(Array)
    return obj if is_primitive?(obj)

    obj.each do |m|
      if obj[m].nil?
        if obj.kind_of?(Array)
          obj.delete_at(m)
        else
          obj.delete(m)
        end
      elsif obj[m].kind_of?(Hash)
        purge_nils(obj[m])
      end
    end
    obj
  end
end
