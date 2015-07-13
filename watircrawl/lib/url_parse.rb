require "addressable/uri"

module Crawl
  module UrlParse

    # validate if a url is "valid" and classify it as to
    #  from :ref_same_page
    #       :ref_external_page
    #       :ref_static_content
    #       :not_valid_url
    # return [:same_page, url_to_check_parsed.normalize]
    def is_valid_url(url, current_page_canonical)

      url_to_check_parsed = Addressable::URI.parse(url)

      # first see if the url is really static content
      if url_to_check_parsed =~ /(GIF|JPG|JPEG|MP4|AVI|MOV)$/i
        return [:ref_static_content, url_to_check_parsed.normalize]
      end

      if url =~ /^#{URI::regexp(%w(http https))}$/
        ## valid url, check if same site as current page

        if current_page_canonical
          url_current_page_parsed = Addressable::URI.parse(current_page_canonical)

          if url_to_check_parsed.host
            if url_to_check_parsed.host == url_current_page_parsed.host
              return [:ref_same_page, url_to_check_parsed.normalize]
            else
              return [:ref_external_page, url_to_check_parsed.normalize]
            end
          end
        end

        ## if we did not get the current page, we assume its an ref_external_page
        return [:ref_external_page, url_to_check_parsed.normalize]
      end

      # it is something to ignore
      return [:not_valid_url, url_to_check_parsed.normalize]
    end

  end
end