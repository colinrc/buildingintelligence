package au.com.BI.Dynalite;

import au.com.BI.Util.*;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public class AreaCodes {
	protected HashMap areaCodes = null;
	public final static int AreaCommand = 0;
	
	public AreaCodes () {
		areaCodes = new HashMap(10);
	}
	
	public void clear (){
		areaCodes.clear();
	}
	
	// @TODO fix
	public void addJoin ( String areaCode,String toArea){
		int toAreaInt = Integer.parseInt(toArea);
		addJoin (areaCode,toAreaInt);
	}
	
	// @TODO change to iterate over all dynalite devices
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

	public void add (String areaCode, DynaliteDevice device){
		LinkedList keys;
		if (areaCodes.containsKey(areaCode)){
			keys = (LinkedList)areaCodes.get(areaCode);
		}else {
			keys = new LinkedList();
		}
		keys.add(device);
		areaCodes.put(areaCode,keys);
	}
	
	

	public List findDevicesInArea (int areaInt, boolean includeAreaControl,int join) {
		String area = Utility.padStringTohex(areaInt);
		return findDevicesInArea (area,includeAreaControl,join);
	}

	public List findDevicesInArea (String area, boolean includeAreaControl,int join) {
		LinkedList deviceList = (LinkedList)(areaCodes.get(area));
		Iterator eachLight = deviceList.iterator();
		while (eachLight.hasNext()){
			DynaliteDevice nextItem = (DynaliteDevice)eachLight.next();
			if (!includeAreaControl && nextItem.getChannel() == AreaCommand) continue;
		}
		return deviceList;
	}
}
