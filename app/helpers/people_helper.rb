module PeopleHelper

  def make_alphabet_menu(alphabet_hash)
    # expects a hash like {"a" => 22, "b" => 131} etc
    res = ""
    link_array = [link_to("All People", peopleAll_path())]
    alphabet_hash.each do |key, value|
      # TODO figure out what to do with blank strings / missing facet because then the solr query is different
      link_array << link_to("#{key} (#{value})", peopleAll_path({:letter => key})) if !key.empty?
    end
    res += link_array.join(" | ")
    return res.html_safe
  end

end