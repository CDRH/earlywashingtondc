var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
  iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
  typeOfCanvas = typeof HTMLCanvasElement,
  nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
  textSupport = nativeCanvasSupport 
  && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem) 
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};

var edgeColors = {
  "legal": "#6D96A7",          // light blue from logo
  "familyOf": "#a51400",       // maroon
  "acquaintanceOf": "orange",  // orange
  "work": "#4A5131",           // army green
  "": "magenta",               // something is wrong
  "default": "rgba(0,0,0,.2)"         // default grey
};

var nodeColors = {
  0: "#000000",
  1: "#6B696E",
  2: "#696969",
  "hover": "#FAC831",
  "selected": "#FAC831",
  "default": "#D4D4D4"
};

var labelColors = {
  0: "#000000",
  1: "#000000",
  2: "#696969",
  "default": "#000000"
};

var labelSize = {
  0: "0.9em",
  1: "0.8em",
  2: "0.6em",
  "default": "0.8em"
};

var getLabelStyle = function(depth) {
  style = {};
  style["color"] = labelColors[depth] ? labelColors[depth] : labelColors["default"];
  style["size"] = labelSize[depth] ? labelSize[depth] : labelSize["default"];
  return style;
};

var formatId = function(id) {
  // in order to prevent data from being overwritten by jit, first wave of people have _b
  // and second wave have _c appended to their id in the json.  This is removed here.
  return id.substring(0,10);
};

var makeLabels = function(node) {
  var html = "";
  // to get the correct relationship, for each parent grab all that parents'
  // children and select the current node from them, then the relationship
  // should not be any duplicate ids because of _b and _c for 2nd and 3rd levels
  node.getParents().forEach(function(supNode) {
    var xpath = "//*[id='"+supNode.id+"']//*[id='"+node.id+"']";
    var nodeFromParent = JSON.search(json, xpath, true); // true only returns first result
    if (nodeFromParent && nodeFromParent.length > 0) {
      var data = nodeFromParent[0]["data"];
      html += "<p>"+supNode.name+" "+prettify(data["relation"])+"</p>";
    }

  });
  var selectedId = formatId(node.id);
  html += "<h4><a href='" + personUrl + selectedId + "'>" + node.name + "</a></h4>";
  children = node.getSubnodes();
  node.getSubnodes().forEach(function(child, indx) {
    // appears that infovis automatically includes the node itself
    // but we want to avoid doing that
    if (indx != 0) {
      html += "<p>"+prettify(child.data.relation)+" "+child.name+"</p>";
    }
  });
  return html;
};

// the originalLabels and makeLabels function, sadly, pull from slightly different information
var originalLabels = function(node) {
  var html = "<h4><a href='" + personUrl + formatId(node.id) + "'>" + node.name + "</a></h4>";
  node.eachAdjacency(function(adj){
    var child = adj.nodeTo;
    if (child.data) {
      var rel = child.data.relation;
      html += "<p>"+prettify(rel) +" "+ child.name+"</p>";
    }
  });
  return html;
};

var prettify = function(relation) {
  if (relation) {
    // split on the uppercases, downcase, and join with spaces
    // "attorneyFor" becomes "attorney for"
    var relArr = relation.split(/(?=[A-Z])/);
    var relArr = relArr.map(function(item) { return item.toLowerCase(); });
    return relArr.join(" ");
  } else {
    return "unknown of";
  }
};

