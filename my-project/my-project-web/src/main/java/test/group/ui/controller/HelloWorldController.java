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
package test.group.ui.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import com.yota.top.sdk.IdentityServiceClient;
import com.yota.top.sdk.PaymentServiceClient;
import com.yota.top.sdk.TopApiException;
import com.yota.top.sdk.impl.IdentityServiceClientImpl;
import com.yota.top.sdk.impl.PaymentServiceClientImpl;
import com.yota.top.sdk.model.payment.GetAccountTransactionHistoryResponse.Transactions;
import com.yota.top.sdk.model.payment.TransactionInfo;
import test.group.ui.bean.User;
import test.group.ui.bean.UserProfile;
import test.group.utils.TransactionRecordComparator;

import java.util.*;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import java.sql.*;
import java.sql.SQLException;

/**
 * @author EDemyanchik
 * {@link HelloWorldController} is intended to handle requests from Hello World application. 
 * 
 */
@Controller
@RequestMapping("/")
public class HelloWorldController {

    /**
     * API key provided by platform 
     */
    private static final String API_KEY = "ca30f3c5b1f52665ce909434e2ffae31";
    
    /**
     * API secret provided by platform
     */
    private static final String API_SECRET = "2370936af24a64fd";
    
    /**
     * The login page URL provided by platform
     */
    private static final String IDENTITY_PAGE_LOCATION = "https://api.yotatop.ru";
       
    /**
     * The platform URL used to call payment API
     */
    private static final String PAYMENT_URL = "https://api.yotatop.ru";
    
    /**
     * The platform URL used to call identity API
     */
    private static final String IDENTITY_URL = "https://api.yotatop.ru";

    /**
     * The name of authorization code parameter
     */
    private static final String REQUEST_PARAM_CODE = "code";
    
    /**
     * The name of redirect URI request parameter
     */
    private static final String REQUEST_PARAM_REDIRECT_URI = "redirect_uri";

    /**
     * The name of session attribute which defines server host where Hello World application is deployed 
     */
    private static final String SESSION_ATTR_SERVER_HOST = "serverHost";
    
    /**
     * The name of session attribute which defines server port where Hello World application is deployed 
     */    
    private static final String SESSION_ATTR_SERVER_PORT = "serverPort";
       
    /**
     * The name of session attribute which defines the login page URL provided by platform
     */   
    private static final String SESSION_ATTR_IDENTITY_PAGE_LOCATION = "identityLocation";
    
    /**
     * The name of session attribute which defines API key provided by platform
     */
    private static final String SESSION_ATTR_API_KEY = "apiKey";
    
    /**
     * The name of session attribute which defines current user logged in Hello World application
     */
    private static final String SESSION_ATTR_USER = "user";

    /**
     * URN of HelloWorld login handler
     */
    private static final String LOGIN_PAGE = "/demo/login";

    /**
     * The name of main view
     */
    private static final String MAIN_VIEW = "main";
    
    /**
     * The name of profile view
     */
    private static final String PROFILE_VIEW = "profile";

    ArrayList ls = new ArrayList();
    
    private String url_db = "jdbc:postgresql://localhost:5432/";
    private String username_db = "postgres";
    private String password_db = "IeatH@mster5";

    private static final PaymentServiceClient paymentServiceClient = 
	new PaymentServiceClientImpl(PAYMENT_URL, API_KEY, API_SECRET);
    private static IdentityServiceClient identityServiceClient = 
	new IdentityServiceClientImpl(IDENTITY_URL, API_KEY, API_SECRET);

    @RequestMapping("/main")
    public ModelAndView main(HttpServletRequest req, HttpServletResponse res) {

	final String url = req.getRequestURL().toString();
	final String uri = req.getRequestURI();
	final String redirectUri = url.replace(uri, req.getContextPath() + LOGIN_PAGE);

	req.getSession().setAttribute(REQUEST_PARAM_REDIRECT_URI, redirectUri);
	req.getSession().setAttribute(SESSION_ATTR_SERVER_HOST, req.getServerName());
	req.getSession().setAttribute(SESSION_ATTR_SERVER_PORT, req.getServerPort());

	req.getSession().setAttribute(SESSION_ATTR_API_KEY, API_KEY);
	req.getSession().setAttribute(SESSION_ATTR_IDENTITY_PAGE_LOCATION, IDENTITY_PAGE_LOCATION);

	return new ModelAndView(MAIN_VIEW);
    }

