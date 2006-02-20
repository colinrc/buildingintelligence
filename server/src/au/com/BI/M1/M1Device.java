package au.com.BI.M1;

/**
 * The M1 zones have the concept of an area. The area is a room or section of a building having at least
 * one keypad and one or more zone components. Components assigned to one area are separated and 
 * independently controllable from components assigned to other areas. For example: Only area 1 keypads
 * can disarm or arm area 1 zones.
 * @author dcummins
 *
 */
public interface M1Device {
	
	/**
	 * Return the area that the M1 Device is operating in.
	 * @return
	 */
	public String getArea();
	
	/**
	 * Sets the area for an M1 Device.
	 * @param area The area that the zone is in.
	 */
	public void setArea(String area);
	
}
