class Hypertree < Relationships
  attr_accessor :json
  # send omit false if you want to see judges and clerks!
  def initialize(person, type, omit=true)
    super()
    @id = person
    @omit = omit
    @type = type
    raw_res = query_two_removed(person, "json", type)
    
    ruby_json = JSON.parse(raw_res)
    # this made more sense when several formats were being requested by this
    @json = format_results(ruby_json)
  end

  def format_results(raw_json)
    # expects results from self.class.query_two_removed in ruby json form
    info = {}
    # get the actual results
    bindings = raw_json["results"] && raw_json["results"]["bindings"] ? raw_json["results"]["bindings"] : nil
    if bindings.nil?
      return nil
    else
      # File.open("scripts/test_output.json", "w") { |file| file.write(bindings.to_json) }
      bindings.each_with_index do |res, index|
        if index == 0
          # add the original person
          info = _new_person(@id, res["name0"]["value"], nil, nil, true, true)
        end
        # now add the people in this particular result set (using b and c so that infovis doesn't overwrite data)
        per1 = "#{_value(res['per1'])}_b"
        per2 = "#{_value(res["per2"])}_c"
        per0to1 = _value(res["rel01"])
        per1to2 = _value(res["rel12"])
        rel01type = _value(res["rel01type"])
        rel12type = _value(res["rel12type"])
        # if this is a judge / clerk relationship, omit
        if !_omit_rel?(per0to1)
          per1index = info["children"].find_index { |child| child["id"] == per1 }
          per1obj = {}  # this needs to be available to the person two code below
          # if person 1 has not been added, add to the original person's children
          # otherwise, just grab person 1 out of the info hash
          if per1index.nil?
            info["children"] << _new_person(per1, _value(res["name1"]), per0to1, rel01type, true)
            per1obj = info["children"].last
          else
            per1obj = info["children"][per1index]
            # this person might have multiple relationships with same individual
            # for example, Ben petitionerAgainst Scott, Ben enslavedBy Scott
            per1obj["data"]["relation"] += " / #{per0to1}" if !per1obj["data"]["relation"].include?(per0to1)
            per1obj["data"]["relationType"] += " / #{rel01type}" if !per1obj["data"]["relationType"].include?(rel01type)
          end

          # person 2 could potentially be showing up more than once if there are multiple relationships
          if !_omit_rel?(per1to2)
            per2index = per1obj["children"].find_index { |child| child["id"] == per2 }
            # if person 2 has not been added, just shove it in, otherwise, add to existing
            if per2index.nil?
              per1obj["children"] << _new_person(per2, _value(res["name2"]), per1to2, rel12type)
            else
              per2obj = per1obj["children"][per2index]
              # account for multiple relationships with same individual
              puts "TESTING for index #{per2index} \n #{per2obj}"
              per2obj["data"]["relation"] += " / #{per1to2}" if !per2obj["data"]["relation"].include?(per1to2)
              per2obj["data"]["relationType"] += " / #{rel12type}" if !per2obj["data"]["relationType"].include?(rel12type)

            end
          end
        end
      end
    end
    File.open("scripts/test_output.json", "w") { |file| file.write(info.to_json) }
    return info
  end

  def _new_person(id, name, relation=nil, relationType=nil, children_exist=false, first=false)
    person = {}
    person["id"] = id
    person["name"] = name
    person["children"] = [] if children_exist
    person["data"] = {}
    person["data"]["relation"] = relation if !relation.nil?
    person["data"]["relationType"] = relationType if !relationType.nil?
    person["data"]["original_element"] = first
    return person
  end

  def _omit_rel?(rel)
    return rel == "judgeOf" || rel == "clerkOf" || rel == "judgedBy" || rel == "clerkedBy"
  end

  def _value(rdf_item)
    # TODO would I rather be returning nil here?
    if rdf_item && rdf_item["value"]
      return rdf_item["value"].sub(/.*#/, '')
    else
      return ""
    end
  end

end