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
package webapp.ui.controller;

import com.yota.top.sdk.model.subscriber.SubscriberProfile;
import java.math.BigDecimal;
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
import com.yota.top.sdk.QoSServiceClient;
import com.yota.top.sdk.SubscriberInfoServiceClient;
import com.yota.top.sdk.TopApiException;
import com.yota.top.sdk.impl.IdentityServiceClientImpl;
import com.yota.top.sdk.impl.PaymentServiceClientImpl;
import com.yota.top.sdk.impl.QoSServiceClientImpl;
import com.yota.top.sdk.impl.SubscriberInfoServiceClientImpl;
import com.yota.top.sdk.model.payment.TransactionRecord;
import com.yota.top.sdk.model.payment.TransactionInfo;
import com.yota.top.sdk.model.qos.CallbackReference;
import com.yota.top.sdk.model.qos.MediaProperty;
import com.yota.top.sdk.model.qos.ProtocolType;
import com.yota.top.sdk.model.qos.QosFeatureData;
import com.yota.top.sdk.model.qos.QosFeatureProperties;
import java.io.FileInputStream;
import webapp.ui.bean.*;
import webapp.utils.TransactionRecordComparator;

import java.util.*;

import java.io.IOException;

import webapp.dbi.*;

import java.util.Iterator;
import java.util.List;
import org.hibernate.Session;
import org.hibernate.Transaction;

/**
 * @author EDemyanchik
 * {@link WebAppController} is intended to handle requests from Hello World application. 
 * 
 */
@Controller
@RequestMapping("/")
public class WebAppController {
    
    private static final String fName = "src/main/resources/cfgFile.properties";
    private static final Properties properties = readProps();
    
    private static final String API_KEY = properties.getProperty("apiKey", "ca30f3c5b1f52665ce909434e2ffae31");
    private static final String API_SECRET = properties.getProperty("apiSecret", "2370936af24a64fd");
    
    private static final String IDENTITY_PAGE_LOCATION = properties.getProperty("identity_page_location");
    private static final String PAYMENT_URL = properties.getProperty("payment_url");
    private static final String IDENTITY_URL = properties.getProperty("identity_url");
    private static final String SUBSCRIBER_URL = properties.getProperty("subscriber_url");
    private static final String QOS_URL = properties.getProperty("qos_url");
    
    private static final String LOGIN_PAGE = properties.getProperty("login_page");
    private static final String MAIN_VIEW = properties.getProperty("main_view");
    private static final String PROFILE_VIEW = properties.getProperty("profile_view");
    
    private static final String REQUEST_PARAM_CODE = "code";
    private static final String REQUEST_PARAM_REDIRECT_URI = "redirect_uri";

    private static final String SESSION_ATTR_SERVER_HOST = "serverHost";
    private static final String SESSION_ATTR_SERVER_PORT = "serverPort";
    private static final String SESSION_ATTR_IDENTITY_PAGE_LOCATION = "identityLocation";
    private static final String SESSION_ATTR_API_KEY = "apiKey";
    private static final String SESSION_ATTR_USER = "user";
    private static final String USER_NAME = "userName";
    
    private String sfId = null;
    
    private static final PaymentServiceClient paymentServiceClient = 
	new PaymentServiceClientImpl(PAYMENT_URL, API_KEY, API_SECRET);
    private static final IdentityServiceClient identityServiceClient = 
	new IdentityServiceClientImpl(IDENTITY_URL, API_KEY, API_SECRET);
    private static final SubscriberInfoServiceClient subscriberInfoServiceClient = 
	new SubscriberInfoServiceClientImpl(SUBSCRIBER_URL, API_KEY, API_SECRET);
    private final QoSServiceClient qosServiceClient = 
            new QoSServiceClientImpl(QOS_URL, API_KEY, API_SECRET);

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
	    final BigDecimal balance = paymentServiceClient.getBalance(currentUser.getAccessToken());
	    final List<TransactionRecord> transactionHistory = paymentServiceClient.getTransactionHistory(
		    currentUser.getAccessToken(), null, null);
	    Collections.sort(transactionHistory, new TransactionRecordComparator());
	    userProfile.setBalance(balance.toString());
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
            throws TopApiException, InterruptedException {
	final String redirectUri = 
             (String) req.getSession().getAttribute(REQUEST_PARAM_REDIRECT_URI);	
	if (code != null && redirectUri != null) {
	    final String accessToken = 
                    identityServiceClient.getAccessToken(redirectUri, code);
		System.out.println("!!! " + accessToken + " !!!");			
	    final Long id = Long.parseLong(
                    identityServiceClient.validateAccessToken(accessToken));
            final SubscriberProfile profile = 
                    subscriberInfoServiceClient.getSubscriberInfo(accessToken);
            String firstname = profile.getFirstName();
            String lastname = profile.getLastName();
	    String email = profile.getEmail();
            final User user = new User(id, accessToken);
	    req.getSession().setAttribute(SESSION_ATTR_USER, user);
            req.getSession().setAttribute(USER_NAME, firstname);
            storeToDB(id, firstname, lastname, email);
	}
        return new ModelAndView("close_window");
    }
    
