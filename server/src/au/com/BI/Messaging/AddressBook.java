package au.com.BI.Messaging;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
public class AddressBook {
	public static enum Locations { NOT_CONNECTED,DIRECT,HTTP,JABBER};
	public static enum ClientTypes { FLASH, JAVA_PDA };
	
	public final static String ALL = "All";
	public final static long  ALL_INT = -1;
	

	public final static long NOT_FOUND = -3;
	protected ClientTypes clientType = ClientTypes.FLASH;

	public ConcurrentHashMap <String,Long>nameMap;
	public ConcurrentHashMap <String,Long>userMap;
	public ConcurrentHashMap <Long,String>nameMapReverse;
	public ConcurrentHashMap <Long,String>userMapReverse;


	
	public AddressBook () {
		nameMap = new ConcurrentHashMap<String,Long>();
		userMap = new ConcurrentHashMap<String,Long>();
		nameMapReverse = new ConcurrentHashMap<Long,String>();
		userMapReverse = new ConcurrentHashMap<Long,String>();
		nameMap.put(ALL,new Long (ALL_INT));
	}
	
	public void setName (String name, long ID,Locations location){
		nameMap.put(name,new Long (ID));		
		nameMapReverse.put(ID, name);
	}

	public long getIDFromName (String name){
		if (nameMap.containsKey(name)) 
			return ((Long)nameMap.get(name)).longValue();
		else
			return AddressBook.NOT_FOUND;
	}
	
	public void setUser (String user, long ID,Locations location){
		userMap.put(user,new Long (ID));		
		userMapReverse.put(ID,user);
	}

	public long getIDFromUser (String user){
		if (nameMap.containsKey(user)) 
			return ((Long)userMap.get(user)).longValue();		
		else
			return AddressBook.NOT_FOUND;

	}

	public ClientTypes getClientType() {
		return clientType;
	}

	public void setClientType(ClientTypes clientType) {
		this.clientType = clientType;
	}
	
	public Set <String>getAllNames () {
		return this.nameMap.keySet();
	}
	
	public void removeByID (long ID){
			String name = nameMapReverse.get(ID);
			if (name != null){
				if (nameMap.containsKey(name)) {
					nameMap.remove(name);
				}
				nameMapReverse.remove(ID);
			}
			
			String user = userMapReverse.get(ID);
			if (user != null){
				if (userMap.containsKey(user)) userMap.remove(user);
				userMapReverse.remove(ID);
			}
	}
	
	public String getUserAtClientName(String clientName){
		long ID = this.getIDFromName(clientName);
		if (userMapReverse.containsKey(ID)) {
			return userMapReverse.get(ID);
		} else {
			return "";
		}
	}


}
