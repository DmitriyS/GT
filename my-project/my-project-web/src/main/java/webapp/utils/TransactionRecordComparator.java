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
package webapp.utils;

import java.util.Comparator;

import com.yota.top.sdk.model.payment.TransactionRecord;

/**
 * {@link TransactionRecordComparator} 
 *
 */
public class TransactionRecordComparator 
implements Comparator<TransactionRecord> {

	/* (non-Javadoc)
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(TransactionRecord tr1, TransactionRecord tr2) {
		return tr1.getCompleteTime().getTime() < tr2.getCompleteTime().getTime() ? -1 :
			(tr1.getCompleteTime().getTime() > tr2.getCompleteTime().getTime() ? 1 : 0);
	}

}
