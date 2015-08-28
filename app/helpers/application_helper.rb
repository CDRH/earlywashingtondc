module ApplicationHelper

  #######################
  #      All Pages      #
  #######################

  def linkable_id?(id)
    return !(id == "per.000000") && !(id == "")  end

  #######################
  #    Index Display    #
  #######################

  def paginator_numbers(total_pages)
    current_page = params[:page] ? params[:page].to_i : 1
    total_pages = total_pages.to_i
    html = ""
    # weed out the first and last page, they'll be handled separately
    prior_three = (current_page-3..current_page-1).reject { |x| x <= 1 }
    next_three = (current_page+1..current_page+3).reject { |x| x >= total_pages }

    # add the first page if you're not on it and add dots if it is far from the other pages
    if current_page != 1
      html += "<li>"
      html += link_to "1", to_page("1") 
      html += "</li>"
      html += "<li class='disabled'><span>...</span></li>" if prior_three.min != 2 && current_page != 2
    end

    # prior three, current page, and next three
    html += _add_paginator_options(prior_three)
    html += "<li class='active'>"
    html += link_to current_page.to_s, to_page(current_page)
    html += "</li>"
    html += _add_paginator_options(next_three)

    # add the last page if you're not on it and add dots if it is far from the other pages
    if current_page != total_pages
      html += "<li class='disabled'><span>...</span></li>" if next_three.max != total_pages-1 && current_page != total_pages-1
      html += "<li>"
      html += link_to total_pages.to_s, to_page(total_pages)
      html += "</li>"
    end

    return html.html_safe
  end

  def _add_paginator_options(range)
    html = ""
    range.each do |page|
      html += "<li>"
      html += link_to page.to_s, to_page(page)
      html += "</li>"
    end
    return html
  end

  def selected_sort?(field, sort_param)
    return "selected" if sort_param == field
  end

  def sort_results(sort_field)
    params[:sort] = sort_field
    return params
  end

  # paginator method
  def to_page(page)
    merged = params.merge({:page => page.to_s})
    return merged
  end

