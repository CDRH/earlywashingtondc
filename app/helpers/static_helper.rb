module StaticHelper

  def person_search(display, solr_name)
    return link_to(display, search_path(:qfield => "person", :qtext => solr_name))
  end

end
