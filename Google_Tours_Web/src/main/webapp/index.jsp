
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
    <title>Google Tours</title> 
    <script type="text/javascript" src="http://maps.google.com/maps?file=api&amp;&v=2&key=ABQIAAAAjU0EJWnWPMv7oQ-jjS7dYxSPW5CJgpdgO_s4yyMovOaVh_KvvhSfpvagV18eOyDWu7VytS6Bi1CWxw"></script> 
    <script type="text/javascript"> 
    
    // nepemeHHbIe
    var map;
    var myPano;   
    var panoClient;
    var houseMarker;
    var directions;
    var i;
    var v;
    var yaw;
    var yaw_pan;
    var vertices;
    var markers;
    var panoMetaData;
    var advanceTimer = null;
    var driving = false;
    // koopguHatbI 5 to4ek mapIIIpyta (A, B, C, D, E)
    var cityPoints =    [  
    [[48.85992225292772, 2.2681403160095215], [48.85560224934877, 2.314939498901367] ,[48.86064221727744, 2.325561046600342], [48.860148125211126, 2.3529624938964844], [48.85913169190895, 2.362189292907715]],
    [[48.85732817785907, 2.352168560028076], [48.856212860716944, 2.3465681076049805] ,[48.862604420477275, 2.324810028076172], [48.85380566751866, 2.312396764755249], [48.804722416109335, 2.123880386352539]],
    [[48.832894926647285, 2.316269874572754], [48.85615285877072, 2.297687530517578] ,[48.86277734477193, 2.335270643234253], [48.874337213533956, 2.2954022884368896], [48.88742882058753, 2.3397445678710938]],
    [[48.85584314172278, 2.348424196243286], [48.856212860716944, 2.3465681076049805]]
                        ];

    // co3gaHue o6bekta u3 to4ek cityPoints
    function changeToGLatLng(route, point) {
        return new GLatLng(cityPoints[route][point][0], cityPoints[route][point][1]);
    }
    
    // uHuLLuaJIu3aLLu9 npu 3anycke
    function initialize() {
          if (GBrowserIsCompatible()) {
              panoClient = new GStreetviewClient();      
              map = new GMap2(document.getElementById("map_canvas"));
              map.setCenter(new GLatLng(48.85771288591816, 2.344207763671875), 11);
              map.addControl(new GSmallMapControl());
              map.addControl(new GMapTypeControl());
              map.enableScrollWheelZoom();
			  
              directions = new GDirections(map);
              houseMarker = new GMarker(new GLatLng(48.85771288591816, 2.344207763671875), {draggable: false});
              
              myPano = new GStreetviewPanorama(document.getElementById("pano"));
              panoClient.getNearestPanorama(houseMarker.getLatLng(), showPanoData);
              
              GEvent.addListener(directions, "load", function() {
                handle();
              });
          }
    }
    
    function showPanoData(panoData) {
      if (panoData.code == 500) {
          setTimeout("move()", 300);
        } else if (panoData.code == 600) {
          setTimeout("move()", 300);
        } else {
      }
      myPano.setLocationAndPOV(panoData.location.latlng, {yaw: yaw, pitch: 0});
    }
    
    // nepega4a ynpaBJIeHu9 o6pa6ot4ukom co6bItuu npu load()
    function handle () {
        getVertices(directions.getPolyline());
    }
    
    function getVertices(path) {
        vertices = new Array ();
        for (var i = 0; i < path.getVertexCount(); i++) 
              if (! path.getVertex(i).equals(vertices[vertices.length - 1])) {
                vertices.push(path.getVertex(i));
              } 
    }
    
    // BbI4ucJIeHue yrJIa me)I(gy to4kamu
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
    
    // Show me!
    function drawRoute() { 
      if (driving) stopDrive();
      var route = changeTour();
      v=0;
      map.clearOverlays();
      
      var points = [];
      for (var k=0; k<cityPoints[route].length; k++)
        points.push(changeToGLatLng(route, k));
      directions.loadFromWaypoints(points);
      
      
      yaw = getBearing(vertices[0], vertices[1]);
      panoClient.getNearestPanorama(vertices[0], showPanoData);
      
      marker = new GMarker(vertices[0], {draggable: false});
      map.addOverlay(marker);
      
      document.getElementById("draw").disabled = true;
      document.getElementById("drive").disabled = false;
      
      
      markers = new Array();
      for (var i=0; i<vertices.length; i++) {
          markers[i] = new GMarker(vertices[i], {draggable: false});
          map.addOverlay(markers[i]);
      }
        
    }
    
    // Drive Me!
    function moveRoute() {
            
            document.getElementById("draw").disabled = true;
            document.getElementById("drive").disabled = false;
            document.getElementById("drive").value = 'Stop me!';
            document.getElementById("drive").setAttribute('onclick', 'stopDrive()');
            document.getElementById("drive").onclick = function() { stopDrive(); }
            
            driving = true;
            move();
    }
    
    function move() {
        if (!driving) stopDrive();
        
        var to4ka = myPano.getLatLng();
        var yaw_check = getBearing(to4ka, vertices[v+1]);
        
        if (getYawDelta(yaw_check, yaw) > 90) {
            for ( var w=v+2; w<vertices.length; w++)
                if (getYawDelta(yaw_check, yaw) < 90)
                    { v=w; break;}
        }
        yaw = getBearing(vertices[v], vertices[v+1]);
//        myPano.setPOV({yaw: yaw, pitch: 0});
        
		panoClient.getNearestPanorama(to4ka, function(svData) {
        if (svData.code == 500) {
         GLog.write('ERROR 500');
        } else if (svData.code == 600) {
        GLog.write('ERROR 600');
        } else {
		  for (var i = 0; i < svData.links.length; i++) {
                    var d = getYawDelta(yaw, svData.links[i].yaw);
                    if (d<15) {
                        yaw_pan = svData.links[i].yaw;
                        break;}
        }
		myPano.panTo({yaw: yaw_pan, pitch: 0});
		setTimeout("myPano.followLink(" + yaw_pan + ")", 1500);
      }});
	  
        map.panTo(to4ka);
//        myPano.panTo({yaw: yaw, pitch: 0});
//        setTimeout("myPano.followLink(" + yaw + ")", 1000);
        marker.setLatLng(to4ka);
        
        if (to4ka.distanceFrom(vertices[v+1]) < 10)
        {    
            yaw = getBearing(vertices[v+1], vertices[v+2]);
//            panoClient.getNearestPanorama(vertices[v+1], showPanoData);
            for (var j=v+1; j<vertices.length; j++)
            { 
                if (to4ka.distanceFrom(vertices[j]) < to4ka.distanceFrom(vertices[j+1]))
                v++; break;
            }
        }    
        advanceTimer = setTimeout("move()", 3000);
    }
    
    // Stop Me!
    function stopDrive () {
        driving = false;
        if (advanceTimer != null) {
        clearTimeout(advanceTimer);
        advanceTimer = null;
        }
        
        document.getElementById("draw").disabled = false;
        document.getElementById("drive").value = 'Drive me!'
        document.getElementById("drive").setAttribute('onclick', 'moveRoute()');
        document.getElementById("drive").onclick = function() { moveRoute(); }
    }
    
    // cmeHa mapIIIpyta
    function changeTour() {
        document.getElementById("draw").disabled = false;
        
        var nomer = document.getElementById("country").value;
        var routeValue;

        if (nomer == 1)       routeValue = 0
        else if (nomer == 2)  routeValue = 1
        else if (nomer == 3)  routeValue = 2
        else routeValue = 3;
        
        
/*        switch (nomer) {
            case 1: routeValue = 0; break;
            case 2: routeValue = 1; break;
            case 3: routeValue = 2; break;
            default: routeValue = 3; break;
        }*/
        return routeValue;
    } 
    
    // pa3Hoctb me)I(gy yrJIamu
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
    
    // npototunbI
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
  <body onload="initialize()" onunload="GUnload()"> 
    <div name="pano" id="pano" style="width: 700px; height: 350px"></div>  
    <div id="map_canvas" style="width: 700px; height: 300px"></div> 
    <b>Choose Tour:</b><br>
    <select id="country" onchange="changeTour()">
    <option value="1">Sights
    <option value="2">Impressionism
    <option value="3">French Revolution
    <option value="4">test
    </select>  
    <input type="button" value="Show Me!" id="draw"  onclick="drawRoute()" />
    <input type="button" value="Drive Me!" id="drive"  onclick="moveRoute()" disabled/> <br><br>
    <a href="http://int-see.yotatop.ru:8001/identity/authorize?response_type=code&client_id=ca30f3c5b1f52665ce909434e2ffae31&redirect_uri=http://localhost:8080/Google_Tours_Web-0.1-SNAPSHOT">Login</a>
  </body> 
</html> 	