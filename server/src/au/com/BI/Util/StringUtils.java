package au.com.BI.Util;

import java.util.Vector;

public class StringUtils {

	public static String[] split(String str, char x) {
		Vector<String> v = new Vector<String>();
		String str1 = new String();
		for (int i = 0; i < str.length(); i++) {
			if (str.charAt(i) == x) {
				v.add(str1);
				str1 = new String();
			} else {
				str1 += str.charAt(i);
			}
		}
		v.add(str1);
		String array[];
		array = new String[v.size()];
		for (int i = 0; i < array.length; i++) {
			array[i] = new String((String) v.elementAt(i));
		}
		return array;
	}
	
	public static String[] split(String str) {
		Vector<String> v = new Vector<String>();
		for (int i = 0; i < str.length(); i++) {
			v.add(String.valueOf(str.charAt(i)));
		}
		String array[];
		array = new String[v.size()];
		for (int i = 0; i < array.length; i++) {
			array[i] = new String((String) v.elementAt(i));
		}
		return array;
	}

	public StringUtils() {
		super();
		// TODO Auto-generated constructor stub
	}

}
