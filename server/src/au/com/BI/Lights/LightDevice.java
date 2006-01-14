package au.com.BI.Lights;

public interface LightDevice {

	public int getMax ();
	
	public void setMax (int max);
	
	public void setRelay (String relay);
	
	public String getRelay();
}
