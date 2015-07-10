class PeopleController < ApplicationController
  def index
    options = {:fq => "recordType_s:person"}
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    @people = $solr.query(options)
    @total_people = @people[:num_found]
  end

  def show
    id = params[:id]
    @person = $solr.query({:q => "id:#{id}", :fq => "recordType_s:person"})[:docs][0]

    @docs = $solr.query({:qfield => "peopleID_ss", :qtext => id})

    puts "PREFIXES #{@@prefixes}"
    rdfquery = SPARQL.parse("#{@@prefixes} SELECT ?rel1 ?per1 ?name1 WHERE 
                            { osrdf:#{id} ?rel1 ?per1 . 
                              ?per1 oscys:fullName ?name1
                            }")
    rdf = @@rdf.query(rdfquery)
    @rdfresults = JSON.parse(rdf.to_json)

  end

  def network
    @id = params[:id]
    @type = params[:type]
    tree = Hypertree.new(@id, @type)
    @res = tree.json
    respond_to do |format|
      # optional to avoid all the header / footer
      format.html { render layout: false }
      format.json { render :json => tree.json.to_json }
      format.xml { render :xml => tree.raw_res.to_xml }
    end
  end

end