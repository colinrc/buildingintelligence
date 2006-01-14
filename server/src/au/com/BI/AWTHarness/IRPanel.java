/*
 * Created on Sep 27, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.AWTHarness;

import java.util.logging.Logger;

import javax.swing.JPanel;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import au.com.BI.GC100.IRCodeDB;



public class IRPanel extends JPanel implements ChangeListener {

    protected Logger logger;
    protected IRCodeDB iRCodeDB;

    public IRPanel (IRCodeDB iRCodeDB) {
    		logger = Logger.getLogger(this.getClass().getPackage().getName());
    }
    /* (non-Javadoc)
     * @see javax.swing.event.ChangeListener#stateChanged(javax.swing.event.ChangeEvent)
     */
    public void stateChanged(ChangeEvent e) {

    }

}
