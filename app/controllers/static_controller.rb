class StaticController < ApplicationController
  def index
    facet = @@solr.get_facets(nil, ["term", "subtype"])
    @term_facet = dropdownify_facets(facet['term'])
    @subtype_facet = dropdownify_facets(facet['subtype'])
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

  private

  def dropdownify_facets(facet_term)
    facet_term.keys.collect { |x| ["#{x} (#{facet_term[x]})", x] }
  end

end
