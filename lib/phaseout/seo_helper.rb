module Phaseout
  module SEOHelper
    def page_title(content)
      content_tag 'title', content
    end

    def meta_description(content)
      tag 'meta', name: 'description', content: content
    end

    def meta_keywords(content)
      tag 'meta', name: 'keywords', content: content
    end

    def og_url(content)
      tag 'meta', property: 'og:url', content: content
    end

    def og_title(content)
      tag 'meta', property: 'og:title', content: content
    end

    def og_image(content)
      tag 'meta', property: 'og:image', content: content
    end

    def og_description(content)
      tag 'meta', property: 'og:description', content: content
    end
  end
end
