require 'csv'
require 'sparql'
require 'linkeddata'
require 'nokogiri'

# take the current relationships rdf file and turn it into a csv
# this is likely a one time script, but in case it is required again it is here

# this has only been tested with .rdf, but I predict .ttl, .n3, etc, would work also
rdf_path = File.join(File.dirname(__FILE__), '../public/relationships.rdf')
csv_path = File.join(File.dirname(__FILE__), '../public/relationships.csv')


def find_old_network
  relationships = {}
  # read in as XML and for each triple, create a new entry in a hash
  # was trying to read it in as RDF but it does not appear to be working for some reason
  # { "per.000001" => { "per.000005" => { "parentOf" => "oscys.case.0001.001" }}}
  network_path = File.join(File.dirname(__FILE__), 'network.xml')
  network_file = File.open(network_path)
  xml = Nokogiri::XML(network_file)
  network_file.close
  descriptions = xml.xpath('//rdf:Description')
  descriptions.each do |description|
    subj = get_attr(description.xpath('rdf:subject'), 'resource')
    pred = get_attr(description.xpath('rdf:predicate'), 'resource')
    obj = get_attr(description.xpath('rdf:object'), 'resource')
    prov = get_attr(description.xpath('dccourts.owl:provenance'), 'nodeID')

    # oh my gracious, just check if there is a key and shove hashes in willy nilly
    if relationships.has_key?(subj)
      if !relationships[subj][obj].nil?
        relationships[subj][obj] = { pred => prov }
      else
        relationships[subj][obj] = {pred => prov}
      end
    else
      relationships[subj] = { obj => { pred => prov } }
    end
  end
  return relationships
end

def get_attr(element, attr_name)
  if !element[0].nil?
    attribute = element[0].attribute(attr_name).to_s
    return remove_ns(attribute)
  else
    raise Exception("NO XPATH FOUND!!! #{element}")
  end
end

def get_case_id(subject, pred, object)
  begin
    return @relationships[subject][object][pred]
  rescue
    return nil
  end
end

def remove_ns(item)
  # chop off th namespace portion before the #
  # this will return literals without changing them, unless if they happen
  # to have a # character in them, which would be bad
  return item.sub(/.*#/, '')
end

@relationships = find_old_network

CSV.open(csv_path, 'wb') do |csv|
  RDF::Reader.open(rdf_path) do |rdf|
    rdf.each_statement do |triple|
      subject = remove_ns(triple.subject.to_s)
      pred = remove_ns(triple.predicate.to_s)
      object = remove_ns(triple.object.to_s)
      case_id = get_case_id(subject, pred, object)
      csv << [subject, pred, object, case_id]
    end
  end
end