module ApplicationHelper


  #######################
  #    Index Display    #
  #######################

  def paginator_numbers(total_pages)
    current_page = params[:page] ? params[:page].to_i : 1
    total_pages = total_pages.to_i
    html = ""
    # weed out the first and last page, they'll be handled separately
    prior_three = (current_page-3..current_page-1).reject { |x| x <= 1 }
    next_three = (current_page+1..current_page+3).reject { |x| x >= total_pages }

    # add the first page if you're not on it and add dots if it is far from the other pages
    if current_page != 1
      html += "<li>"
      html += link_to "1", to_page("1") 
      html += "</li>"
      html += "<li class='disabled'><a href='#'>...</a></li>" if prior_three.min != 2 && current_page != 2
    end

    # prior three, current page, and next three
    html += _add_paginator_options(prior_three)
    html += "<li class='active'>"
    html += link_to current_page.to_s, to_page(current_page)
    html += "</li>"
    html += _add_paginator_options(next_three)

    # add the last page if you're not on it and add dots if it is far from the other pages
    if current_page != total_pages
      html += "<li class='disabled'><a href='#'>...</a></li>" if next_three.max != total_pages-1 && current_page != total_pages-1
      html += "<li>"
      html += link_to total_pages.to_s, to_page(total_pages)
      html += "</li>"
    end

    return html.html_safe
  end

  def _add_paginator_options(range)
    html = ""
    range.each do |page|
      html += "<li>"
      html += link_to page.to_s, to_page(page)
      html += "</li>"
    end
    return html
  end

  # paginator method
  def to_page(page)
    params = reset_params
    merged = params.merge({:page => page.to_s})
    return merged
  end

  def reset_params
    new_params = params.clone
    new_params.delete("action")
    new_params.delete("controller")
    new_params.delete("page")
    return new_params
  end


#######################
#     Item Display    #
#######################

  def format_list(items, route="doc")
    if !items.nil?
      res = "<ul>"
      items.each do |item|
        begin
          hash = JSON.parse(item)
          if route == "case"
            res += "<li>#{link_to hash['label'], case_path(hash['id'])}</li>"
          elsif route == "person"
            res += "<li>#{link_to hash['label'], person_path(hash['id'])}</li>"
          else
            res += "<li>#{link_to hash['label'], doc_path(hash['id'])}</li>"
          end
        rescue
          # is invalid JSON just display what is possible
          res += item
        end
      end
      res += "</ul>"
      return res.html_safe
    end
  end

  # pass in solr_res each time rather than use instance variable
  def metadata_mult(display, solr_res, search_field)
    res = ""
    if !solr_res.nil?
      res += "<p><strong>#{display}: </strong>"
      solr_res.each do |term|
        res += "<span class='subjectLink'>"
        res += link_to(term, search_path(:qfield => search_field, :qtext => term))
        res += "</span>"
      end
    res += "</p>"
    end
    return res.html_safe
  end

  # This will only link out to external URLs and documents!
  # So be careful if you are expecting something with case ids
  # Note:  This function is getting way out of hand - should be refactored
  def metadata_builder(display, data)
    if !data.nil? && data.class == Array
      res = display.nil? ? "" : "<p><strong>#{display}: </strong>"
      data.each do |item|
        begin
          hash = JSON.parse(item)
          date = hash['date'] ? "(#{hash['date']}) " : ""
          if hash['id'] =~ URI::regexp
            # if this has a real url then use
            res += "<p><a href=\"#{hash['id']}\">#{hash['label']}</a> #{date}</p>"
          else
            res += "<p>#{link_to hash['label'], doc_path(hash['id'])} #{date}</p>"
          end
        rescue
          # if it can't be parsed into JSON just display what you can
          res += item
        end
      end
      res += "</p>"
      return res.html_safe
    end
  end
end
