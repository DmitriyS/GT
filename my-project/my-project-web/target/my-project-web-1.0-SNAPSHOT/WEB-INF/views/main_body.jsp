<!--
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript">
   
$(document).ready(function(){
	var handler = function(){
                var nomer = document.getElementById("country").value;
		$('a#charge').unbind();
		$('a#charge').css('color', '#808080');
		$('#charge-status-msg').empty().text("Please wait...");
	    $.ajax( { 
	        url: "http://${serverHost}:${serverPort}/demo/pay?nomer="+nomer,
	        dataType: "json",
	        success: function(json) { 
	            $('#charge-status-msg').empty().text("You have bought a new route! - " + json);
	        },
	        error: function() {                 
	            $('#charge-status-msg').empty().text("The last payment has failed, please try again later.");
	        },
	        complete: function(){
	        	$('a#charge').bind('click', handler);
	        	$('a#charge').css('color', '#0099FF');
	        }
	    });    
	};
	$('a#charge').bind('click', handler);
});
</script>

</p>
<c:if test="${not empty user}">
	<div id="pay">
		<p id="charge-status-msg" class="info-msg"></p> 
		<p><a href="" id="charge">Buy!</a></p>  
</c:if>
-->