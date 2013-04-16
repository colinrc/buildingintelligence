/*
 * Created on Apr 12, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Util;
import au.com.BI.Command.*;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public interface ClientModel {
	public void broadcastCommand (CommandInterface command);
}
