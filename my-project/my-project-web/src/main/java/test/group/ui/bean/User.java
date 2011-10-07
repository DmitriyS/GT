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

import java.util.HashSet;
import java.util.Set;
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
    private Long id;
    private String accessToken;
    private String firstName;
    private String lastName;
    private String email;
    private Set routes = new HashSet();

    public User() {
    }

    public User(Long id, String accessToken) {
        this.id = id;
        this.accessToken = accessToken;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    protected Set getRoutes() {
        return routes;
    }

    protected void setRoutes(Set routes) {
        this.routes = routes;
    }

    public void addToRoute(Route route) {
        this.getRoutes().add(route);
        route.getUsers().add(this);
    }

    public void removeFromRoute(Route route) {
        this.getRoutes().remove(route);
        route.getUsers().remove(this);
    }
}