    public void storeToDB(Long id, String name, String surname, String email) {
        Transaction trns = null;
        Session session = HibernateUtil.getSessionFactory().openSession();
        try {
            trns = session.beginTransaction();
            List<User> u = session.createQuery("from User").
                    list();
            for (Iterator<User> iter = u.iterator(); iter.hasNext();) {
                User compare = iter.next();
                if (compare.getId().equals(id)){
                    return;
                }
            }    
            User user = new User();
            user.setId(id); 
            user.setFirstName(name);
            user.setLastName(surname);
            user.setEmail(email);
            session.save(user);
            trns.commit();
            
            trns = session.beginTransaction();
            List<Route> r = session.createQuery("from Route where cost = 0").
                    list();
            for (Iterator<Route> iter = r.iterator(); iter.hasNext();) {
                Route route = iter.next();
                addRoute(id, route.getId());
            }    
            trns.commit();
        } catch (RuntimeException e) {
            if (trns != null) {
                trns.rollback();
            }
            e.printStackTrace();
        } finally {
            session.flush();
            session.close();
        }
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
            TransactionInfo pay(@RequestParam(required = false, value = "id") String routeId,
            HttpServletRequest req, HttpServletResponse res) 
            throws IOException, TopApiException {
        final User user = getCurrentUser(req);
        Long id = user.getId();
        Long route = Long.parseLong(routeId);
        addRoute(id, route);
        ArrayList array = getDescription(route);
        String description = array.get(0).toString();
        String amount = array.get(1).toString();
	final TransactionInfo transactionInfo = paymentServiceClient.chargeAmount(user.getAccessToken(), amount,
		description, "Refcode");
        return transactionInfo;
    }
    
    private void addRoute (Long idUser, Long idRoute) {
        Transaction trns = null;
        Session session = HibernateUtil.getSessionFactory().openSession();
        try {
           trns = session.beginTransaction();
           
           User someUser = (User) session.load(User.class, idUser);
           Route someRoute = (Route) session.load(Route.class, idRoute);
           someRoute.addToUser(someUser);
           
           trns.commit();
      } catch (RuntimeException e) {
           if(trns != null){
            trns.rollback();
           }
           e.printStackTrace();
      } finally{
           session.flush();
           session.close();
      } 
    }
    
    private ArrayList getDescription(Long id) {
        Transaction trns = null;
        Session session = HibernateUtil.getSessionFactory().openSession();
        ArrayList desc = new ArrayList();
        try {
           trns = session.beginTransaction();
           
           List<Route> query = session.createQuery ("from Route as r where r.id = :id")
                   .setLong("id", id)
                   .list();
           trns.commit();
           desc.add(query.iterator().next().getDescription());
           desc.add(query.iterator().next().getCost());
      } catch (RuntimeException e) {
           if(trns != null){
            trns.rollback();
           }
           e.printStackTrace();
      } finally{
           session.flush();
           session.close();
           return desc;
      } 
    }
    
    @RequestMapping("/loadPoints")
    public @ResponseBody
            ArrayList load(@RequestParam(required = false, value = "route") String route,
            HttpServletRequest req, HttpServletResponse res) 
            throws IOException {
        Long nomer = Long.parseLong(route);
        return getXY(nomer);
    }
    
    private ArrayList getXY(Long id) {
      ArrayList points = new ArrayList();
      Transaction trns = null;
      Session session = HibernateUtil.getSessionFactory().openSession();
      try {
       trns = session.beginTransaction();
       List<RouteValues> rvs = session.createQuery("from RouteValues as r where r.id = :id")
       .setLong( "id", id )
       .list();
       for (Iterator<RouteValues> iter = rvs.iterator(); iter.hasNext();) {
            RouteValues rv = iter.next();
            points.add(rv.getX()); points.add(rv.getY());
       }
       trns.commit();
      } catch (RuntimeException e) {
       if(trns != null){
        trns.rollback();
       }
       e.printStackTrace();
      } finally{
       session.flush();
       session.close();
       return points;
      } 
    }
    
    @RequestMapping("/getAllRoutes")
    public @ResponseBody
            ArrayList getRoutes(HttpServletRequest req, HttpServletResponse res)
            throws IOException, TopApiException {
        ArrayList data = new ArrayList();
        Transaction trns = null;
        Session session = HibernateUtil.getSessionFactory().openSession();
        try {
           trns = session.beginTransaction();
           List<Route> routes = session.createQuery("from Route")
           .list();
           for (Iterator<Route> iter = routes.iterator(); iter.hasNext();) {
                Route route = iter.next();
                data.add(route.getId());
                data.add(route.getDescription());
                data.add(route.getCost());
           }
           trns.commit();
        } catch (RuntimeException e) {
           if(trns != null){
            trns.rollback();
           }
           e.printStackTrace();
        } finally{
           session.flush();
           session.close();
           return data;
        } 
    }
    
   @RequestMapping("/checkRoute")
    public @ResponseBody
            boolean checkRoute(@RequestParam(required = false, value = "routeId") String routeId,
            HttpServletRequest req, HttpServletResponse res)
            throws IOException, TopApiException {
        Transaction trns = null;
        Session session = HibernateUtil.getSessionFactory().openSession();
        final User user = getCurrentUser(req);
        boolean flag = false;
        Long route = Long.parseLong(routeId);
        if (user == null) {
            try {
               trns = session.beginTransaction();
               List<Route> routes = session.createQuery("from Route where cost = 0")
               .list();
               for (Iterator<Route> iter = routes.iterator(); iter.hasNext();) {
                    Route r = iter.next();
                    if (r.getId().equals(route)){
                        flag = true; break;
                    }
               }
               trns.commit();
            } catch (RuntimeException e) {
               if(trns != null){
                trns.rollback();
               }
               e.printStackTrace();
            } finally{
               session.flush();
               session.close();
               return flag;
            }
        }
        else {
            Long id = user.getId();
            try {
               trns = session.beginTransaction();
               List<UserRoutes> routes = session.createQuery("from UserRoutes where uid = :id)")
               .setLong( "id", id )
               .list();
               for (Iterator<UserRoutes> iter = routes.iterator(); iter.hasNext();) {
                    UserRoutes compare = iter.next();
                    if (compare.getRid().equals(route)){
                        flag = true; break;
                    }
               }
               trns.commit();
            } catch (RuntimeException e) {
               if(trns != null){
                trns.rollback();
               }
               e.printStackTrace();
            } finally{
               session.flush();
               session.close();
               return flag;
            }
        }    
    }

    @RequestMapping("/qos")
    public @ResponseBody
            void applyQos(HttpServletRequest req) throws TopApiException {
        if (sfId != null) {
            qosServiceClient.removeQoSFeature(sfId);
            sfId = null;
            return;
        }
        
        String inIp = "10.0.0.1";
        String inPort = "8888";
        String outIp = "10.0.0.2";
        String outPort = "9999";
	QosFeatureProperties qosFeatureProperties = new QosFeatureProperties();
        MediaProperty mediaProperty = new MediaProperty();
        mediaProperty.setInIp(inIp);
        mediaProperty.setInPort(inPort);
        mediaProperty.setOutIp(outIp);
        mediaProperty.setOutPort(outPort);
        mediaProperty.setProtocolType(ProtocolType.RTCP);

        qosFeatureProperties.setDuration(100);
        qosFeatureProperties.setMaxDBw(300);
        qosFeatureProperties.setMaxUBw(200);
        qosFeatureProperties.getMediaProps().add(mediaProperty);

        CallbackReference qosNotificationCallback = new CallbackReference();
        qosNotificationCallback.setCallbackData("Callback Data");
//        qosNotificationCallback.setApiKey(API_KEY);
        qosNotificationCallback.setNotifyURL("http://10.2.177.116:8888/qos_notification");
        qosNotificationCallback.setOrigNotifyURL("http://nofity.url");
        
        QosFeatureData resp = 
                qosServiceClient.applyQoSFeature("10.2.172.30", "QoSVideo", qosFeatureProperties, qosNotificationCallback);

        sfId = resp.getSfId();
        
        return;
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


    private static Properties readProps() {
        Properties props = new Properties();
        try {
            FileInputStream iFile = new FileInputStream(fName);
            props.load(iFile);
        } catch (IOException ex) {
            throw new IOException("[readProp]" + ex.getMessage());
        }
        finally {
            return props;
        }
    }
}