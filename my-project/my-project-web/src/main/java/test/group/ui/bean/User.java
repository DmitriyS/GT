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

/**
 * @author EDemyanchik
 * @{link User} bean
 * 
 */
public class User implements Serializable {
    /**
     * Serial version identifier
     */
    private static final long serialVersionUID = 1L;

    private String uid;
    private String accessToken;

    
    
    public User() {
    }

    public User(String uid, String accessToken) {
	this.uid = uid;
	this.accessToken = accessToken;
    }

    public String getUid() {
	return uid;
    }

    public void setUid(String uid) {
	this.uid = uid;
    }

    public String getAccessToken() {
	return accessToken;
    }

    public void setAccessToken(String accessToken) {
	this.accessToken = accessToken;
    }
}
