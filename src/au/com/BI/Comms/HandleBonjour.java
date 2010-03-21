package au.com.BI.Comms;

import java.util.logging.Level;
import java.util.logging.Logger;

import com.apple.dnssd.*;

public class HandleBonjour implements RegisterListener
{
	protected int port;
	Logger logger = null;
	protected DNSSDRegistration monService = null;
	protected String serverName = "Unknown";
	
	public HandleBonjour(Level debugLevel) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        logger.setLevel( debugLevel);
	}

	// Display error message on failure
	public void operationFailed(DNSSDService service, int errorCode)
	{
		logger.log (Level.WARNING,"Bonjour registration failed for monitor " + errorCode);
	}

	// Display registered name on success
	public void serviceRegistered(DNSSDRegistration registration, int flags,
	    String serviceName, String regType, String domain)
	{
	    logger.log(Level.INFO, "Registered bonjour service : " + serviceName);
	    logger.log(Level.INFO,"Type  : " + regType);
	    logger.log(Level.INFO,"Domain: " + domain);
	}

	  // Do the registration
	public void startBonjour (String name,int port)
	    throws DNSSDException
    {
		logger.log(Level.FINER,"Bonjour Registration Starting");
		logger.log(Level.FINER,"Requested Name: " + name + " port : " + Integer.toString(port));
		monService = DNSSD.register(name, "_eLife_Monitor._tcp", port, this);
    }
	
	public void stopBonjour (){
		logger.log(Level.FINER,"Bonjour Registration Stopping");
		monService.stop();
	}
}
