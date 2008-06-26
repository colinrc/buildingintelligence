package au.com.BI.Admin.util;
/*
 * Created on Jan 30, 2005
 * @Author Colin Canfield
 */

import java.util.*;
import java.text.DateFormat;

public class FileList {

	private String dir;
	private Vector <String>names;
	private Vector <String>descs;
	private Vector<String> joined;
	private DateFormat myFormat;
	
	public FileList(String dir){
		this.dir = dir;
		names = new Vector <String>();
		descs = new Vector<String>();
		joined = new Vector<String>();
		myFormat = DateFormat.getDateTimeInstance(DateFormat.SHORT,DateFormat.SHORT);
	}
	
	public void addItem (String name, String desc,String timestamp) {
		names.add(name);
		descs.add (desc);
		Date time;
		
		try {
			long timeLong = Long.parseLong(timestamp);
			time = new Date (timeLong);
		} catch (NumberFormatException ex) {
			time = new Date();
		}
		
		int nameLength = name.length();
		int spaces = 22 - nameLength;
		if (spaces < 0) spaces = 0;
		String spc = "                          ".substring(0,spaces);
		
		if (desc.equals (""))
			joined.add (name  + spc + " : " + myFormat.format(time));
		else 
			joined.add (name + spc + " : " + myFormat.format(time) + " : " + desc);
	}
	
	public Object [] getNames () {
		return names.toArray();
	}

	public Object [] getJoined () {
		return joined.toArray();		
	}

	public Object [] getDesc () {
		return joined.toArray();
	}
	
	public int getNumberItems() {
		return names.size();
	}
	
	
}
