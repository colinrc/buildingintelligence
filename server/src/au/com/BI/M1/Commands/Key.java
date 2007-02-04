package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class Key extends Type {
	public static final Key NO_KEY = new Key("0","No key");
	public static final Key STAR_KEY = new Key("11","Star Key");
	public static final Key POUND_KEY = new Key("12","Pound Key");
	public static final Key F1_KEY = new Key("12","Pound Key");
	public static final Key F2_KEY = new Key("12","Pound Key");
	public static final Key F3_KEY = new Key("12","Pound Key");
	public static final Key F4_KEY = new Key("12","Pound Key");
	public static final Key STAY_KEY = new Key("12","Pound Key");
	public static final Key EXIT_KEY = new Key("12","Pound Key");
	public static final Key CHIME_KEY = new Key("12","Pound Key");
	public static final Key BYPASS_KEY = new Key("12","Pound Key");
	public static final Key ELK_KEY = new Key("12","Pound Key");
	public static final Key DOWN_KEY = new Key("12","Pound Key");
	public static final Key UP_KEY = new Key("12","Pound Key");
	public static final Key RIGHT_KEY = new Key("12","Pound Key");
	
	private Key(String value, String desc) {
		super(value, desc);
	}
	
	public static Key getByValue(String value) {
		return((Key)Key.getByValue(Key.class,value));
	}
}
