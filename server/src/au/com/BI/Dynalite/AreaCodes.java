package au.com.BI.Dynalite;

import au.com.BI.Util.*;
import java.util.HashMap;
import java.util.LinkedList;

public class AreaCodes {
	protected HashMap areaCodes = null;
	
	public AreaCodes () {
		areaCodes = new HashMap(10);
	}
	
	public void clear (){
		areaCodes.clear();
	}
	
	
	public boolean isJoined (String area1, String area2){
		return false;
	}

	public void addKey (String areaCode){
		String paddedKey = Utility.padString (areaCode,2);
		if (!areaCodes.containsKey(paddedKey)){
			LinkedList keys = new LinkedList();
			areaCodes.put(paddedKey, keys);
		}
	}
	
	public void addJoin ( String areaCode,String toArea){
		int toAreaInt = Integer.parseInt(toArea);
		addJoin (areaCode,toAreaInt);
	}

	public void addJoin ( String areaCode,int toAreaInt){
		String paddedKey = Utility.padString (areaCode,2);
		String paddedToKey = Utility.padStringTohex(toAreaInt);
		if (areaCodes.containsKey(paddedKey)){
			LinkedList keys = (LinkedList)areaCodes.get (paddedKey);
			keys.add(paddedToKey);
		}
	}

	public void removeJoin ( String areaCode,String toArea){
		int toAreaInt = Integer.parseInt(toArea);
		removeJoin (areaCode,toAreaInt);
	}

	public void removeJoin ( String areaCode,int toAreaInt){
		String paddedKey = Utility.padString (areaCode,2);
		String paddedToKey = Utility.padStringTohex(toAreaInt);
		if (areaCodes.containsKey(paddedKey)){
			LinkedList keys = (LinkedList)areaCodes.get (paddedKey);
			keys.remove(paddedToKey);
		}
	}

	public void add (String areaCode, String key){
		LinkedList keys;
		if (areaCodes.containsKey(areaCode)){
			keys = (LinkedList)areaCodes.get(areaCode);
		}else {
			keys = new LinkedList();
		}
		keys.add(key);
		areaCodes.put(areaCode,keys);
	}
	
}
