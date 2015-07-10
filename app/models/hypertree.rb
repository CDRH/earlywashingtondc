class Hypertree < Relationships
  attr_accessor :raw_res, :json, :raw_res

  # send omit false if you want to see judges and clerks!
  def initialize(person, type, omit=true)
    @id = person
    @omit = omit
    @type = type
    # choose the right query to run
    # easier just to make a whole new one if involving type
    @raw_res = nil
    if type == "legal" || type == "familyOf" || type == "acquaintanceOf"
      @raw_res = self.class.query_two_removed_type(person, type)
    else
      # assume if not one of those types then everything desired
      @raw_res = self.class.query_two_removed_all(person)
    end
    @raw_xml = @raw_res
    # format the results
    res_ruby_json = JSON.parse(@raw_res.to_json)
    @json = format_results(res_ruby_json)
  end

  def format_results(raw_json)
    # expects results from self.class.query_two_removed in ruby json form
    info = {}
    # get the actual results
    bindings = raw_json["results"] && raw_json["results"]["bindings"] ? raw_json["results"]["bindings"] : nil
    if bindings.nil?
      return nil
    else
      bindings.each_with_index do |res, index|
        if index == 0
          # add the original person
          info = _new_person(@id, res["name0"]["value"], nil, true) 
        end
        # now add the people in this particular result set
        per1 = _value(res["per1"])
        per2 = _value(res["per2"])
        per0to1 = _value(res["rel01"])
        per1to2 = _value(res["rel12"])
        # if this is a judge / clerk relationship, omit
        if !_omit_rel?(per0to1)
          per1index = info["children"].find_index { |child| child["id"] == per1 }
          per1obj = {}
          # if person 1 has not been added, add to the original person's children
          # otherwise, just grab person 1 out of the info hash
          if per1index.nil?
            info["children"] << _new_person(per1, _value(res["name1"]), per0to1, true)
            per1obj = info["children"].last
          else
            per1obj = info["children"][per1index]
          end

          # now add person 2
          if !_omit_rel?(per1to2)
            per1obj["children"] << _new_person(per2, _value(res["name2"]), per1to2)
          end
        end
      end
    end
    return info
  end

  def _new_person(id, name, relation=nil, children_exist=false)
    person = {}
    person["id"] = id
    person["name"] = name
    person["children"] = [] if children_exist
    person["data"] = { "relation" => relation } if !relation.nil?
    return person
  end

  def _omit_rel?(rel)
    return rel == "judgeOf" || rel == "clerkOf" || rel == "judgedBy" || rel == "clerkedBy"
  end

  def _value(rdf_item)
    # possibly should handle an error but for now I'm going to let it raise
    return rdf_item["value"].sub(/.*#/, '')
  end

end