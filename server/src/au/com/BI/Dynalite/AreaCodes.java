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
	public void addJoin ( String areaCode,String toAreaOffsetStr){
		int toAreaOffset = Integer.parseInt(toAreaOffsetStr);
		addJoin (areaCode,toAreaOffset);
	}
	
	// @TODO change to iterate over all dynalite devices
	public void addJoin ( String areaCode,int toAreaOffset){
		
		String paddedKey = Utility.padString (areaCode,2);
		
		if (areaCodes.containsKey(paddedKey)){
			LinkedList devs = (LinkedList)areaCodes.get (paddedKey);
			Iterator devsIter = devs.iterator();
			while (devsIter.hasNext()){
				try {
					DynaliteDevice dev = (DynaliteDevice)devsIter.next();
					int newArea = dev.listensToLinkArea(toAreaOffset);
					if (newArea != 255){
						String paddedToKey = Utility.padStringTohex(toAreaOffset);
						this.add(paddedToKey, dev);
					}
				} catch (ClassCastException ex){}
			}
		}
	}

	public void removeJoin ( String areaCode,String toArea){
		int toAreaInt = Integer.parseInt(toArea);
		removeJoin (areaCode,toAreaInt);
	}

	public void removeJoin ( String areaCode,int toAreaOffset){
		String paddedKey = Utility.padString (areaCode,2);
		if (areaCodes.containsKey(paddedKey)){
			LinkedList devs = (LinkedList)areaCodes.get (paddedKey);
			Iterator devsIter = devs.iterator();
			while (devsIter.hasNext()){
				try {
					DynaliteDevice dev = (DynaliteDevice)devsIter.next();
					int newArea = dev.listensToLinkArea(toAreaOffset);
					if (newArea != 255){
						String paddedToKey = Utility.padStringTohex(toAreaOffset);
						this.remove(paddedToKey, dev);
					}
				} catch (ClassCastException ex){}
			}
		}		
		
	}

	public void add (String areaCode, DynaliteDevice device){
		LinkedList keys;
		if (areaCodes.containsKey(areaCode)){
			keys = (LinkedList)areaCodes.get(areaCode);
		}else {
			keys = new LinkedList();
		}
		synchronized (keys){
			keys.add(device);
			areaCodes.put(areaCode,keys);
		}
	}
	
	public void remove (String areaCode, DynaliteDevice device){
		LinkedList keys;
		if (!areaCodes.containsKey(areaCode)){
			return;
		}
		keys = (LinkedList)areaCodes.get(areaCode);
		synchronized (keys){
			if (keys.contains(keys)) areaCodes.remove(device);
			areaCodes.put(areaCode,keys);
		}
	}
	

	public List findDevicesInArea (int areaInt, boolean includeAreaControl,int join) {
		String area = Utility.padStringTohex(areaInt);
		return findDevicesInArea (area,includeAreaControl,join);
	}

	public List findDevicesInArea (String area, boolean includeAreaControl,int join) {
		LinkedList resultList = new LinkedList();
		LinkedList deviceList = (LinkedList)(areaCodes.get(area));
		Iterator eachLight = deviceList.iterator();
		while (eachLight.hasNext()){
			DynaliteDevice nextItem = (DynaliteDevice)eachLight.next();
			if (!includeAreaControl && nextItem.isAreaDevice()) continue;
			resultList.add(nextItem);
			
		}
		return resultList;
	}
	
	public List findAllAreas () {
		LinkedList allAreas = new LinkedList();
		Iterator eachArea = areaCodes.keySet().iterator();
		while (eachArea.hasNext()){
			String nextArea = (String)eachArea.next();
			LinkedList deviceList = (LinkedList)(areaCodes.get(nextArea));
			Iterator eachLight = deviceList.iterator();
			while (eachLight.hasNext()){
				DynaliteDevice nextItem = (DynaliteDevice)eachLight.next();
				if (nextItem.isAreaDevice()) {
					allAreas.add (nextItem);
				}
			}
		}
		return allAreas;
	}
}
