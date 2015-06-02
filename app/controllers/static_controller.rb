class StaticController < ApplicationController
  def index
    facet = @@solr.get_facets(nil, ["term", "subtype"])
    @term_facet = facet["term"].keys.collect { |x| ["#{x} (#{facet["term"][x]})", x] }
    @subtype_facet = facet["subtype"].keys.collect { |x| ["#{x} (#{facet["subtype"][x]})", x] }
    # TODO how to query attorney facets?  Query both, combine, remove duplicates?
  end

  def about
  end

  def families
  end

  def family
    # presumably at some point this will be pulled from models?
  end

  def interest
  end

end
