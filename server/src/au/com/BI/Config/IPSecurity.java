
package au.com.BI.Config;
import java.util.*;
import java.io.*;


import org.jdom.*;
import org.jdom.input.*;
import java.util.logging.*;

/**
 * @author Colin Canfield
 *
 */

public class IPSecurity {
    Logger logger;
    Map <String,Boolean>fullClients;
    Map <String,Boolean>postOnlyClients;
    
    public enum IPType {FullFunction,PostOnly};
    
    public IPSecurity() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        Map <String,Boolean>fullClients = new HashMap <String,Boolean>();
        Map <String,Boolean>postOnlyClients = new HashMap <String,Boolean>();
    }
    
    public void readIPs(String fileName)
    throws ConfigError {
        // Create an instance of the tester and test
        try {
            SAXBuilder builder = null;
            
            builder = new SAXBuilder();
            Document doc = builder.build(fileName);
            Element theConfig = doc.getRootElement();
            

            Element fullFunctionList = theConfig.getChild("full_function");
            if (fullFunctionList != null) {
            	Iterator <Element>eachElementIter = fullFunctionList.getDescendants();
            	while (eachElementIter.hasNext()){
            		Element nextElm = eachElementIter.next();
            		String IP  = nextElm.getAttributeValue("IP");
            		if (IP != null) {
            			fullClients.put(IP,false);
            		}
            	}
            }
             
            Element postOnlyList = theConfig.getChild("post_only");
            if (postOnlyList != null) {
            	Iterator <Element>eachElementIter = fullFunctionList.getDescendants();
            	while (eachElementIter.hasNext()){
            		Element nextElm = eachElementIter.next();
            		String IP  = nextElm.getAttributeValue("IP");
            		if (IP != null) {
            			postOnlyClients.put(IP,false);
            		}
            	}
            }
            
        } catch (JDOMException e) {
            throw new ConfigError(e);
        } catch (IOException e) {
            throw new ConfigError(e);
        } catch (NullPointerException e) {
            throw new ConfigError("Attribute not set properly in bootstrap file");
        }
        
    }
  
    public boolean iPInRange (String iP,  IPType ipType){
    	switch (ipType){
    	case FullFunction:
    		if (fullClients.containsKey(iP)){
    			return true;
    		} else {
    			return false;
    		}


    	case PostOnly:
    		if (postOnlyClients.containsKey(iP)){
    			return true;
    		} else {
    			return false;
    		}

    	}
    	return false;
    }
    
}
