module PeopleHelper

  def make_alphabet_menu(alphabet_hash)
    # expects a hash like {"a" => 22, "b" => 131} etc
    res = ""
    
    link_array = ["<li>" + link_to("All", peopleAll_path()) + "</li>"]
    alphabet_hash.each do |key, value|
      # TODO figure out what to do with blank strings / missing facet because then the solr query is different
      label = "#{key} <span>(#{value})</span>".html_safe
      link_array << "<li>" + link_to(label, peopleAll_path({:letter => key})) + "</li>" if !key.empty? 
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