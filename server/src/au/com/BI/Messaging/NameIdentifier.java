/**
 * 
 */
package au.com.BI.Messaging;

/**
 * @author colin
 *
 */
public class NameIdentifier {
	String clientName = "";
	String userName = "";
	
	public NameIdentifier (String clientName, String userName){
		this.setClientName(clientName);
		this.setUserName(userName);
	}
	
	public String getClientName() {
		return clientName;
	}
	public void setClientName(String clientName) {
		this.clientName = clientName;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
}