#######################
#     Item Display    #
#######################

  def format_list(items, route="doc", sort_on_field=nil)
    if !items.nil?
      items = jsonify(items)
      items = sort_by_field(items, sort_on_field) if sort_on_field
      res = "<ul>"
      items.each do |item|
	      
        if item.class != String
          if linkable_id?(item['id'])
            if route == "case"
              res += "<li>#{link_to item['label'], case_path(item['id'])}</li>"
            elsif route == "person"
              res += "<li>#{link_to item['label'], person_path(item['id'])}</li>"
            else
              res += "<li>#{link_to item['label'], doc_path(item['id'])}</li>"
            end
          else
		  	
            res += "<li><span class='a'>#{item['label']}</span></li>"

          end
        else
          # if it's not a hash then send it through as it was
          res += "<li class='a'>#{item}</li>"
        end
      end
      res += "</ul>"
      return res.html_safe
    end
  end

  def jsonify(items)
    # go ahead and map everything to a JSON object up front
    items.map! do |item|
      begin
        JSON.parse(item)
      rescue
        # if it can't be parsed into JSON just display what you can
        puts "this item isn't making it through #{item}"
        item
      end
    end
  end

  def metadata_list(display, solr_res, search_field, date=false)
    res = ""
    if !solr_res.nil?
      res += "<ul>"
      solr_res.each do |term|
        display = date ? format_date(term) : term
        res += "<li>"
        res += link_to(display, search_path(:qfield => search_field, :qtext => term))
        res += "</li>"
      end
    res += "</ul>"
    end
    return res.html_safe
  end


  # This will only link out to external URLs and documents!
  # So be careful if you are expecting something with case ids
  # Note:  This function is getting way out of hand - should be refactored
  def metadata_builder(display, data, sort_by_date=false)
    if !data.nil? && data.class == Array
      res = display.nil? ? "" : "<p><strong>#{display}: </strong>"
      data = jsonify(data)
      data = sort_by_field(data, "date") if sort_by_date

      data.each do |item|
        begin
          date = item['dateDisplay'] ? "(#{item['dateDisplay']}) " : ""
          if item['id'] =~ URI::regexp
            # if this has a real url then use
            res += "<p><a href=\"#{item['id']}\">#{item['label']}</a> #{date}</p>"
          else
            res += "<p>#{link_to item['label'], doc_path(item['id'])} #{date}</p>"
          end
        rescue
          res += item
        end
      end
      res += "</p>"
      return res.html_safe
    end
  end
  
  # Oh god I am butchering Jessica's code so much I am so sorry -KMD

  # This will only link out to external URLs and documents!
  # So be careful if you are expecting something with case ids
  # Note:  This function is getting way out of hand - should be refactored
  def metadata_people_list(data)
    if !data.nil? && data.class == Array
      res = "<ul>"
      data.each do |item|
        begin
          hash = JSON.parse(item)
          date = hash['dateDisplay'] ? "(#{hash['dateDisplay']}) " : ""
          if hash['id'] =~ URI::regexp
            # if this has a real url then use
            res += "<li>" + hash['label'] + " <span class='source_note'>[" + "<a href=\"#{hash['id']}\">source</a>" + "]</span></li>"
          else
            res += "<li>" + hash['label'] + " <span class='source_date'>#{date}</span> " +  "<span class='source_note'>[" + "#{link_to 'source', doc_path(hash['id'])}" + "]</span></li>"
          end
        rescue
          # if it can't be parsed into JSON just display what you can
          res += item.to_s
        end
      end
      res += "</ul>"
      return res.html_safe
    end
  end
  
  def sort_by_field(array_of_hashes, field)
    return array_of_hashes.sort_by do |item|
      item[field] || "zzzz"  # sort nil to the back of the list (nums first then letters)
    end
  end

  #######################
  #   Search Dropdown   #
  #######################

  def get_relationship_types
    return [
        ["Acquaintance Of", "acquaintanceOf"],
        ["Administrator For", "administratorFor"],
        ["Agent For", "agentFor"],
        ["Attorney Against", "attorneyAgainst"],
        ["Attorney For", "attorneyFor"],
        ["Attorney With", "attorneyWith"],
        ["Attorneyed Against", "attorneyedAgainst"],
        ["Business Relationship With", "businessRelationshipWith"],
        ["Child Of", "childOf"],
        ["Clerk Of", "clerkOf"],
        ["Client Of", "clientOf"],
        # ["Correspondent Of", "correspondentOf"],  # no examples
        ["Defendant Against", "defendantAgainst"],
        ["Deponent Against", "deponentAgainst"],
        ["Deponent For", "deponentFor"],
        # ["Deponent Of", "deponentOf"],  # no examples
        ["Deposed", "deposed"],
        ["Deposed By", "deposedBy"],
        ["Employee Of", "employeeOf"],
        ["Employer Of", "employerOf"],
        ["Enslaved By", "enslavedBy"],
        ["Exchanged Slaves With", "exchangedSlavesWith"],
        ["Executor For", "executorFor"],
        ["Friend Of", "friendOf"],
        ["Guardian Of", "guardianOf"],
        ["Had Contract With", "hadContractWith"],
        ["Hired", "hired"],
        ["Hired Out To", "hiredOutTo"],
        ["Indentured To", "indenturedTo"],
        ["Indenturer Of", "indenturerOf"],
        ["Judge Of", "judgeOf"],
        ["Judged By", "judgedBy"],
        ["Juror For", "jurorFor"],
        # ["Jury Pool For", "juryPoolFor"],  # no examples
        ["Lives With", "livesWith"],
        ["Marshal Of", "marshalOf"],
        ["Neighbor Of", "neighborOf"],
        ["Next Friend Of", "nextFriendOf"],
        ["Notary For", "notaryFor"],
        ["Opposing Attorneys", "opposingAttorneys"],
        ["Owner Of", "ownerOf"],
        ["Parent Of", "parentOf"],
        ["Petitioner Against", "petitionerAgainst"],
        # ["Provenance", "provenance"],  # no examples
        ["Purchased Slave From", "purchasedSlaveFrom"],
        ["Recognizance With", "recognizanceWith"],
        ["Secretary For", "secretaryFor"],
        ["Sibling Of", "siblingOf"],
        ["Sold Slave To", "soldSlaveTo"],
        ["Spouse Of", "spouseOf"],
        ["Sued", "sued"],
        ["Sued By", "suedBy"],
        ["Witness Against", "witnessAgainst"],
        ["Witness For", "witnessFor"],
        ["Witness Of", "witnessOf"],
        # ["Works With", "worksWith"],  # currently no examples of this
      ]
  end


end
