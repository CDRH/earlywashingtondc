module DocumentsHelper

  def facet_maker(facets)
    links = []
    links << link_to("All Results", search_path(facet_results), :class => selected_facet?())
    facets.each do |key, value|
      labelkey = key == "caseid" ? "case" : key
      label = "#{labelkey.titleize} (#{value})"
      link = "#{link_to(label, search_path(facet_results(key)), :class => selected_facet?(key))}"
      links << link
    end
    return links.join(" ").html_safe
  end

  def selected_facet?(field=nil)
    if field.nil?
      return "selected" if params[:facet].nil?
    else
      return "selected" if params[:facet] == field
    end
  end

  def selected_sort?(field)
    return "selected" if params[:sort] == field
  end

  def facet_results(facet_field=nil)
    new_params = reset_params  # will delete page and sort
    # add facet field if there should be one
    if facet_field.nil?
      new_params.delete("facet")
    else
      new_params[:facet] = facet_field
    end
    return new_params
  end

  def search_result_link(doc)
    label = doc["dateDisplay"] ? "#{doc["title"]} (#{doc["dateDisplay"]})" : doc["title"]
    return link_to label, doc_path(doc["id"])
  end

  def sort_results(sort_field)
    # add sorting field
    new_params[:sort] = sort_field
    return new_params
  end

  def query_display
    # TODO this will need to be filled out if there are fq queries happening
    # or if anything is using the straight up "q" fields
    qtext = params[:facet] ? "#{params[:qtext]} (#{params[:facet]})" : params[:qtext]
    # override if anything is specified
    return params[:display] ? params[:display] : qtext
  end

end
