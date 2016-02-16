var labelType,useGradients,nativeTextSupport,animate;!function(){var e=navigator.userAgent,t=e.match(/iPhone/i)||e.match(/iPad/i),n=typeof HTMLCanvasElement,a="object"==n||"function"==n,o=a&&"function"==typeof document.createElement("canvas").getContext("2d").fillText;labelType=!a||o&&!t?"Native":"HTML",nativeTextSupport="Native"==labelType,useGradients=a,animate=!(t||!a)}();var Log={elem:!1,write:function(e){this.elem||(this.elem=document.getElementById("log")),this.elem.innerHTML=e,this.elem.style.left=500-this.elem.offsetWidth/2+"px"}},edgeColors={legalRelationship:"#6D96A7",familyRelationship:"#a51400",socialRelationship:"orange",workRelationship:"#4A5131","":"magenta","default":"rgba(0,0,0,.2)"},nodeColors={0:"#000000",1:"#6B696E",2:"#696969",hover:"#FAC831",selected:"#FAC831","default":"#D4D4D4"},labelColors={0:"#000000",1:"#000000",2:"#696969","default":"#000000"},labelSize={0:"0.9em",1:"0.8em",2:"0.6em","default":"0.8em"},getLabelStyle=function(e){return style={},style.color=labelColors[e]?labelColors[e]:labelColors["default"],style.size=labelSize[e]?labelSize[e]:labelSize["default"],style},formatId=function(e){return e.substring(0,10)},makeLabels=function(e){var t="";e.getParents().forEach(function(n){var a="//*[id='"+n.id+"']//*[id='"+e.id+"']",o=JSON.search(json,a,!0);if(o&&o.length>0){var i=o[0].data;t+="<p>"+n.name+" "+prettify(i.relation)+"</p>"}});var n=formatId(e.id);t+="<h4><a href='"+personUrl+n+"'>"+e.name+"</a></h4>",children=e.getSubnodes();var a=JSON.search(json,"//*[id='"+e.id+"']",!0),o=a[0];return o&&o.children&&o.children.length>0&&o.children.forEach(function(e){t+="<p>"+prettify(e.data.relation)+" "+e.name+"</p>"}),t},originalLabels=function(e){var t="<h4><a href='"+personUrl+formatId(e.id)+"'>"+e.name+"</a></h4>";return e.eachAdjacency(function(e){var n=e.nodeTo;if(n.data){var a=n.data.relation;t+="<p>"+prettify(a)+" "+n.name+"</p>"}}),t},prettify=function(e){if(e){var t=e.split(/(?=[A-Z])/),t=t.map(function(e){return e.toLowerCase()});return t.join(" ")}return"unknown of"},initHypertree=function(){var e=document.getElementById("infovis"),t=e.offsetWidth-10,n=e.offsetHeight-0,a=new $jit.Hypertree({injectInto:"infovis",width:t,height:n,Navigation:{enable:!0,panning:!0,zooming:20},Node:{overridable:!0,dim:4,width:100,height:100,color:nodeColors["default"]},Edge:{lineWidth:1,color:edgeColors["default"],overridable:!0},Events:{enable:!0,onClick:function(e){if(e){var t="";t=e.data.original_element?originalLabels(e):makeLabels(e),$jit.id("inner-details").innerHTML=t}}},onBeforeCompute:function(){Log.write("centering")},onBeforePlotNode:function(e){var t=e._depth,n=nodeColors[t];e.Node.color=n?n:nodeColors["default"]},onBeforePlotLine:function(e){var t,n,a=e.nodeFrom.data.level,o=e.nodeTo.data.level,i=1;if(a+1==o)t=e.nodeTo.data.relationType;else if(a-1==o){var l="//*[id='"+e.nodeTo.id+"']//*[id='"+e.nodeFrom.id+"']",r=JSON.search(json,l,!0);r&&r[0]&&r[0].data&&(t=r[0].data.relationType)}graphType?t==graphType?(n=edgeColors[t],i=2):n=edgeColors["default"]:n=edgeColors[t],n&&(e.data.$color=n),e.data.$lineWidth=i},onCreateLabel:function(e,t){e.innerHTML=t.name,$jit.util.addEvent(e,"click",function(){a.onClick(t.id,{})})},onPlaceLabel:function(e,t){var n=e.style;n.display="",n.cursor="pointer";var a=getLabelStyle(t._depth);a.size&&a.color?(n.fontSize=a.size,n.color=a.color):n.display="none";var o=parseInt(n.left),i=e.offsetWidth;n.left=o-i/2+"px"},onComplete:function(){Log.write("done");var e=a.graph.getClosestNodeToOrigin("current"),t=originalLabels(e);$jit.id("inner-details").innerHTML=t}});$jit.Hypertree.prototype.onClick=function(){},0!==Object.keys(json).length&&(a.loadJSON(json),a.refresh(),a.controller.onComplete());var o=1.1,i=25;initialZoom=1,a.canvas.scale(initialZoom,initialZoom),$("#panUp").click(function(){a.canvas.translate(0,1*i/a.canvas.scaleOffsetY)}),$("#panLeft").click(function(){a.canvas.translate(1*i/a.canvas.scaleOffsetX,0)}),$("#panRight").click(function(){a.canvas.translate(1*-i/a.canvas.scaleOffsetX,0)}),$("#panDown").click(function(){a.canvas.translate(0,1*-i/a.canvas.scaleOffsetY)}),$("#zoomIn").click(function(){a.canvas.scale(o,o)}),$("#zoomReset").click(function(){a.canvas.scale(initialZoom/a.canvas.scaleOffsetX,initialZoom/a.canvas.scaleOffsetY)}),$("#zoomOut").click(function(){a.canvas.scale(1/o,1/o)}),$(".limiter").click(function(){var e=$(this).attr("type");graphType=e?e:null,$(".limiter").removeClass("selected"),$(this).toggleClass("selected"),a.refresh()})};