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

var makeLabels = function(node) {
  var html = node.getParents()[0].name+" "+prettify(node.data.relation);
  html += "<h4>" + node.name + "</h4>", data = node.data;
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

var originalLabels = function(node) {
  var html = "<h4>" + node.name + "</h4>";
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
  var w = infovis.offsetWidth - 50, h = infovis.offsetHeight - 50;

    //init Hypertree
    var ht = new $jit.Hypertree({
      //id of the visualization container
      injectInto: 'infovis',
      //canvas width and height
      width: w,
      height: h,
      //Change node and edge styles such as
      //color, width and dimensions.
      Node: {
        dim: 9,
        color: "#f00"
      },
      Edge: {
        lineWidth: 2,
        color: "#ADADAD",
        overridable: true
      },
      Fx: {
        transition: $jit.Trans.linear
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
        }
      },
      onBeforeCompute: function(node){
        Log.write("centering");
      },
      onBeforePlotNode: function(node) {
        // node.Edge.color = "#123123"; // this changes all of them
        if (node._depth < 1) {
          node.Node.color = '#000'
        } else if (node._depth == 1) {
          node.Node.color = '#6B696E'
        } else if (node._depth == 2) {
          node.Node.color = '#696969'
        } else {
          node.Node.color = '#D4D4D4'
        }
      },
      onBeforePlotLine: function(adj) {
        // if (adj.nodeFrom.id == "per.000824") {
        //   adj.data.$color = "#111333";
        // }
      },
      //Attach event handlers and add text to the
      //labels. This method is only triggered on label
      //creation
      onCreateLabel: function(domElement, node){
        domElement.innerHTML = node.name;
        $jit.util.addEvent(domElement, 'click', function () {
          ht.onClick(node.id, {
            // onComplete: function() {
            //   ht.controller.onComplete();
            // }
          });
        });
      },
      //Change node styles when labels are placed
      //or moved.
      onPlaceLabel: function(domElement, node){
        var style = domElement.style;
        style.display = '';
        style.cursor = 'pointer';
        if (node._depth < 1) {
          style.fontSize = "0.9em";
          // style.color = "#000";
          style.color = "green";
        } else if (node._depth == 1) {
          style.fontSize = "0.8em";
          style.color = "#000";

        } else if(node._depth == 2){
          style.fontSize = "0.7em";
          style.color = "#696969";

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
    //load JSON data.
    ht.loadJSON(json);
    //compute positions and plot.
    ht.refresh();
    //end
    ht.controller.onComplete();
  }
