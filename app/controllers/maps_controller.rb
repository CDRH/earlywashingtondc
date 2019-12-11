class MapsController < ApplicationController
  def index
    @page_class = "maps"
  end

  def directory_dc
    @page_class = "maps"
    @year = "1822"
  end

  def directory_dc_1834
    @page_class = "maps"
    @year = "1834"
    render "maps/directory_dc"
  end

end
