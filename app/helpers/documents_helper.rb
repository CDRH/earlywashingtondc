module DocumentsHelper

  def facet_maker(facets)
    perm_facet = params[:facet] # don't want the link_tos to change the scope
    links = []
    links << link_to("All Results", search_path(facet_results), :class => selected_facet?(nil, perm_facet))
    facets.each do |key, value|
      labelkey = key == "caseid" ? "case" : key
      # have to make the label html_safe before putting it inside a link or else &lg;you'll regret it&gt;
      label = "#{labelkey.titleize} <span class='badge'>#{value}</span>".html_safe
      link = "#{link_to(label, search_path(facet_results(key)), :class => facet_classes(key, value, perm_facet))}"
      links << link
    end
    return links.join(" ").html_safe
  end

  def facet_classes(key, value, perm_facet)
    # if the key matches the selected parameter then attach "selected"
    # if the value == 0 then attach "no-facet-results"
    css = (value && value.to_i == 0) ? "no-facet-results " : ""
    selected = selected_facet?(perm_facet, key)
    css += selected if !selected.nil?
    return css
  end

  def selected_facet?(request_facet=nil, field=nil)
    if field.nil?
      return "selected" if request_facet.nil?
    else
      return "selected" if request_facet == field
    end
  end

  def facet_results(facet_field=nil)
    new_params = params.clone
    # add facet field if there should be one
    if facet_field.nil?
      new_params.delete("facet")
    else
      new_params[:facet] = facet_field
    end
    return new_params
  end

  def search_result_link(doc)
    label = (doc["dateDisplay"] && (doc["dateDisplay"] != "n.d.")) ? "#{doc["title"]} (#{doc["dateDisplay"]})" : doc["title"]
    if linkable_id?(doc["id"])
      return link_to label, doc_path(doc["id"])
    else
      return label
    end
  end

  def query_display
    # this will need to be filled out if there are fq queries happening
    # or if anything is using the straight up "q" fields
    qtext = params[:facet] ? "#{params[:qtext]} (#{params[:facet]})" : params[:qtext]
    # override if anything is specified
    return params[:display] ? params[:display] : qtext
  end

end
