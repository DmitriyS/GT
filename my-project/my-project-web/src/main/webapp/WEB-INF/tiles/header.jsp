<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="menu">    
    <!-- !!! If user not logged in: -->    
    <c:if test="${empty user}">                
        <a href="${identityLocation}/rest/1/identity/authorize?response_type=code&providerId=yota&client_id=${apiKey}&redirect_uri=${redirect_uri}">Login</a>
        <a href="https://my.yota.ru/selfcare/registration" target="_blank">Register</a>
    </c:if>    
    <!-- !!! If user logged in: -->
    <c:if test="${not empty user}">    
    	<a href="<%=request.getContextPath()%>/demo/main">Home</a>
        <a href="<%=request.getContextPath()%>/demo/profile">My profile</a>
        <a href="<%=request.getContextPath()%>/demo/logout">Logout</a>        
    </c:if>    

</div>