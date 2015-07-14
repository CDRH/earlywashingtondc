module CasesHelper


  def find_unique_strings(solr_array)
    unique = find_unique(solr_array)
    return unique.join(", ")
  end

  def find_unique(array)
    unique = []
    array.each do |item|
      unique << item if !unique.include?(item)
    end
    return unique
  end

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

  def people_list(items)
    # look for the unique elements and send those to format_list
    unique = find_unique(items)
    return format_list(unique, "person")
  end
  
end
