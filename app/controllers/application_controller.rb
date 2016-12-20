class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # set up SOLR configuration for the website
  solr_url = CONFIG['solr_url']
  if solr_url.nil?
    raise "No Solr URL found, cannot continue"
  else
    $solr = RSolrCdrh::Query.new(solr_url, [])
    # set default to look for just documents
    $solr.set_default_query_params({
      # :fq => ['category:(NOT "Case" NOT "People")']
      :fq => ['recordType_s:document']
    })
    $solr.set_default_facet_fields({
      :fq => ['recordType_s:document'],
      :facet => "true",
      :rows => 0,
      "facet.mincount" => "1",
      "facet.limit" => "-1"
    })
  end

  private

  def _index_finder(options={})
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    @docs = $solr.query(options)
    @total_found = @docs[:num_found]
    # default response is 50 pages, divide and round up for all
    @total_pages = @docs[:pages]
  end

  def format_date(date)
    year_month = date.split("-")
    # if there is a better way of doing this I would love to hear it
    # but ruby's DateTime and Date didn't seem to offer what we need
    months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    begin
      selected_month = year_month[1].to_i-1
      return "#{months[selected_month]} #{year_month[0]}"
    rescue
      # when in doubt, just return whatever was in solr
      return date
    end
  end
  helper_method :format_date

  # for the traditional Smith => 10 type results
  def dropdownify_facets(facet_term, date=false)
    facet_term.keys.collect { |x| 
      display = date ? format_date(x) : x
      ["#{display} (#{facet_term[x]})", x] 
    }
  end

  # for the less traditional {label: Smith, id: 0001} => 10 type results
  def dropdownify_data_facets(facet_term, number=true)
    facets = facet_term.collect do |term|
      begin
        hash = JSON.parse(term[0])
        display = number ? "#{hash['label']} (#{term[1]})" : hash['label']
        if linkable_id?(hash["id"])
          [display, hash["id"]]
        else
          nil
        end
      rescue
        puts "Not parsable!!! #{term}"
        nil
      end
    end
    return facets.compact   #  remove all the nils
  end

  def linkable_id?(id)
    return !(id == "per.000000") && !(id == "")  
  end
  helper_method :linkable_id?

end
