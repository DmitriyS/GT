<!--
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
-->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title><tiles:getAsString name="title" ignore="true" /></title>
                
        <script type="text/javascript" src="../static/js/jquery-1.6.2.min.js"></script>               
        <link rel="stylesheet" type="text/css" href="../static/styles/style.css"/>
    </head>
    <body>
        <div id="container">

            <div id="head">
                <tiles:insertAttribute name="header" />
            </div>

            <div id="body">
                <tiles:insertAttribute name="body" />
            </div>

            <div id="footer">
                <tiles:insertAttribute name="footer" />
            </div>
        </div>

    </body>
</html>