function initHypertree(){
  var infovis = document.getElementById('infovis');
  var w = infovis.offsetWidth - 10, h = infovis.offsetHeight - 0;

    //init Hypertree
    var ht = new $jit.Hypertree({
      //id of the visualization container
      injectInto: 'infovis',
      //canvas width and height
      width: w,
      height: h,
      Navigation: {
        enable: true,
        panning: true,
        zooming: 20
      },
      Node: {
        overridable: true,
        dim: 4,
        width: 100,
        height: 100,
        color: nodeColors["default"]
      },
      // I would like to use these but the duration makes them temporary events
      // that switch unexpectedly back to the original person.  :(
      // NodeStyles: {
      //   enable: true,
        // stylesHover: {
        //   dim: 15,
        //   color: nodeColors["hover"]
        // },
        // stylesClick: {
        //   dim: 15,
        //   color: nodeColors["selected"]
        // },
        // duration: 1500
      // },
      Edge: {
        lineWidth: 1,
        color: edgeColors["default"],
        overridable: true
      },
      Events: {
        enable: true,
        onClick: function(node) {
          if(!node) return;
          //Build detailed information about the file/folder
          //and place it in the right column.
          var html = ""
          if (node.data.original_element) {
            html = originalLabels(node);
          } else {
            html = makeLabels(node);
          }
          $jit.id('inner-details').innerHTML = html;
        },
      },
      onBeforeCompute: function(node){
        Log.write("centering");
      },
      onBeforePlotNode: function(node) {
        var nodeDepth = node._depth;
        var color = nodeColors[nodeDepth];
        node.Node.color = color ? color : nodeColors["default"];
      },
      onBeforePlotLine: function(adj) {
        // this should be simple but onBeforePlotLine overwrites with the wrong relationship
        // colors and runs a -> b as well as b -> a so unfortunately this has to get complicated
        // if running a -> b use b's relationship
        // if running b -> a also use b's relationship
        // if there is a type requested then only highlight those
        var fromLevel = adj.nodeFrom.data.level;
        var toLevel = adj.nodeTo.data.level;
        var relation;
        var color;
        if (fromLevel+1 == toLevel) {
          var relation = adj.nodeTo.data.relationType;
        } else if (fromLevel-1 == toLevel) {
          var relation = adj.nodeFrom.data.relationType;
        }
        if (graphType) {
          // everything default color except that relationship
          if (relation == graphType) {
            color = edgeColors[relation];
            adj.data.$lineWidth = 2;
          }
        } else {
          // if no type specified then color everything possible
          var color = edgeColors[relation];
        }
        if (color) { adj.data.$color = color; }
      },
      // Attach event handlers and add text to the
      // labels. This method is only triggered on label
      // creation
      onCreateLabel: function(domElement, node){
        domElement.innerHTML = node.name;
        $jit.util.addEvent(domElement, 'click', function () {
          ht.onClick(node.id, {});
        });
      },
      //Change node styles when labels are placed
      //or moved.
      onPlaceLabel: function(domElement, node){
        var style = domElement.style;
        style.display = '';
        style.cursor = 'pointer';
        var settings = getLabelStyle(node._depth);
        if (settings["size"] && settings["color"]) {
          style.fontSize = settings["size"];
          style.color = settings["color"];
        } else {
          style.display = 'none';
        }
        var left = parseInt(style.left);
        var w = domElement.offsetWidth;
        style.left = (left - w / 2) + 'px';
      },
      
      onComplete: function(){
        Log.write("done");
        
        //Build the right column relations list.
        //This is done by collecting the information (stored in the data property) 
        //for all the nodes adjacent to the centered node.
        var node = ht.graph.getClosestNodeToOrigin("current");
        var html = originalLabels(node);
        $jit.id('inner-details').innerHTML = html;
      }
    });

    // override the default behavior of hypertree so that the graph does not reorient
    $jit.Hypertree.prototype.onClick = function(id, opt) {};
    if (Object.keys(json).length !== 0) {
      ht.loadJSON(json);
      ht.refresh();  //compute positions and plot.
      ht.controller.onComplete();
    }
    // many thanks to SNAC for providing a lovely zooming / panning tool
    // that could be shamelessly incorporated into our graph
    // http://socialarchive.iath.virginia.edu/

    // SNAC panZoomControl
    var scaleFactor = 1.1;
    var panSize = 25;
    initialZoom = 1;
    ht.canvas.scale(initialZoom,initialZoom);

    $('#panUp').click(function(){
        ht.canvas.translate(0, panSize * 1/ht.canvas.scaleOffsetY);
    });

    $('#panLeft').click(function(){
        ht.canvas.translate(panSize * 1/ht.canvas.scaleOffsetX, 0);
    });

    $('#panRight').click(function(){
        ht.canvas.translate(-panSize * 1/ht.canvas.scaleOffsetX, 0);
    });

    $('#panDown').click(function(){
        ht.canvas.translate(0, -panSize * 1/ht.canvas.scaleOffsetY);
    });

    $('#zoomIn').click(function(){
        ht.canvas.scale(scaleFactor,scaleFactor);
    });

    $('#zoomReset').click(function(){
        ht.canvas.scale(initialZoom/ht.canvas.scaleOffsetX,initialZoom/ht.canvas.scaleOffsetY);
    });

    $('#zoomOut').click(function(){
        ht.canvas.scale(1/scaleFactor,1/scaleFactor);
    });
  }
