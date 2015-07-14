module ApplicationHelper

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
  def metadata_builder(display, data)
    if !data.nil? && data.class == Array
      res = "<p><strong>#{display}: </strong>"
      data.each do |item|
        begin
          hash = JSON.parse(item)
          date = hash['date'] ? "(#{hash['date']}) " : ""
          # check if this uses a url
          if hash['id'] =~ URI::regexp
            res += "<p>#{hash['label']} #{date}[<a href=#{hash['id']}>source</a>]</p>"
          else
            res += "<p>#{hash['label']} #{date}[#{link_to 'source', doc_path(hash['id'])}]</p>"
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
