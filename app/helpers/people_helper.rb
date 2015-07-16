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

end