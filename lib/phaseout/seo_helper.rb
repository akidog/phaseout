module Phaseout
  module SEOHelper
    def page_title(content)
      controller.seo_context[:page_title] = content
      content_tag 'title', content
    end

    def meta_description(content)
      controller.seo_context[:meta_description] = content
      tag 'meta', name: 'description', content: content
    end

    def meta_keywords(content)
      tag 'meta', name: 'keywords', content: content
    end

    def meta_robots(robots='robots', content)
      controller.seo_context[:meta_robot] = content
      tag 'meta', name: robots, content: content
    end

    def link_canonical(url)
      controller.seo_context[:link_canonical] = url
      tag 'link', rel: 'canonical', href: url
    end

    def og_auto(value = true)
      controller.seo_context[:og_auto] = !!value && value != 'false'
      nil
    end

    def og_title(content)
      controller.seo_context[:defined_og_title] = true
      tag 'meta', property: 'og:title', content: content
    end

    def og_description(content)
      controller.seo_context[:defined_og_description] = true
      tag 'meta', property: 'og:description', content: content
    end

    def og_url(content)
      tag 'meta', property: 'og:url', content: content
    end

    def og_type(content)
      tag 'meta', property: 'og:type', content: content
    end

    def og_image(content)
      tag 'meta', property: 'og:image', content: content
    end

    def og_auto_default
      tags = ''
      if controller.seo_context[:og_auto]
        tags += og_title(controller.seo_context[:page_title])             if controller.seo_context[:page_title] && !controller.seo_context[:defined_og_title]
        tags += og_description(controller.seo_context[:meta_description]) if controller.seo_context[:meta_description] && !controller.seo_context[:defined_og_description]
      end
      tags
    end

    def twitter_auto(value = true)
      controller.seo_context[:twitter_auto] = !!value && value != 'false'
      nil
    end

    def twitter_card(content)
      tag 'meta', property: 'twitter:card', content: content
    end

    def twitter_site(content)
      tag 'meta', property: 'twitter:site', content: content
    end

    def twitter_creator(content)
      tag 'meta', property: 'twitter:creator', content: content
    end

    def twitter_title(content)
      tag 'meta', property: 'twitter:title', content: content
    end

    def twitter_description(content)
      tag 'meta', property: 'twitter:description', content: content
    end

    def twitter_image(content)
      tag 'meta', property: 'twitter:image', content: content
    end

    def twitter_auto_default
      tags = ''
      if controller.seo_context[:twitter_auto]
        tags += twitter_title(controller.seo_context[:page_title])             if controller.seo_context[:page_title] && !controller.seo_context[:defined_twitter_title]
        tags += twitter_description(controller.seo_context[:meta_description]) if controller.seo_context[:meta_description] && !controller.seo_context[:defined_twitter_description]
      end
      tags
    end


  end
end
