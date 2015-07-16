module DocumentsHelper

  def selected_facet?(field)
    return "selected" if params[:facet] == field
  end

  def selected_sort?(field)
    return "selected" if params[:sort] == field
  end

  def facet_results(facet_field)
    new_params = reset_params  # will delete page and sort
    # add facet field
    new_params[:facet] = facet_field
    return new_params
  end

  def sort_results(sort_field)
    new_params = reset_params  # should not delete current facet
    # add sorting field
    new_params[:sort] = sort_field
    return new_params
  end

  def query_display
    # TODO this will need to be filled out if there are fq queries happening
    # or if anything is using the straight up "q" fields
    
    # override if anything is specified
    return params[:display] ? params[:display] : params[:qtext]
  end

end
