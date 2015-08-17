module StoriesHelper

  def story_link(display, name)
    # simply tack on a controller and action to cut out
    # the complexity for the non-programmer making new links
    return link_to display, {
      :controller => "stories", 
      :action => "sub", 
      :name => name 
    }
  end

  def story_img(img_path, link_name)
    return link_to image_tag(img_path), {
      :controller => "stories",
      :action => "sub",
      :name => link_name
    }
  end

end
