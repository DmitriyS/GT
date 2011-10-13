
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--
 Copyright 2008 Google Inc. 
 Licensed under the Apache License, Version 2.0: 
 http://www.apache.org/licenses/LICENSE-2.0 
 -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Google Maps Street View API Driving Directions Example</title>
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAjU0EJWnWPMv7oQ-jjS7dYxSPW5CJgpdgO_s4yyMovOaVh_KvvhSfpvagV18eOyDWu7VytS6Bi1CWxw" type="text/javascript"></script>
    <script type="text/javascript">
    var map;
    var pano;
    var svClient;
    var directions;
    var route;
    var vertices;
    var vertexMap;
    var stepToVertex;
    var stepMap;
    var currentLatLng;
    var panoMetaData;
    var close = false;
    var bearing;
    var nextBearing;
    var nextVertexId;
    var nextVertex;
    var progressArray;
    var progressDistance;
    var currentStep;
    var carMarker;
    var selectedStep = null;
    var driving = false;
    var advanceTimer = null;
    var advanceDelay = 1;
    
    function load() {
      if (GBrowserIsCompatible()) {
        var start = new GLatLng(37.090240,-95.712891);
        map = new GMap2(document.getElementById("map"));
        map.setCenter(start, 3);
        map.addControl(new GSmallMapControl());

        carMarker = getCarMarker(start);
        map.addOverlay(carMarker);
        carMarker.hide();

        svClient = new GStreetviewClient();
        pano = new GStreetviewPanorama(document.getElementById("streetview"));

        GEvent.addListener(pano, "initialized", function(loc) {
          panoMetaData = loc;
          moveCar();
        });

        GEvent.addListener(pano, "error", function(errorCode) {
          showStatus("The requested panorama could not be displayed");
        });

        directions = new GDirections(map);
        GEvent.addListener(directions, "load", function() {
          jumpInMyCar();
        });

        GEvent.addListener(directions, "error", function() {
          showStatus("Could not generate a route for the current start and end addresses");
        });
      }
    }
    
    function getCarMarker(start) {
      return new GMarker(start, getArrowIcon(0.0));
    }

    function setCarMarkerImage(bearing) {
      carMarker.setImage(getArrowUrl(bearing));
    }
    
    function generateRoute() {
      var from = document.getElementById("from").value;
      var to = document.getElementById("to").value;
      directions.load("from: " + from + " to: " + to, { preserveViewport: true, getSteps: true });
    }

    function jumpInMyCar() {
      route = directions.getRoute(0);
      collapseVertices(directions.getPolyline());
      map.setCenter(vertices[0], 16);
      renderTextDirections();
      checkCoverage(0);
    }

    function checkCoverage(step) {
      if (step > route.getNumSteps()) {
        hideStatus();
        stopDriving();
        jumpToVertex(0);
      } else {
        if (step == route.getNumSteps()) {
          ll = route.getEndLatLng();
        } else {
          ll = route.getStep(step).getLatLng();
        }

        svClient.getNearestPanorama(ll, function(svData) {
          if (svData.code == 500) {
            setTimeout("checkCoverage(" + step + ")", 1000);
          } else if (svData.code == 600) {
            showStatus("Street View coverage is not available for this route");
          } else {
            checkCoverage(step + 1);
          }
        });
      }
    }

    function jumpToVertex(idx) {
      currentLatLng = vertices[idx];
      nextVertex = vertices[idx + 1];
      nextVertexId = idx + 1;

          bearing = getBearingFromVertex(idx);
      nextBearing = getBearingFromVertex(idx + 1);

      setCarMarkerImage(bearing);
      carMarker.setLatLng(currentLatLng);
      carMarker.show();

      currentStep = stepMap[idx];
      constructProgressArray(idx);
      setProgressDistance();
      updateProgressBar(0);

      map.panTo(currentLatLng, 16);
      highlightStep(currentStep);
      checkDistanceFromNextVertex();

      pano.setLocationAndPOV(currentLatLng, { yaw:bearing, pitch:0 });
      svClient.getNearestPanorama(currentLatLng, function(loc) {
        if (loc.code == 500) {
          setTimeout("jumpToVertex(" + idx + ")", 1000);
        } else if (loc.code == 600) {
          jumpToVertex(nextVertexId);
        } else {
          panoMetaData = loc.location;
          panoMetaData.pov.yaw = bearing;
          moveCar();
        }
      });
    }

    function moveCar() {
      currentLatLng = panoMetaData.latlng;
      carMarker.setLatLng(currentLatLng);
      map.panTo(currentLatLng);

      svClient.getNearestPanorama(panoMetaData.latlng, function(svData) {
        if (svData.code == 500) {
          setTimeout("moveCar()", 1000);
        } else if (svData.code == 600) {
          jumpToVertex(nextVertexId);
        } else {
          panoMetaData.links = svData.links;
          checkDistanceFromNextVertex();
          if (driving) {
            advanceTimer = setTimeout("advance()", advanceDelay * 1000);
          }
        }
      });
    }

    function checkDistanceFromNextVertex() {
      close = false;
      var d = currentLatLng.distanceFrom(nextVertex);
      var b = getBearing(currentLatLng, nextVertex);

      if (getYawDelta(bearing, b) > 90) {
        incrementVertex();
        if (driving) {
          checkDistanceFromNextVertex();
        }
      } else {
        updateProgressBar(progressDistance - d);
        if (driving) {
          updateViewerDirections(progressDistance - d);
        }
        if (d < 10) {
          close = true;
        }
      }
    }

    function advance() {
      var selected = selectLink(bearing);
      if (close && nextBearing) {
        var selectedTurn = selectLink(nextBearing);
        if (selectedTurn.delta < 15) {
          selected = selectedTurn;
          incrementVertex();
        }
      }

      if (selected.delta > 40) {
        jumpToVertex(nextVertexId);
      } else {
        var panAngle = getYawDelta(panoMetaData.pov.yaw, panoMetaData.links[selected.idx].yaw);
        pano.panTo({ yaw:panoMetaData.links[selected.idx].yaw, pitch:0 });
        setTimeout(function() {
          pano.followLink(panoMetaData.links[selected.idx].yaw);
        }, panAngle * 10);
      }
    }

    function selectLink(yaw) {
      var Selected = new Object();

      for (var i = 0; i < panoMetaData.links.length; i++) {
        var d = getYawDelta(yaw, panoMetaData.links[i].yaw);
        if (Selected.delta == null || d < Selected.delta) {
          Selected.idx = i;
          Selected.delta = d;
        }
      }
      return Selected;
    }

    function incrementVertex() {
      if (! vertices[nextVertexId + 1]) {
        endReached();
      } else {
        nextVertexId++;
        nextVertex = vertices[nextVertexId];
            bearing = getBearingFromVertex(nextVertexId - 1);
        nextBearing = getBearingFromVertex(nextVertexId);
        setCarMarkerImage(bearing);
        if (stepMap[nextVertexId - 1] == currentStep) {
          progressArray.push(nextVertex);
        } else {
          currentStep = stepMap[nextVertexId - 1];
          highlightStep(currentStep);
          progressArray = [ currentLatLng, nextVertex ];
          updateProgressBar(0);
        }
        setProgressDistance();
      }
    }

    function endReached() {
      stopDriving();
      updateProgressBar(0);
      showInstruction("You have reached your destination");
      document.getElementById("step" + selectedStep).style.backgroundColor = "white";
      selectedStep = null;
    }

    function getBearingFromVertex(n) {
      var origin = vertices[n];
      var destination = vertices[n+1];
      if (destination != undefined) {
        return getBearing(origin, destination);
      } else {
        return null;
      }
    }

    function updateViewerDirections(distanceFromStartOfStep) {
      var lengthOfStep = route.getStep(currentStep).getDistance().meters;
      var distanceFromEndOfStep = (lengthOfStep - distanceFromStartOfStep);

      distanceFromEndOfStep *= 3.2808399;

      var uiDistance, unit;

      if (distanceFromEndOfStep > 7920) {
        distanceFromEndOfStep /= 5280;
        uiDistance = distanceFromEndOfStep.toFixed(0);
        unit = 'miles';
      } else if (distanceFromEndOfStep > 4620) {
        uiDistance = '1';
        unit = 'mile';
      } else if (distanceFromEndOfStep > 3300) {
        /* Display "3/4 mile" between 5/8 and 7/8 of a mile */
        uiDistance = '&frac34;';
        unit = 'mile';
      } else if (distanceFromEndOfStep > 1980) {
        /* Display "1/2 mile" between 3/8 and 5/8 of a mile */
        uiDistance = '&frac12;';
        unit = 'mile';
      } else if (distanceFromEndOfStep >  660) {
        /* Display "1/4 mile" between 1/8 and 3/8 of a mile */
        uiDistance = '&frac14;';
        unit = 'mile';
      } else {
        uiDistance = (Math.round(distanceFromEndOfStep / 10)) * 10;
        unit = "ft";
      }

      if (route.getStep(currentStep + 1) != undefined) {
        showInstruction('In ' + uiDistance + ' ' + unit + ': ' + route.getStep(currentStep + 1).getDescriptionHtml());
      } else {
        showInstruction('In ' + uiDistance + ' ' + unit + ': You will reach your destination');
      }
    }
    
    function constructProgressArray(vertexId) {
      progressArray = new Array();
      var stepStart = stepToVertex[currentStep];
      for (var i = stepToVertex[currentStep]; i <= vertexId + 1; i++) {
        progressArray.push(vertices[i]);
      }
    }

    function setProgressDistance() {
      var polyline = new GPolyline(progressArray);
      progressDistance = polyline.getLength();
    }

    function updateProgressBar(progress) {
      progress = (progress < 0 ? 0 : progress);
      var stepLength = route.getStep(currentStep).getDistance().meters;
      setProgressBarLength(1 - (progress / stepLength));
    }
    
    function setProgressBarLength(progress) {
      var width = (636 * progress);
      if (width < 0) {
        width = 0;
      }
      document.getElementById("progressBar").style.width = width + "px";
    }

    function getYawDelta(a, b) {
      var d = Math.abs(sanitiseYaw(a) - sanitiseYaw(b));
      if (d > 180) {
        d = 360 - d;
      }
      return d;
    }

    function sanitiseYaw(yaw) {
      if (yaw > 360 || yaw < 360) {
        yaw = yaw % 360;
      }
      return yaw;
    }

    function getArrowIcon(bearing) {
      var icon = new GIcon();
      icon.image = getArrowUrl(bearing);
      icon.iconSize = new GSize(24, 24);
      icon.iconAnchor = new GPoint(12, 12);
      return icon;
    }

   function getArrowUrl(bearing) {
      var id = (3 * Math.round(bearing / 3)) % 120;
      return "http://maps.google.com/mapfiles/dir_" + id + ".png";
    }

   function collapseVertices(path) {
     vertices = new Array();
     vertexMap = new Array(path.getVertexCount());

     vertices.push(path.getVertex(0));
     vertexMap[0] = 0;

     for (var i = 1; i < path.getVertexCount(); i++) {
       if (! path.getVertex(i).equals(vertices[vertices.length - 1])) {
         vertices.push(path.getVertex(i));
       }
       vertexMap[i] = vertices.length - 1;
     }

     stepToVertex = new Array(route.getNumSteps());
     stepMap      = new Array(vertices.length);

     for (var i = 0; i < route.getNumSteps(); i++) {
       stepToVertex[i] = vertexMap[route.getStep(i).getPolylineIndex()];
     }

     var step = 0;
     for (var i = 0; i < vertices.length; i++) {
       if (stepToVertex[step + 1] == i) {
         step++;
       }
       stepMap[i] = step;
     }
   }

    function renderTextDirections() {

      var startAddress = route.getStartGeocode().address;
      var   endAddress = route.getEndGeocode().address;
      var html  =  getDirectionsWaypointHtml(startAddress, "A");
          html +=  getDivHtml("summary", "", route.getSummaryHtml());

      for (var n = 0; n < route.getNumSteps(); n++) {
        html += '<a onclick="selectStep(' + n + ')">';
        html += getDivHtml("step" + n, "dstep", route.getStep(n).getDescriptionHtml());
        html += '</a>';
      }
      html += getDirectionsWaypointHtml(endAddress, "B");
      document.getElementById("directions").innerHTML = html;

      setWaypointIcon('A');
      setWaypointIcon('B');
    }
    
    function getDirectionsWaypointHtml(address, letter) {
     var content = getDivHtml('letter' + letter, 'letterIcon', "");
         content += '<span class="waypointAddress">' + address + '</span>';
      return getDivHtml("wayPoint" + letter, "waypoint", content);
    }

    function setWaypointIcon(letter) {
      var png = 'http://maps.google.com/intl/en_us/mapfiles/icon_green' + letter + '.png';
      document.getElementById('letter' + letter).style.backgroundImage = 'url(' + png + ')';
    }

    function getDivHtml(id, cssClass, content) {
      var div = "<div";
      if (id != "") {
        div += ' id="' + id + '"';
      }

      if (cssClass != "") {
        div += ' class="' + cssClass + '"';
      }

      div += '>' + content + '</div>';
      return div;
    }

    function selectStep(i) {
      var vertex = vertexMap[route.getStep(i).getPolylineIndex()];
      stopDriving();
      jumpToVertex(vertex);
    }

    function highlightStep(i) {
      if (selectedStep != null) {
        document.getElementById("step" + selectedStep).style.backgroundColor = "white";
      }

      document.getElementById("step" + i).style.backgroundColor = "#eeeeff";
      selectedStep = i;
    }

    function startDriving() {
      hideInstruction();
      document.getElementById("route").disabled = true;
      document.getElementById("stopgo").value = "Stop";
      document.getElementById("stopgo").setAttribute('onclick', 'stopDriving()'); 
      document.getElementById("stopgo").onclick = function() { stopDriving(); }
      driving = true;
      advance();
    }

    function stopDriving() {
      driving = false;
      
      if (advanceTimer != null) {
        clearTimeout(advanceTimer);
        advanceTimer = null;
      }
      
      document.getElementById("route").disabled = false;
      document.getElementById("stopgo").disabled = false;
      document.getElementById("stopgo").value = "Drive";
      document.getElementById("stopgo").setAttribute('onclick', 'startDriving()'); 
      document.getElementById("stopgo").onclick = function() { startDriving(); }
      showInstruction('Press <b>Drive</b> to follow your route');
    }

    function setSpeed() {
      advanceDelay = document.getElementById('speed').selectedIndex;
    }
    
    function showStatus(message) {
      hideInstruction();
      document.getElementById("status").innerHTML = message;
      document.getElementById("status").style.display = "block";
      document.getElementById("streetview").style.display = "none";
    }

    function hideStatus() {
      document.getElementById("status").style.display = "none";
      document.getElementById("streetview").style.display = "block";
    }

    function showInstruction(message) {
      document.getElementById("instruction").innerHTML = message;
      document.getElementById("instruction").style.display = "block";
    }

    function hideInstruction() {
      document.getElementById("instruction").style.display = "none";
    }

    function getBearing(origin, destination) {
      if (origin.equals(destination)) {
        return null;
      }
      var lat1 = origin.lat().toRad();
      var lat2 = destination.lat().toRad();
      var dLon = (destination.lng()-origin.lng()).toRad();

      var y = Math.sin(dLon) * Math.cos(lat2);
      var x = Math.cos(lat1)*Math.sin(lat2) -
              Math.sin(lat1)*Math.cos(lat2)*Math.cos(dLon);
      return Math.atan2(y, x).toBrng();
    }
    
    Number.prototype.toRad = function() {
      return this * Math.PI / 180;
    }

    Number.prototype.toDeg = function() {
      return this * 180 / Math.PI;
    }

    Number.prototype.toBrng = function() {
      return (this.toDeg()+360) % 360;
    }
    </script>
  </head>
  <body onload="load();" onunload="GUnload();">
    <div id="content">
    <table cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="2">
        <div id="svPanel">
          <div id="streetview" style="width: 638px; height: 319px;"></div>
          <div id="status">Enter your start and end addresses and click <b>Route</b></div>
          <div id="instruction"></div>
        </div>
        <div id="progressBorder">
          <div id="progressBar"></div>
        </div>
      </td>
    </tr>
    <tr>
      <td>
        <div id="map"></div>
          <div class="controls">
            <div class="label">From</div>
            <div class="input"><input id="from" size="30" value="stanyan st, san francisco"/></div>
          </div>
          <div class="controls">
            <div class="label">To</div>
            <div class="input"><input id="to" size="30" value="twin peaks blvd, san francisco"/></div>
          </div>
          <div class="controls">
            <div class="label">Speed</div>
            <div id="actions">
              <select id="speed" onchange="setSpeed()">
                <option value="0">Fast</option>
                <option value="1" SELECTED>Medium</option>
                <option value="2">Slow</option>
              </select>
              <div id="buttons">
                <input type="button" value="Route" id="route" onclick="generateRoute()" />
                <input type="button" value="Drive" id="stopgo"  onclick="startDriving()"  disabled />
              </div>
            </div>
          </div>
        </div>
      </td>
      <td>
        <div id="directions"></div>
      </td>
    </tr>
  </table>
  </div>
  </body>
</html>
