module PeopleHelper

  def make_alphabet_menu(alphabet_hash)
    # expects a hash like {"a" => 22, "b" => 131} etc
    res = ""
    
    link_array = ["<li>" + link_to("All", peopleAll_path()) + "</li>"]
    alphabet_hash.each do |key, value|
      next if key.empty?
      label = "#{key.capitalize} ".html_safe
      if key == ","
        label << '<span class="sr-only-clip">comma </span>'.html_safe
      end
      label << <<~HTML.html_safe
        <span class="count">#{value}<span class="sr-only-clip">
      HTML
      if value != 1
        label << " people".html_safe
      else
        label << " person".html_safe
      end
      link_array << "<li>" + link_to(label, peopleAll_path({:letter => key})) + "</li>"
    end
    res += "<ul class='letter_pagination'>" + link_array.join(" ") + "</ul>"
    return res.html_safe
  end

  def prettify(relationship)
    relArray = relationship.split(/(?=[A-Z])/)
    rejoined = relArray.join(" ")
    return rejoined.downcase
  end

  def rdf_res?(item)
    return item && !item.empty?
  end

  def rdfval(rdf_item)
    if rdf_item && rdf_item["value"]
      return rdf_item["value"].sub(/.*#/, '')
    else
      return ""
    end
  end

end