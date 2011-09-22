package test.group.ui.bean;

import java.util.HashSet;
import java.util.Set;

public class Route {
 private Long id;
 private String description;
 private Set users = new HashSet();
  
 public Route() {}
 
 public Long getId() {
        return id;
 }
 public void setId(Long id) {
        this.id = id;
 }
 public String getDescription() {
  return description;
 }
 public void setDescription(String description) {
  this.description = description;
 }
 protected Set getUsers() {
  return users;
 }
 protected void setUsers(Set users) {
  this.users = users;
 }
 public void addToUser(User user) {
     this.getUsers().add(user);
     user.getRoutes().add(this);
 }
 public void removeFromUser(User user) {
     this.getUsers().remove(user);
     user.getRoutes().remove(this);
 }
}