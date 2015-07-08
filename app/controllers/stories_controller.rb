class StoriesController < ApplicationController

  def index
    # This is a list of all the stories
    # add more links in app/views/stories/index.html.erb
  end

  def story
    # in the URL there will be an ID
    # either a number or a string
    # and that will determine which template to
    # show so make sure that you name the partial templates
    # in app/views/stories/ the same thing as the link

    # example:
    #  in index.html.erb
    #    <%= link_to "Early DC", story_path('early_dc') %>
    #  name file in app/views/stories
    #    _early_dc.html.erb

    @story_name = params[:name]  # this is unnecessary, only for clarity
  end

end