package au.com.BI.Jetty;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Date;
import java.util.Properties;

import org.eclipse.jetty.http.security.Credential;
import org.eclipse.jetty.http.security.UnixCrypt;
import org.eclipse.jetty.security.HashLoginService;
import org.eclipse.jetty.security.LoginService;

public class BIHashLoginService extends HashLoginService implements
		LoginService {
	
	String dataFile = "";
	Properties properties;
	
	public BIHashLoginService (String realm, String dataFile){
		super (realm,dataFile);
		this.dataFile = dataFile;
	}
	
	public void putUser (String userID, String newPwdtxt, String [] roles) throws Error {
		if ( newPwdtxt == null || newPwdtxt.equals ("") ){
			throw new Error ("New password cannot be empty");
		}
		if ( userID == null || userID.equals("")){
			throw new Error ("User cannot be empty");
		}		
		String rawPwd = "CRYPT:" + UnixCrypt.crypt (newPwdtxt, new Date().toString());
		String newPwd = rawPwd + "," + roles[0];
		try {
			readFile();
			super.putUser (userID,Credential.getCredential(newPwdtxt),roles);
			properties.put (userID,newPwd);
			writeFile();
		} catch (IOException ex){
			throw new Error ("There was a problem reading/writing the password file " + ex.getMessage());
		}
	}
	
	public void removeUser (String userID) throws Error  {
		if (userID == null || userID.equals("")){
			throw new Error ( "User cannot be empty");
		}
		try {
			readFile();
			properties.remove (userID);
			super.removeUser(userID);
			writeFile();
		} catch (IOException ex){
			throw new Error ("There was a problem reading/writing the password file " + ex.getMessage());
		}
	}
	
	public void readFile() throws IOException {
    	properties = new Properties();
   		properties.load(new FileInputStream("datafiles/realm.properties"));
	}
	
	public void writeFile () throws IOException {
        OutputStream outStream = this.getConfigResource().getOutputStream();
        properties.store (outStream,null);
		outStream.close();
	}

}
