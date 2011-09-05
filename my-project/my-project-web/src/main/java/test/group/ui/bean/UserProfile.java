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
package test.group.ui.bean;

import java.io.Serializable;
import java.util.List;

import com.yota.top.sdk.model.payment.GetAccountTransactionHistoryResponse.Transactions;

/**
 * @author EDemyanchik
 * {@link UserProfile} bean
 *
 */
public class UserProfile implements Serializable {
	/**
	 * Serial version identifier
	 */
	private static final long serialVersionUID = 1L;
	
	private String balance;
	private List<Transactions> transactionHistory;
	
	public String getBalance() {
		return balance;
	}
	public void setBalance(String balance) {
		this.balance = balance;
	}
	public List<Transactions> getTransactionHistory() {
		return transactionHistory;
	}
	public void setTransactionHistory(List<Transactions> transactionHistory) {
		this.transactionHistory = transactionHistory;
	}
	
}
