/**
 * 
 */
package au.com.BI.Messaging;
import au.com.BI.Messaging.AddressBook.Locations;

/**
 * @author colin
 *
 */
public class AddressDetails {
	Locations currentLocation = Locations.NOT_CONNECTED;
	String user = "";
	String password = "";
	String jabber_id = "";
	String jabber_server = "";
	String mobile_number = "";
	
	public Locations getCurrentLocation() {
		return currentLocation;
	}
	public void setCurrentLocation(Locations currentLocation) {
		this.currentLocation = currentLocation;
	}
	public String getJabber_id() {
		return jabber_id;
	}
	public void setJabber_id(String jabber_id) {
		this.jabber_id = jabber_id;
	}
	public String getJabber_server() {
		return jabber_server;
	}
	public void setJabber_server(String jabber_server) {
		this.jabber_server = jabber_server;
	}
	public String getMobile_number() {
		return mobile_number;
	}
	public void setMobile_number(String mobile_number) {
		this.mobile_number = mobile_number;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getUser() {
		return user;
	}
	public void setUser(String user) {
		this.user = user;
	}
}
