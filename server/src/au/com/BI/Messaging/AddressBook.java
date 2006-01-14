package au.com.BI.Messaging;
import java.util.*;
public class AddressBook {
	
	public final static String ALL = "All";
	public final static long  ALL_INT = -1;
	
	public final static String ALL_INC_SRC = "All_Inc_Src";
	public final static long ALL_INC_SRC_INT = -2;

	public final static long NOT_FOUND = -3;

	public HashMap nameMap;
	public HashMap userMap;
	
	public AddressBook () {
		nameMap = new HashMap();
		userMap = new HashMap();
		nameMap.put(ALL_INC_SRC,new Long (ALL_INC_SRC_INT));
		nameMap.put(ALL,new Long (ALL_INT));
	}
	
	public void setName (String name, long ID){
		nameMap.put(name,new Long (ID));		
	}

	public long getIDFromName (String name){
		if (nameMap.containsKey(name)) 
			return ((Long)nameMap.get(name)).longValue();
		else
			return AddressBook.NOT_FOUND;
	}
	
	public void setUser (String user, long ID){
		userMap.put(user,new Long (ID));		
	}

	public long getIDFromUser (String user){
		if (nameMap.containsKey(user)) 
			return ((Long)userMap.get(user)).longValue();		
		else
			return AddressBook.NOT_FOUND;

	}

}
