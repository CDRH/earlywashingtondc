## Create a Story or Family Page

Let's add a new story.  The procedure should be very similar for kinship and about pages.

The stories are located in `app/views/stories`.  In `app/views` there are other directories like about and kinship.  If you wish to add a page to something like `app/views/static` you will need to ask a programmer / sysadmin, as those pieces were not set up in such a way to allow easy adding of new pages.

`app/views/stories` should look something like this:

```
    app
     |--stories
           |---- _example.html.erb
           |---- _some_existing_story.html.erb
           |---- index.html.erb
           |---- sub.html.erb
```

Go ahead and add another file to `app/views/stories` with a short name for the story as you would like it to appear in the URL.  __Make sure you start the name with an underscore__.  Rails needs to know that information in order to read the file correctly.  You will also need to use the extension `html.erb`.

Example:  You are making a page called "Juries in Early Washington DC."  Your URL might look like "earlywashingtondc.org/stories/dc_juries" or whatever you prefer to identify it on the end.  Therefore, you should create a new file at `app/views/stories/_dc_juries.html.erb`.  

At this point, you should also make a link to the story.  Open up `app/views/stories/index.html.erb` and you'll see the existing stories.  Copy this template and add it to index.html.erb.

```html
    <div class="media-body">
      <h3 class="media-heading"><%= story_link("Example Page", "example") %></h3>
      Use this page as a reference for how to link to things and use images!
    </div>
    <div class="media-right">
      <%= story_img("oscys_logo.png", "example") %>
    </div>
```

In the media-heading portion, instead of "Example Page" you'll want to fill in your own title, like "Juries in Early Washington DC."  You'll also then need to provide the url for your new page.  So it would look something like this:

```
    <h3 class="media-heading"><%= story_link("Juries in Early Washington DC", "dc_juries") %></h3>
```

Additionally, if there is an image, make sure it is in the `app/assets/images` directory and then fill in media-right with the image name and a link to your new page.

```
    <div class="media-right">
      <%= story_img("juries.jpg", "dc_juries") %>
    </div>
```

If you just added the image, you may need to restart the server.  If the image has been there for a while, skip this step.  From the root of the repository:

```
    touch tmp/restart.txt
```

You can add standard HTML to your new file if you like, but be careful if you are adding links or images -- you can use traditional HTML but Rails has helpers that make it easier to move things from server to server and it is HIGHLY recommended that you use them.  Rails helpers work by making it unnecessary to put in the entire url.  These would be equivalent in an HTML document in rails:

```
    <a href="earlywashingtondc.org/people/per.000001">Francis Scott Key</a>
    <%= link_to "Francis Scott Key", person_path("per.000001") %>


    <a href="earlywashingtondc.org">Home</a>
    <%= link_to "Home", home_path %>
```


There are some examples in `app/views/stories/_example.html.erb` but here are a few of the more common ones:

```
    # Link to a person
    <%= link_to "Francis Scott Key", person_path("per.000001") %>

    # Link to a case
    <%= link_to "Abraham Smith v. John Lyons", case_path("oscys.caseid.0081") %>

    # Display an image that lives in app/assets/images
    <%= image_tag("image.gif") %>
```