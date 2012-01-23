package webapp.dbi;

import java.io.Serializable;

public class RouteValues implements Serializable {
 private Long id;
 private Long pos;
 private double x;
 private double y;
  
 public Long getId() {
  return id;
 }
 public void setId(Long id) {
  this.id = id;
 }
 public Long getPos() {
  return pos;
 }
 public void setPos(Long pos) {
  this.pos = pos;
 }
 public double getX() {
  return x;
 }
 public void setX(double x) {
  this.x = x;
 }
 public double getY() {
  return y;
 }
 public void setY(double y) {
  this.y = y;
 }
}