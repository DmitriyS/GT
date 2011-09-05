<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<c:if test="${not empty profile}">
	<div id="profile">
		<p>Balance: ${profile.balance} RUB</p>
		<p>Purchases History:</p>
		<table id="payment-history" cellspacing=0 cellpadding=0>
			<tr>
				<th>Date</th>
				<th>Purchase</th>
				<th>Amount</th>
			</tr>
			<c:forEach var="record"
				items="${profile.transactionHistory}">
				<tr>
					<td><fmt:formatDate value="${record.completeTime}"
						pattern="dd.MM.yyyy hh:mm:ss" /></td>
					<td>${record.description}</td>
					<td>${record.amount} ${record.currency}</td>
				</tr>
			</c:forEach>
		</table>
	</div>
</c:if>
<c:if test="${empty profile}">
	<span class="info-msg">${errorMsg}</span>
</c:if>

