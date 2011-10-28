<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title><tiles:getAsString name="title" ignore="true" /></title>       
        <script type="text/javascript" src="../static/js/jquery-1.6.2.min.js"></script> 
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAA-gBHcbc-hWjWattlNwHI0BQ_gclvnbRHKqy5YZC2Jgi6EamBthSVWmQmT_kLW2NT6QuLuwHb0dBvDA" type="text/javascript"></script>
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
    var isAvaliable = false;
	
    function load() {
      if (GBrowserIsCompatible()) {
        var start = new GLatLng(48.85994695776509, 2.2918617725372314);
        map = new GMap2(document.getElementById("map"));
        map.setCenter(start, 11);
        map.addControl(new GSmallMapControl());
        map.addControl(new GMapTypeControl());
        map.enableScrollWheelZoom();

        carMarker = new GMarker(start, {draggable: false});

        svClient = new GStreetviewClient();
        pano = new GStreetviewPanorama(document.getElementById("streetview"));
		svClient.getNearestPanorama(carMarker.getLatLng(), pano.setLocationAndPOV(carMarker.getLatLng(), {yaw: 135, pitch: 0}));

        GEvent.addListener(pano, "initialized", function(loc) {
          panoMetaData = loc;
          moveCar();
        });

        directions = new GDirections(map);
        GEvent.addListener(directions, "load", function() {
          jumpInMyCar();
        });
		
        $.ajax( { 
            url: "http://${serverHost}:${serverPort}/demo/getAllRoutes",
            dataType: "json",
            success: function(data) {
                for (var i=0; i<data.length; i=i+3) 
                    addRoute(data[i], data[i+1])
            },
            error: function() {   
            },
            complete: function(){
            }
        }); 
      }
    }
    
    function generateRoute() {
      if (document.getElementById('country').value == 0) return;  
      if (driving) stopDriving();

      map.clearOverlays();
      document.getElementById("route").disabled = true;
      document.getElementById("stopgo").disabled = false;
      // building route
      var cityPoints = [];
      var dbPoints = [];

      dbPoints = loadFromDB();
      createRoute(cityPoints, dbPoints);
      var markerPoint = new GLatLng(dbPoints[0], dbPoints[1]);
      carMarker.setLatLng(markerPoint);
      map.addOverlay(carMarker);
      // load route
      directions.loadFromWaypoints(cityPoints); // Listener catch "load" event here
    }
	
	function changeTour() {
		document.getElementById("route").disabled = false;
                var id = document.getElementById("country").value;
                $.ajax( { 
                    url: "http://${serverHost}:${serverPort}/demo/checkRoute?routeId="+id,
                    dataType: "json",
                    success: function(data) { 
                        isAvaliable = data;
                    },
                    error: function() {                 
                    },
                    complete: function(){
                    }
                });
	}
	
	function loadFromDB() {
        var points = [];
        var route = document.getElementById("country").value;
        $.ajax( { 
            url: "http://${serverHost}:${serverPort}/demo/loadPoints?route="+route,
            async: false,
            dataType: "json",
            success: function(data) {
                points = data;
            },
            error: function() {   
            },
            complete: function(){
            }
        });      
        return points;
    } 
	
	function createRoute(cityPoints, dbPoints) {   
        for (var k=0; k<dbPoints.length; k=k+2) {
            var obj = new GLatLng(dbPoints[k], dbPoints[k+1]);
            cityPoints.push(obj);
        }    
    }
    
    function getTransactions() {
        var history = [];
        if (test=${empty user}) {
            history = [
                "<br><br><h1>You should <a href=${identityLocation}/rest/1/identity/authorize?response_type=code&providerId=yota&client_id=${apiKey}&redirect_uri=${redirect_uri}>sign in</a></h1>"
            ]
        }
        if (test=${not empty user}) {
            history = [
                "<br><br><h1>You should <a href=javascript:doSubmit() style=text-decoration: none><strong>buy</strong></a> this route"
            ]
        }
        
        $.ajax( { 
                    url: "http://${serverHost}:${serverPort}/demo/profile",
                    dataType: "json",
                    async: false,
                    success: function() {
                        setVisible('pay', history);
                    },
                    error: function() {
                        
                    },
                    complete: function(){
                    }
        });
    }

    function setVisible(obj, content) {
        var div = document.getElementById(obj);
        div.style.visibility = (div.style.visibility == 'visible') ? 'hidden' : 'visible';

        if (div.style.visibility == 'visible') {
            div.innerHTML = "<span id=close><a href=javascript:setVisible('pay') style=text-decoration: none><strong>Hide</strong></a></span>";
            fillContent(div, content);
        }	
        else div.innerHTML = "";
    }

    // later variable i replace with a route description
    function fillContent(div, content) {
        for (var i=0; i<content.length; i++)
            div.innerHTML += content[i]
        if (test=${empty user}) {
            div.innerHTML += "<br><br><h1>You should <a href=${identityLocation}/rest/1/identity/authorize?response_type=code&providerId=yota&client_id=${apiKey}&redirect_uri=${redirect_uri}>sign in</a></h1>";
            return;
        }
        if (test=${not empty user}) {
            div.innerHTML += "<br><br><h1>You should <a href=javascript:doSubmit() style=text-decoration: none><strong>buy</strong></a> this route";
            return;
        }
    }

    function doSubmit() {
        var id = document.getElementById("country").value;
        var name = document.getElementById("country").options[id].text;
        var area = document.getElementById("pay");

        area.innerHTML = "You've bought a new route: <strong>"
           + name + "</strong>";
        area.innerHTML += "<br><br> Closing soon..."; 
        $.ajax( { 
                    url: "http://${serverHost}:${serverPort}/demo/pay?id="+id,
                    async: false,
                    dataType: "json",
                    success: function() { 
                        addRoute(id, name);
                    },
                    error: function() {                 
                        $('#charge-status-msg').empty().text("The last payment has failed, please try again later.");
                    },
                    complete: function(){
                    }
                });
        isAvaliable = true;        
        setVisible('pay');
        return false;
    }
    
    function addRoute(id, name) {
        var countries = document.getElementById('country');
        var option = document.createElement('option');
        option.text = name;
        option.value = id;
        countries.add(option);
    }
	
    function jumpInMyCar() {
      route = directions.getRoute(0);
      collapseVertices(directions.getPolyline());
      map.setCenter(vertices[0], 16);
      checkCoverage(0);
    }

    function checkCoverage(step) {
      if (step > route.getNumSteps()) {
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

      carMarker.setLatLng(currentLatLng);

      currentStep = stepMap[idx];
      constructProgressArray(idx);
      setProgressDistance();

      map.panTo(currentLatLng, 16);
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
            advanceTimer = setTimeout("advance()", 1000);
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

        if (stepMap[nextVertexId - 1] == currentStep) {
          progressArray.push(nextVertex);
        } else {
          currentStep = stepMap[nextVertexId - 1];
          progressArray = [ currentLatLng, nextVertex ];
        }
        setProgressDistance();
      }
    }
    
    function endReached() {
      stopDriving();
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

    function startDriving() {
      if (isAvaliable) {
          document.getElementById("route").disabled = true;
          document.getElementById("stopgo").value = "Stop Me!";
          document.getElementById("stopgo").setAttribute('onclick', 'stopDriving()'); 
          document.getElementById("stopgo").onclick = function() { stopDriving(); }
          driving = true;
          advance();
      }
      else {
          setVisible('pay');
      }
    }
    
    function stopDriving() {
      driving = false;
      if (advanceTimer != null) {
        clearTimeout(advanceTimer);
        advanceTimer = null;
      }
      
      document.getElementById("route").disabled = false;
      document.getElementById("stopgo").disabled = false;
      document.getElementById("stopgo").value = "Drive Me!";
      document.getElementById("stopgo").setAttribute('onclick', 'startDriving()'); 
      document.getElementById("stopgo").onclick = function() { startDriving(); }
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
    
    function setQos() {
        $.ajax( { 
                    url: "http://${serverHost}:${serverPort}/demo/qos"
/*                    dataType: "json",
                    success: function(data) { 
                        GLog.write(data);
                    },
                    error: function() {                 
                    },
                    complete: function(){
                    }*/
        });
    }
    </script>
  <link rel="stylesheet" type="text/css" href="../static/styles/style.css"/>
  </head>
	<body onload="load();" onunload="GUnload();">  

        <div id="container">

            <div id="head">
                <tiles:insertAttribute name="header" />
            </div>
                    
                <div name="pano" id="streetview" style="width: 638px; height: 319px"></div>  
                
                <div id="map" style="width: 638px; height: 319px"></div>
                
                <b>Choose Tour:</b><br>
                <select id="country" onchange="changeTour()">
                    <option value="0" disabled>Choose Tour:</option>
                </select>
                
                <input type="button" value="Show Me!" id="route" onclick="generateRoute()" />
                <input type="button" value="Drive Me!" id="stopgo"  onclick="startDriving()"  disabled />

                <a href="javascript:setQos()">QoS</a>
                
		<div id="body">
                <tiles:insertAttribute name="body" />
                </div>  
                                
                <div id="pay">
		<p id="charge-status-msg" class="info-msg"></p> 
                </div>
                
                <div id="profile">
                </div>    
        </div>

    </body>
</html>
