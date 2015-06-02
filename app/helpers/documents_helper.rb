module DocumentsHelper

  def selected?(field)
    return "selected" if params[:sort] == field
  end

  def sort_results(sort_field)
    new_params = params.clone
    # remove action and controller
    new_params.delete("action")
    new_params.delete("controller")
    # add sorting field
    new_params[:sort] = sort_field
    puts "params #{params}"
    return new_params
  end

  def query_display
    # TODO this will need to be filled out if there are fq queries happening
    # or if anything is using the straight up "q" fields
    return "#{params[:qfield]} = #{params[:qtext]}"
  end

end
