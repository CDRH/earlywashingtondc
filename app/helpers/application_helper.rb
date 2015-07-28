module ApplicationHelper


  #######################
  #    Index Display    #
  #######################

  def paginator
    return select_tag("page", 
                      options_for_select((1..@total_pages), params[:page]),
                      :onchange => "this.form.submit();")
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
