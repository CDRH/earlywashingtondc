module CasesHelper

  def find_unique_strings(solr_array)
    unique = find_unique(solr_array)
    return unique.join("<br/>").html_safe
  end

  def find_unique(array)
    unique = []
    array.each do |item|
      unique << item if !unique.include?(item)
    end
    return unique
  end

  def people_list(items)
    # look for the unique elements and send those to format_list
    unique = find_unique(items)
    return format_list(unique, "person", "label")
  end

end
