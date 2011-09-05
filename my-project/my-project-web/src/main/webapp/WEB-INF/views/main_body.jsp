<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<script type="text/javascript">
 $(document).ready(function(){
	var handler = function(){
		$('a#charge').unbind();
		$('a#charge').css('color', '#808080');
		$('#charge-status-msg').empty().text("Please wait...");
	    $.ajax( {
	        url: "http://${serverHost}:${serverPort}/demo/pay",
	        dataType: "json",
	        success: function(json) {
	            $('#charge-status-msg').empty().text("The last payment has successfully passed! Transaction identifier is "+json.transactionId);
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
		<p><a href="#" id="charge">[ Watch with Quality ]</a></p>
	</div>
</c:if>