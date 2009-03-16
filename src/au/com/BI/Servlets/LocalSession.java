/**
 * 
 */
package au.com.BI.Servlets;

import au.com.BI.Command.ClientCommandFactory;
import au.com.BI.Jetty.CacheBridge;

/**
 * @author colin
 *
 */
public class LocalSession {
	boolean handlingSession = false;
	Long ID = null;
	Long serverID = null;
	CacheBridge cacheBridge = null;
	ClientCommandFactory clientCommandFactory = null;
	
	public boolean isHandlingSession() {
		return handlingSession;
	}


	public void setHandlingSession(boolean handlingSession) {
		this.handlingSession = handlingSession;
	}


	public Long getID() {
		return ID;
	}


	public void setID(Long id) {
		ID = id;
	}


	public Long getServerID() {
		return serverID;
	}


	public void setServerID(Long serverID) {
		this.serverID = serverID;
	}


	public CacheBridge getCacheBridge() {
		return cacheBridge;
	}


	public void setCacheBridge(CacheBridge cacheBridge) {
		this.cacheBridge = cacheBridge;
	}


	public ClientCommandFactory getClientCommandFactory() {
		return clientCommandFactory;
	}


	public void setClientCommandFactory(ClientCommandFactory clientCommandFactory) {
		this.clientCommandFactory = clientCommandFactory;
	}

}
