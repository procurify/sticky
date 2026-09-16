# Concatenate Slate's JS the way sprockets //= require used to.
# Underscore-prefixed sources are Middleman partials and are not published.
class SlateJsBundle < Middleman::Extension
  JS_PARTS = %w[
    javascripts/lib/_jquery.js
    javascripts/lib/_imagesloaded.min.js
    javascripts/lib/_energize.js
    javascripts/app/_copy.js
    javascripts/app/_toc.js
    javascripts/app/_lang.js
    javascripts/all_nosearch.js
  ].freeze

  class BundleResource < ::Middleman::Sitemap::Resource
    def initialize(store, path, source)
      @bundle_source = source
      super(store, path)
    end

    def template?
      true
    end

    def render(*)
      @bundle_source
    end

    def binary?
      false
    end
  end

  def manipulate_resource_list(resources)
    source = JS_PARTS.map { |rel| File.read(File.join(app.source_dir, rel)) }.join("\n")
    resources = resources.reject do |resource|
      %w[javascripts/all.js javascripts/all_nosearch.js].include?(resource.destination_path)
    end
    resources << BundleResource.new(app.sitemap, 'javascripts/all_nosearch.js', source)
    resources << BundleResource.new(app.sitemap, 'javascripts/all.js', source)
    resources
  end
end

Middleman::Extensions.register(:slate_js_bundle, SlateJsBundle)
