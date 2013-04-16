/*
 * Created on 25/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.io.PrintStream;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorPrintStream extends PrintStream {
	SimulatorControls controls;
	public SimulatorPrintStream(PrintStream out, SimulatorControls controls) {
		super(out);
		this.controls = controls;
	}
	public void println(String inString){
		controls.appendNetwork(inString);
	}
}
