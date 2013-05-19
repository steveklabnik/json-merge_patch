require 'rails'

module JSON
  class MergePatch
    # This class registers our gem with Rails.
    class Railtie < ::Rails::Railtie

      # When the application loads, this will cause Rails to know
      # how to serve up the proper type.
      initializer 'json-merge_patch' do
         Mime::Type.register 'application/json-merge-patch', :json_merge_patch
      end
    end
  end
end

