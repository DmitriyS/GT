<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<script type="text/javascript" src="../static/js/jquery.oauthpopup.js"></script>
<div id="menu">    
    <!-- !!! If user not logged in: -->    
    <c:if test="${empty user}">                
        <!--a href="${identityLocation}/rest/1/identity/authorize?response_type=code&providerId=yota&client_id=${apiKey}&redirect_uri=${redirect_uri}">Login</a-->
        <script>
            $(document).ready(function(){
                $('#oauthlogin').click(function(){
                    $.oauthpopup({
                        path: '${identityLocation}/rest/1/identity/authorize?response_type=code&providerId=yota&client_id=${apiKey}&redirect_uri=${redirect_uri}',
                        callback: function(){
                            window.location.reload();
                        }
                    });
                });
            });
        </script>
        <a class="button" id="oauthlogin" href="#">Login</a>
        <a href="https://my.yota.ru/selfcare/registration" target="_blank">Register</a>
    </c:if>    
    <!-- !!! If user logged in: -->
    <c:if test="${not empty user}">    
    	<a href="<%=request.getContextPath()%>/demo/main">Home</a>
        <a href="<%=request.getContextPath()%>/demo/logout">Logout</a>
        <!--a href='javascript:getTransactions()' style="float:right;">${userName}</a-->
        <!--a href="<%=request.getContextPath()%>/demo/profile" style="float:right;">${userName}</a-->
        <a href="javascript:openWindow('<%=request.getContextPath()%>/demo/profile')" style="float:right;">${userName} Profile</a>
    </c:if>    

</div>