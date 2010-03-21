package au.com.BI.Comms;

import java.util.logging.Level;
import java.util.logging.Logger;

import com.apple.dnssd.*;

public class HandleBonjour implements RegisterListener
{
	protected int port;
	Logger logger = null;
	protected DNSSDRegistration monService = null;
	protected DNSSDRegistration webDavShare = null;
	protected String serverName = "Unknown";
	
	public HandleBonjour(Level debugLevel,int port) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        logger.setLevel( debugLevel);
        this.port = port;
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
	public void startBonjour (String name)
	    throws DNSSDException
    {
		logger.log(Level.FINER,"Bonjour Registration Starting");
		logger.log(Level.FINER,"Requested Name: " + name + " port : " + Integer.toString(port));
		monService = DNSSD.register(name, "_elife_monitor._tcp", port, this);
    }
	
	public void stopBonjour (){
		logger.log(Level.FINER,"Bonjour Registration Stopping");
		if (monService != null) monService.stop();
	}
	
	  // Do the registration
	public void startWebDavShare (String name)
	    throws DNSSDException
    {
		logger.log(Level.FINER,"Bonjour Registration Starting");
		logger.log(Level.FINER,"Requested Name: " + name + " port : " + Integer.toString(port));
		webDavShare = DNSSD.register(name, "webdavs._tcp", port, this);
    }
	
	public void stopWebDavShare (){
		logger.log(Level.FINER,"Bonjour Registration Stopping");
		if (webDavShare != null ) webDavShare.stop();
	}
}