    @RequestMapping("/profile")
    public ModelAndView balance(HttpServletRequest req) {
	try {
	    final User currentUser = getCurrentUser(req);

	    if (currentUser == null) {
		return new ModelAndView(new RedirectView(MAIN_VIEW));
	    }

	    final UserProfile userProfile = new UserProfile();
	    final Double balance = paymentServiceClient.getBalance(currentUser.getAccessToken());
	    final List<Transactions> transactionHistory = paymentServiceClient.getTransactionHistory(
		    currentUser.getAccessToken(), null, null);
	    Collections.sort(transactionHistory, new TransactionRecordComparator());
	    userProfile.setBalance(Double.toString(balance));
	    userProfile.setTransactionHistory(transactionHistory);
	    return new ModelAndView(PROFILE_VIEW, "profile", userProfile);
	} catch (TopApiException ex) {
	    return new ModelAndView(PROFILE_VIEW, "errorMsg", ex.getMessage());
	}
    }
    
    @RequestMapping("/login")
    public ModelAndView login(@RequestParam(required = false, 
            value = REQUEST_PARAM_CODE) String code,
	    HttpServletRequest req, HttpServletResponse res) 
            throws TopApiException, SQLException {
	final String redirectUri = 
             (String) req.getSession().getAttribute(REQUEST_PARAM_REDIRECT_URI);	
	if (code != null && redirectUri != null) {
	    final String accessToken = 
                    identityServiceClient.getAccessToken(redirectUri, code);
	    final String uid = 
                    identityServiceClient.validateAccessToken(accessToken);
	    final User user = new User(uid, accessToken);
	    req.getSession().setAttribute(SESSION_ATTR_USER, user);
	}
        
        Statement st = connectDB(); 
        ResultSet rs = st.executeQuery("select * from users where uid = 'user1';"); // user1 will be defined later
        String mas[] = new String[4];
        while (rs.next())
             for (int i=0; i<4; i++) {
                 mas[i] = rs.getString(i+2);
                 if ("1".equals(mas[i]))
                    ls.add(i+2); 
             } 
        
        return new ModelAndView(new RedirectView(MAIN_VIEW));
    }

    @RequestMapping("/logout")
    public ModelAndView logout(HttpServletRequest req) {
	final HttpSession session = req.getSession(false);
	if (session != null) {
	    session.invalidate();
	}
	return new ModelAndView(new RedirectView(MAIN_VIEW));
    }

    @RequestMapping("/pay")
    public @ResponseBody
            TransactionInfo pay(@RequestParam(required = false, value = "nomer") String nomer,
            HttpServletRequest req, HttpServletResponse res) 
            throws IOException, TopApiException, SQLException {
       
        final User user = getCurrentUser(req);
	final TransactionInfo transactionInfo = paymentServiceClient.chargeAmount(user.getAccessToken(), "10.00",
		"Description", "Refcode");
        
        Statement st = connectDB(); 
        st.executeQuery("update users set " + nomer + " = 1 where uid = 'user1';"); // 'user1' will be defined later
        ls.add(nomer);
        return transactionInfo;
    }
    
    @RequestMapping("/check")
    public @ResponseBody
            boolean check(@RequestParam(required = false, value = "nomer") String nomer,
            HttpServletRequest req, HttpServletResponse res) 
            throws IOException {
        if (ls.contains(nomer))
                return true;
        return false;
    }
    
    public Statement connectDB() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver").newInstance();
        } catch (Exception x) {
            System.out.println("Unable to load the driver class!");
            System.out.println(x.getMessage());
        }
        
        Connection con = DriverManager.getConnection(url_db, username_db, password_db);
        Statement st = con.createStatement();
        
        return st;
    }

    private User getCurrentUser(HttpServletRequest req) {
	final Object userObj = req.getSession().getAttribute(SESSION_ATTR_USER);

	if (!(userObj instanceof User)) {
	    return null;
	} else {
	    return (User) userObj;
	}
    }

    @ExceptionHandler(TopApiException.class)
    public @ResponseBody
    com.yota.top.sdk.model.common.ErrorResponse handleTopApiException(TopApiException e, HttpServletRequest request,
	    HttpServletResponse response) {
	response.setStatus(e.getHttpStatus().getStatusCode());
	return e.getError();
    }
}
