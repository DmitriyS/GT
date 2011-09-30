<!--
 /*********************************************************************************
 *
 * Copyright 2011 - 2011 Yota Lab LLC, Russia
 * Copyright 2011 - 2011 Seconca Holdings Limited, Cyprus
 *
 *  This source code is Yota Lab Confidential Proprietary
 *  This software is protected by copyright.  All rights and titles are reserved.
 *  You shall not use, copy, distribute, modify, decompile, disassemble or reverse
 *  engineer the software. Otherwise this violation would be treated by law and
 *  would be subject to legal prosecution.  Legal use of the software provides
 *  receipt of a license from the right holder only.
 *
 *
 **********************************************************************************/
-->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title><tiles:getAsString name="title" ignore="true" /></title>
                
        <script type="text/javascript" src="../static/js/jquery-1.6.2.min.js"></script> 
        
        <script type="text/javascript" src="http://maps.google.com/maps?file=api&amp;&v=2&key=ABQIAAAAjU0EJWnWPMv7oQ-jjS7dYxSPW5CJgpdgO_s4yyMovOaVh_KvvhSfpvagV18eOyDWu7VytS6Bi1CWxw"></script> 
        <script type="text/javascript"> 
    
    // vars
    var map;
    var myPano;   
    var panoClient;
    var directions;
    var vertices;
    var v;
    var driving = false;
    var yaw_pan;

    // init()
    function initialize() {
          if (GBrowserIsCompatible()) {
              var center = new GLatLng(48.85994695776509, 2.2918617725372314);
              panoClient = new GStreetviewClient();      
              map = new GMap2(document.getElementById("map_canvas"));
              map.setCenter(center, 11);
              map.addControl(new GSmallMapControl());
              map.addControl(new GMapTypeControl());
              map.enableScrollWheelZoom();
			  
              directions = new GDirections(map);
              var houseMarker;
              houseMarker = new GMarker(center, {draggable: false});
              // panorama at screenload
              myPano = new GStreetviewPanorama(document.getElementById("pano"));
              panoClient.getNearestPanorama(houseMarker.getLatLng(), myPano.setLocationAndPOV(houseMarker.getLatLng(), {yaw: 135, pitch: 0}));
              
              GEvent.addListener(directions, "load", function() {
                handle();
              });
              
              if (test=${not empty user})
                $.ajax( { 
                      url: "http://${serverHost}:${serverPort}/demo/getRoutes",
                      dataType: "json",
                      success: function(data) {
                         for (var i=0; i<data.length; i=i+2) 
                            if (data[i]>2) addRoute(data[i], data[i+1])
                      },
                      error: function() {   
                      },
                      complete: function(){
                      }
                });  
              
          }
    }
    
    function createRoute(cityPoints, dbPoints) {   
        for (var k=0; k<dbPoints.length; k=k+2) {
            var obj = new GLatLng(dbPoints[k], dbPoints[k+1]);
            cityPoints.push(obj);
        }    
    }
    
    // catch "load" event
    function handle () {
        getVertices(directions.getPolyline());
    }
    
    function getVertices(path) {
        vertices = new Array ();
        for (var i = 0; i < path.getVertexCount(); i++) 
              if (! path.getVertex(i).equals(vertices[vertices.length - 1])) {
                vertices.push(path.getVertex(i));
              }  
        panoClient.getNearestPanorama(vertices[0], showPanoData);
    }
    
    function showPanoData(panoData) {
      if (panoData.code == 500) {
          setTimeout("move()", 300);
        } else if (panoData.code == 600) {
          setTimeout("move()", 300);
        } else {
      }
      myPano.setLocationAndPOV(panoData.location.latlng, {yaw: getBearing(vertices[0], vertices[1]), pitch: 0});
    }
    
    // angle between 2 points (point-north is 0 degrees)
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
    
    // "Show me!" button
    function drawRoute() {
      if (driving) stopDrive();
      v=0;
      map.clearOverlays();
      document.getElementById("draw").disabled = true;
      document.getElementById("drive").disabled = false;
      // building route
      var cityPoints = [];
      var dbPoints = [];
      dbPoints = changeTour();
      createRoute(cityPoints, dbPoints);
      var markerPoint = new GLatLng(dbPoints[0], dbPoints[1]);
      marker = new GMarker(markerPoint, {draggable: false});
      map.addOverlay(marker);
      // load route
      directions.loadFromWaypoints(cityPoints); // Listener catch "load" event here
    }
    
    // "Drive Me!" button
    function moveRoute() {
            document.getElementById("draw").disabled = true;
            document.getElementById("drive").disabled = false;
            document.getElementById("drive").value = 'Stop me!';
            document.getElementById("drive").setAttribute('onclick', 'stopDrive()');
            document.getElementById("drive").onclick = function() { stopDrive(); }
            
            driving = true;
/*            
            markers = new Array();
            for (var i=0; i<vertices.length; i++) {
                markers[i] = new GMarker(vertices[i], {draggable: false});
                map.addOverlay(markers[i]);
            } 
*/			
//            var v=0;
            move();
    }
    
    // moving iterations
    function move() {
        if (!driving) return;
        
        var to4ka = myPano.getLatLng();
        var yaw = getBearing(to4ka, vertices[v+1]);
        
        var close;
        if (to4ka.distanceFrom(vertices[v+1]) < 10)
            close = true;  
        else                                        
            close = false;
	panoClient.getNearestPanorama(to4ka, function(svData) {
            if (svData.code == 500) {
                GLog.write("ERROR 500"); // server error
                setTimeout("move()", 1000);
            } else if (svData.code == 600) {
                GLog.write("ERROR 600"); // no panorama found
                move();
            } else {
                // check if we have passed the vertex
                if (svData.links.length == 2) { // doroga
                        if (getYawDelta(yaw_pan, yaw) > 90)
                            v++;
                }
                else { // crossroad
                        if (close) v++;
                } 
                
                yaw = getBearing(to4ka, vertices[v+1]);
                
                // links.length - number of links to all directions
                for (var i = 0; i < svData.links.length; i++) {
                    var d = getYawDelta(yaw, svData.links[i].yaw);
                    
                    if (svData.links.length == 2) {
                        if (d<135) { yaw_pan = svData.links[i].yaw; break;}
                        else yaw_pan = yaw;
                    }
                    else { // crossroad
                        if(d<20) { yaw_pan = svData.links[i].yaw; break;} 
                        else yaw_pan = yaw;
                    }
                }
                
         //       GLog.write("v=" + v);
         //       GLOg.write("vertices[v+1]=" + vertices[v+1]);
         //       GLog.write("yaw=" + yaw);
         //       GLog.write("yaw_pan=" + yaw_pan);
                
                myPano.panTo({yaw: yaw_pan, pitch: 0}); // smooth pan
                setTimeout("myPano.followLink(" + yaw_pan + ")", 1500); // smooth move forward     
              }
        });
        map.panTo(to4ka); // set map center on current marker
        marker.setLatLng(to4ka);
//        setTimeout("move(" + yaw_pan + ", " + v + ")", 3000);
        setTimeout("move()", 3000);
    }
    
    // "Stop Me!" button
    function stopDrive () {
        driving = false;
        document.getElementById("draw").disabled = false;
        document.getElementById("drive").value = 'Drive me!'
        document.getElementById("drive").setAttribute('onclick', 'moveRoute()');
        document.getElementById("drive").onclick = function() { moveRoute(); }
    }
    
    // change route button
    function changeTour() {
        document.getElementById("draw").disabled = false;
        var points = [];
        var route = document.getElementById("country").value;
        //  dbPoints = [];
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
    
    function setVisible(obj) {
        var route;
        var div = document.getElementById(obj);
        div.style.visibility = (div.style.visibility == 'visible') ? 'hidden' : 'visible';
// here I get route description (string)
        if (div.style.visibility == 'visible') {
            div.innerHTML = "Wait please...";
            
            $.ajax( { 
                url: "http://${serverHost}:${serverPort}/demo/getRoutesToBuy",
                async: false,
                dataType: "json",
                success: function(data) {
                    route = data;
                },
                error: function() {  
                },
                complete: function(){
                }
            });
            fillContent(div, route);
        }	

        else div.innerHTML = "";
    }

    // later variable i replace with a route description
    function fillContent(obj, route) {
        obj.innerHTML = "<span id=close><a href=javascript:setVisible('pay') style=text-decoration: none><strong>Hide</strong></a></span>";
        if (route[0] == null)
            obj.innerHTML += "<br><br><h1>You've bought all routes</h1>";
        else {
            obj.innerHTML += "<h1>Choose Route:</h1>";
            for (var i=0; i<route.length; i=i+2)
                obj.innerHTML += "<p><input type=radio name=route id=" + route[i+1] + " value=" + route[i] + "><label for=" + route[i+1] + ">" + route[i+1] + "</label></p>";
            obj.innerHTML += "<p style=text-align:" + "right" + ";><input type=submit value=Submit onclick=doSubmit()></p>";
        }
    }

    function doSubmit() {
        var routes = document.getElementsByName("route");
        var area = document.getElementById("pay");

        var chosenId = 0;
        var chosenName = "";
        for (var i = 0; i < routes.length; i++) {
            if (routes[i].checked) {
                chosenId = routes[i].value;
                chosenName = routes[i].id;
                break;
            }
        }

        area.innerHTML = "You've bought a new route: <strong>"
           + chosenName + "</strong>";
        area.innerHTML += "<br><br> Closing soon..."; 
        $.ajax( { 
                    url: "http://${serverHost}:${serverPort}/demo/pay?id="+chosenId,
                    async: false,
                    dataType: "json",
                    success: function(buy) { 
//                        GLog.write(buy.transactionId);
                        addRoute(chosenId, chosenName);
                    },
                    error: function() {                 
                        $('#charge-status-msg').empty().text("The last payment has failed, please try again later.");
                    },
                    complete: function(){
                    }
                });
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

    // diff between the angles
    function getYawDelta(a, b) {
      var d = Math.abs(sanitiseYaw(a) - sanitiseYaw(b));
      if (d > 180) {
        d = 360 - d;
      }
      return d;
    }
    
    // <360
    function sanitiseYaw(yaw) {
      if (yaw > 360 || yaw < 360) {
        yaw = yaw % 360;
      }
      return yaw;
    }
    
    // prototypes
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
        
        <link rel="stylesheet" type="text/css" href="../static/styles/style.css"/>
    </head>
    <body onload="initialize()" onunload="GUnload()">  

        <div id="container">

            <div id="head">
                <tiles:insertAttribute name="header" />
            </div>
                    
                <div name="pano" id="pano" style="width: 700px; height: 350px"></div>  
                
                <div id="map_canvas" style="width: 700px; height: 300px"></div>
                
                <b>Choose Tour:</b><br>
                <select id="country" onchange="changeTour()">
                    <option value="0" disabled>Choose Tour:</option>
                    <option value="1">Sights</option>                
                    <option value="2">Impressionism</option>
                </select>
                
                <input type="button" value="Show Me!" id="draw"  onclick="drawRoute()" />
                <input type="button" value="Drive Me!" id="drive"  onclick="moveRoute()" disabled/> 
                <c:if test="${not empty user}">
                <a href="#" onclick="setVisible('pay');return false" target="_self" id="charge">Buy!</a>
                </c:if>
    
             <div id="body">
                <tiles:insertAttribute name="body" />
             </div>  
                <c:if test="${not empty user}">
                <div id="pay">
		<p id="charge-status-msg" class="info-msg"></p> 
                </div>
                </c:if>
        </div>

    </body>
</html>
