module StoriesHelper

  def story_link(display, name)
    # simply tack on a controller and action to cut out
    # the complexity for the non-programmer making new links
    return link_to display, {
      :controller => "stories", 
      :action => "story", 
      :name => name 
    }
  end

  def story_img(img_path, link_name)
    # temporary for demo remove the if once working
    if img_path == "img_path"
      return nil
    else
      return link_to image_tag(img_path), {
        :controller => "stories",
        :action => "story",
        :name => name
      }
    end
  end

end
