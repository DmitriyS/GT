package test.group.ui.bean;

import java.io.Serializable;

public class UserRoutes implements Serializable {
 private Long uid;
 private Long rid;
 
 public UserRoutes () {
 } 
 public Long getUid() {
  return uid;
 }
 public void setUid(Long uid) {
  this.uid = uid;
 }
 public Long getRid() {
  return rid;
 }
 public void setRid(Long rid) {
  this.rid = rid;
 }
}