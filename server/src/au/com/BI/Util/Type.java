package au.com.BI.Util;

import java.io.Serializable;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class Type implements Serializable, Cloneable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private transient String value;

	private transient String desc;

	// a hashtable of hashtables...
	private static final Hashtable types = new Hashtable();

	protected Type(String value, String desc) {
		this.value = value;
		this.desc = desc;
		checkForDupes(this);
		storeType(this);
	}

	private void checkForDupes(Type type) {
		String className = type.getClass().getName();

		Hashtable values;

		values = (Hashtable) types.get(className);

		if (values != null) {
			if (values.get(type.getValue()) != null) {
				System.out.println("No Dupes Allowed: " + className + "="
						+ type);
				throw (new RuntimeException());
			}
		}
	}

	private void storeType(Type type) {
		String className = type.getClass().getName();

		Hashtable values;

		synchronized (types) // avoid race condition for creating inner table
		{
			values = (Hashtable) types.get(className);

			if (values == null) {
				values = new Hashtable();
				types.put(className, values);
			}
		}

		values.put(type.getValue(), type);
	}

	public static Type getByValue(Class classRef, String value) {
		Type type = null;

		String className = classRef.getName();

		Hashtable values = (Hashtable) types.get(className);

		if (values != null) {
			type = (Type) values.get(value);
		}

		return (type);
	}
	
	public static Type getByDescription(Class classRef, String description) {
		Type type = null;
		
		String className = classRef.getName();
		
		Hashtable values = (Hashtable) types.get(className);
		
		Iterator iterator = values.keySet().iterator();
		
		while (iterator.hasNext()) {
			type = (Type)values.get(iterator.next());
			if (type.getDescription().equals(description)) {
				return(type);
			}
		}
		
		return null;
	}
	

	public static Enumeration elements(Class classRef) {
		String className = classRef.getName();

		Hashtable values = (Hashtable) types.get(className);

		if (values != null) {
			return (values.elements());
		} else {
			return null;
		}
	}

	public String getValue() {
		return value;
	}
	
	public String getDescription() {
		return desc;
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof Type)) {
			return false;
		}

		if (this == obj) {
			return true;
		}

		if ((this.getClass() == obj.getClass())
				&& (this.getValue().equals(((Type) obj).getValue()))) {
			return true;
		}

		return false;
	}

}
