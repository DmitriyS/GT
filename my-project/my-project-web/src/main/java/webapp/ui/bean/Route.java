package webapp.ui.bean;

import java.util.HashSet;
import java.util.Set;

public class Route {

    private Long id;
    private String description;
    private Set users = new HashSet();
    private double cost;

    public Route() {
    }

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

    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }
}