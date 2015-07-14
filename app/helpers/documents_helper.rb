module DocumentsHelper


  def selected?(field)
    return "selected" if params[:sort] == field
  end

  def sort_results(sort_field)
    new_params = reset_params
    # add sorting field
    new_params[:sort] = sort_field
    return new_params
  end

  def query_display
    # TODO this will need to be filled out if there are fq queries happening
    # or if anything is using the straight up "q" fields
    
    # return "#{params[:qfield]} = #{params[:qtext]}"
    return "#{params[:qtext]}"
  end

end
