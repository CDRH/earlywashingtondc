class NetworkVisualization < Relationships

  def initialize(person, type, omit=true)
    super()
    @id = person
    @omit = omit
    @type = type

    raw_res = query_two_removed(person, "json")
    @rdf_json = JSON.parse(raw_res)
  end

  def format_results
    nodes = []
    edges = []

    bindings = @rdf_json.present? ? @rdf_json.dig("results", "bindings") : nil
    if bindings.present?
      bindings.each_with_index do |res, index|
        per1 = val(res["per1"])
        # add an identifier characteristic in order to keep
        # the 2-removed wave of people distinct even though
        # they may have already appeared as a 1-removed
        per2 = val(res["per2"])
        name1 = val(res["name1"])
        name2 = val(res["name2"])
        rel01 = val(res["rel01"])
        rel12 = val(res["rel12"])
        rel01type = val(res["rel01type"])
        rel12type = val(res["rel12type"])

        if index == 0
          # this is the MAIN person
          nodes << { id: @id, label: val(res["name0"]), color: "black" }
        end

        # omit judges and clerks because they overwhelm the relationships
        if !omit_rel?(rel01)
          # add a node for per1 if there isn't already one
          if !nodes.any? {|p| p[:id] == per1}
            nodes << { id: per1, label: name1, color: "blue" }
          end
          # create a connection for per0 to per1 if does not already exist
          if !edges.include?({ from: @id, to: per1 })
            edges << { from: @id, to: per1 }
          end

          if !omit_rel?(rel12)
            # because oscys doesn't want to draw lines between
            # TODO making up a per2 for now
            per2 = "#{per2}_#{index}"
            if !nodes.any? {|p| p[:id] == per2 }
              nodes << { id: per2, label: name2, color: "green" }
            end

            if !edges.include?({ from: per1, to: per2 })
              edges << { from: per1, to: per2, color: { color: "magenta"} }
            end
          end
        end
      end
    else
      # TODO what do we want to do if there wasn't an intelligible result?
    end



    # File.open("test_input.json", "w") { |f| f.write(@rdf_json.to_json) }
    info = {
      nodes: nodes,
      edges: edges
    }
    File.open("test_output.json", "w") { |f| f.write(info.to_json) }
    info
  end

  def omit_rel?(rel)
    return rel == "judgeOf" ||
           rel == "clerkOf" ||
           rel == "judgedBy" ||
           rel == "clerkedBy"
  end

  def val(rdf_item)
    rdf_item["value"].sub(/.*#/, "") if rdf_item.present?
  end
end
