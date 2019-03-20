class Hypertree < Relationships
  attr_accessor :json
  # send omit false if you want to see judges and clerks!
  def initialize(person, type, omit=true)
    super()
    @id = person
    @omit = omit
    @type = type
    @num_allowed = 40
    # we are taking the "types" out of the hypertree
    # but we could add it back in the future
    # raw_res = query_two_removed(person, "json", type)
    raw_res = query_two_removed(person, "json")
    
    ruby_json = JSON.parse(raw_res)
    # this made more sense when several formats were being requested by this
    @json = format_results(ruby_json)
  end

  def format_results(raw_json)
    # expects results from self.class.query_two_removed in ruby json form
    info = {}
    notes = ""
    # get the actual results
    bindings = raw_json["results"] && raw_json["results"]["bindings"] ? raw_json["results"]["bindings"] : nil
    if bindings.nil?
      return nil
    else
      # File.open("scripts/test_output.json", "w") { |file| file.write(bindings.to_json) }
      bindings.each_with_index do |res, index|
        if index == 0
          # add the original person
          info = _new_person(@id, res["name0"]["value"], 0, nil, nil, true, true)
        end
        # now add the people in this particular result set (using b and c so that infovis doesn't overwrite data)
        per1 = "#{_value(res['per1'])}_b"
        per2 = "#{_value(res["per2"])}_c"
        per0to1 = _value(res["rel01"])
        per1to2 = _value(res["rel12"])
        rel01type = _value(res["rel01type"])
        rel12type = _value(res["rel12type"])
        # if this is a judge / clerk relationship, omit
        # TODO make a generic function that can do per01 and per12 and potentially more
        if !_omit_rel?(per0to1)
          per1index = info["children"].find_index { |child| child["id"] == per1 }
          per1obj = {}  # this needs to be available to the person two code below
          # if person 1 has not been added, add to the original person's children
          # otherwise, just grab person 1 out of the info hash
          if per1index.nil?
            info["children"] << _new_person(per1, _value(res["name1"]), 1, per0to1, rel01type, true)
            per1obj = info["children"].last
          else
            per1obj = info["children"][per1index]
            # this person might have multiple relationships with same individual
            # for example, Ben petitionerAgainst Scott, Ben enslavedBy Scott
            per1obj["data"]["relation"] += " / #{per0to1}" if !per1obj["data"]["relation"].include?(per0to1)
            if !per1obj["data"]["relationType"].include?(rel01type)
              addType = per1obj["data"]["relationType"].empty? ? rel01type : " / #{rel01type}"
              per1obj["data"]["relationType"] += addType
            end
          end

          # person 2 could potentially be showing up more than once if there are multiple relationships
          if !_omit_rel?(per1to2)
            per2index = per1obj["children"].find_index { |child| child["id"] == per2 }
            # if person 2 has not been added, just shove it in, otherwise, add to existing
            if per2index.nil?
              per1obj["children"] << _new_person(per2, _value(res["name2"]), 2, per1to2, rel12type)
            else
              per2obj = per1obj["children"][per2index]
              # account for multiple relationships with same individual
              per2obj["data"]["relation"] += " / #{per1to2}" if !per2obj["data"]["relation"].include?(per1to2)
              if !per2obj["data"]["relationType"].include?(rel12type)
                addType = per2obj["data"]["relationType"].empty? ? rel12type : " / #{rel12type}"
                per2obj["data"]["relationType"] += addType
              end
            end
          end
        end
      end
      # if per0's initial relationships exceed allowed number, disable outer ring
      if info["children"].length > @num_allowed
        notes = "Due to number of relationships, only displaying first level of familiarity"
        # for each of the first ring's children, empty out the dataset
        # so that they will not be displayed
        info["children"].each do |c|
          c["name"] = _omitted_label(c["name"], c["children"])
          c["children"] = []
        end
      end
      # TODO this also removes relationships to other individuals already being
      # displayed for other people on the visualization
      omitted = []
      info["children"].each do |c|
        if c["children"].length > @num_allowed
          omitted << c["name"]
          c["name"] = _omitted_label(c["name"], c["children"])
          c["children"] = []
        end
      end
      if omitted.length > 0
        notes = <<-TEXT
          Due to a large number of relationships,
          these relationship networks have been omitted:
        TEXT
        notes += omitted.join("; ")
      end
    end
    # File.open("scripts/test_output.json", "w") { |file| file.write(info.to_json) }
    { info: info, notes: notes }
  end

  def _new_person(id, name, level, relation=nil, relationType=nil, children_exist=false, first=false)
    person = {}
    person["id"] = id
    person["name"] = name
    person["children"] = [] if children_exist
    person["data"] = {}
    person["data"]["level"] = level
    person["data"]["relation"] = relation if !relation.nil?
    person["data"]["relationType"] = relationType if !relationType.nil?
    person["data"]["original_element"] = first
    return person
  end

  def _omit_rel?(rel)
    return rel == "judgeOf" || rel == "clerkOf" || rel == "judgedBy" || rel == "clerkedBy"
  end

  def _omitted_label(persname, children)
    # add a warning to the person's name
    num = children.length
    label = "#{persname}<br/>(#{num} people omitted)"
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
