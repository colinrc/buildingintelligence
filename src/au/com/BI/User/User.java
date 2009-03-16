/*
 * Created on Jan 29, 2004
 *
 */
package au.com.BI.User;

/**
 * @author Colin Canfield
 * This package handles users for the automation system.
 * The User class is the primary representation of the user
 *
 **/
public class User
{
	String currentUser;
	String password;
	
	/**
	 * Before a specific login the generic user is created
	 *
	 */
	public User () {
	}
	
	public User (String username) {
		setUser (username);
	}

	public User (String username,String password) {
		setUser (username);
		setPassword (password);
	}
	
	
	public void setPassword (String password)
	{
		this.password = password;
	}
	
	public void setUser (String username) {
		this.currentUser = username;
	}
	
	public boolean checkPassword (String username, String password) {
		return true;
	}
	
	/**
	 * True if the current user can do the command code
	 * @param command
	 * @return
	 */
	public boolean canUserDoCommand (au.com.BI.Command.Command command){
		return true;
	}
	
	public String getUser ()
	{
		return currentUser;
	}
	
	public String getPassword () 
	{
		return password;
	}
}
