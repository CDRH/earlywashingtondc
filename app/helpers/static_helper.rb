module StaticHelper

  def people_search(display, solr_name)
    return link_to(display, search_path(:qfield => "people", :qtext => solr_name))
  end

end
