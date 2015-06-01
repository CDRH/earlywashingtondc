class DocumentsController < ApplicationController
  def index
    @all_docs = @@solr.query
  end
end
