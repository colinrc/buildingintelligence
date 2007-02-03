package au.com.BI.Config;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.logging.*;
import Aladdin.*;

public class Security {
    
    public final int clientModel = 0;
    public final int defaultModel = 255;
    public final int lightModel = 1;
    public final int avModel = 2;
    public final int alarmModel = 3;
    public final int controllerModel = 4;
    
    private  byte allowNumbers [] = {4};
    
    private static final String vendor_code = new String("4PleHqy5Sr5zJKxsox07nI31nqP0vdw/XT/h4av881NagxNNel/5QxaeejwrZX9XezJHGQQZNyDZetkSyMyuCnyL9g1Ffnwxz5sCITcyYtNGL0VrvHo5Fm9pxJscHKGWfmLN/WLcTrfWalyh7IiNWbwSDKv78bomJVgziX1DTFsnjkzn4cKR96cPE0XJ19OgIv3DJH4XB87pWTzFxJ5U1ol9sT2Ts6Mi8Zl/A1O4v0IxORrVnqXfY4xwz4Flf21wWwXREy+d+9lLqFRFDtC1Gy0XcCTVmaBHIfUDz4QrsqS13AsdxNTNm31IdWIvWpN+k/RLBgUL36WdkQLwDSSry5XVUzC0DGnwiegHqHkZmEMZZV0UwvdUFMDAULv/v+BoFoju95U7ilSHREs5WTXNc9NCbNYK91xl+ekzQo5q6yTwTp99WLoEgwuD2Vai3UxqEow4O5y/QUCN5RRlwpZ6mx353+bzHlPntYQnDcF/UbxGNYER78ojHom6hwvSc2U/RIhqc2TXfLFRDszZDuH3iX1eHpp7/CbGiCXe9GnhOSYUubtdWS5VMl/mkbt6wMwOuro9z3ACXJHG29a3naQuvpOQEPXvJi0ss3mbDUbb6Ktq+xyZvOZ1muykfKrAPXqx5h/l3LE7z3nQ69+5712cWqkcUJAmbFkCZFo1Zb+khxPXfqRrQeI8q3LIFa5P1PVXrU0SE7TOQhqV2JoicAyUj50F/UsqNQ==");
    private boolean keyPresent = false;
    private Hasp hasp;
    
    private boolean connected = false;
    protected Logger logger;
    
    protected int lastFlashClients = 0;
    protected int lastWebCount = 0;
    
    public Security() {
	/* login program number 0 */
	/* this default feature is available on any key */
	/* search for local and remote HASP HL key */

    logger = Logger.getLogger(this.getClass().getPackage().getName());

    
    // *
	connected = true;
	return ;
    /*
    
     
	InputStreamReader reader = new InputStreamReader(System.in);
	BufferedReader in = new BufferedReader(reader);
	 
	 hasp = new Hasp(Hasp.HASP_PROGNUM_DEFAULT_FID);
	 
       hasp.login(vendor_code);
       int status = hasp.getLastError();
	 
       switch (status) {
	 case HaspStatus.HASP_STATUS_OK:
		 logger.log (Level.FINEST,"Logged into key");
	   connected = true;
	 
	   break;
	 case HaspStatus.HASP_FEATURE_NOT_FOUND:
	   logger.log (Level.WARNING,"Security feature not found");
	   break;
	 case HaspStatus.HASP_CONTAINER_NOT_FOUND:
		 logger.log (Level.WARNING,"License container not available");
	   break;
	 case HaspStatus.HASP_OLD_DRIVER:
		 logger.log (Level.WARNING,"Outdated driver version installed");
	   break;
	 case HaspStatus.HASP_NO_DRIVER:
		 logger.log (Level.WARNING,"HASP HL driver not installed");
	   break;
	 case HaspStatus.HASP_INV_VCODE:
		 logger.log (Level.WARNING,"invalid vendor code");
	   break;
	 default:
		 logger.log (Level.WARNING,"Login to desired feature failed");
       }
       if (!connected) {
		System.exit(0);
       } else {
		int fsize = hasp.getSize(Hasp.HASP_FILEID_MAIN);
		allowNumbers = new byte[fsize];
		hasp.read(Hasp.HASP_FILEID_MAIN,
		     0,
			fsize,
			allowNumbers);
       }
 // */
    }
    
    public final boolean allowClient(int clientCount)  throws TooManyClientsException {

		lastFlashClients = clientCount;
		try {
		    if ((clientCount + lastWebCount ) > allowNumbers[0]) {
				throw new TooManyClientsException ("You have probably attempted to connect to the eLife server with more clients than you have purchased, if this problem persists please contact your integrator");
		    } else {
			return true;
		    }
		} catch (NullPointerException ex){
		    return false;
		}
    }
    
    public final boolean allowWebClient(int clientCount) throws TooManyClientsException {
 
		lastWebCount = clientCount;
		try {
		    if ((clientCount + lastFlashClients ) > allowNumbers[0]) {
				throw new TooManyClientsException ("You have probably attempted to connect to the eLife server with more clients than you have purchased, if this problem persists please contact your integrator");
		    } else {
			return true;
		    }
		} catch (NullPointerException ex){
		    return false;
		}

    }
    
    public final boolean allowModel(int modelType,int modelCount){
	return true;
    }
    
    public boolean isConnected() {
	return connected;
    }
    
    public int getNumberClientsAllowed () {
    	return allowNumbers[0];
    }
    
    
}
