package au.com.BI.Dynalite;

import java.util.LinkedList;
import java.util.List;

import au.com.BI.Command.CommandInterface;

public class GeneralDynaliteResult {
	List linkedDeviceCommands;
	boolean rescanLevels = false;
	boolean rescanSingleChannel = false;
	int rescanArea = 0;
	byte rescanChannel = 0;
	protected boolean isError = false;
	protected String errorMessage;
	Exception ex = null;
	
	public GeneralDynaliteResult() {
		 linkedDeviceCommands = new LinkedList ();	
	}
	
	public List getLinkedDeviceCommands() {
		return linkedDeviceCommands;
	}

	public void setLinkedDeviceCommands(List linkdDeviceCommands) {
		this.linkedDeviceCommands = linkdDeviceCommands;
	}

	public void addLinkedDeviceCommand(CommandInterface command) {
		linkedDeviceCommands.add(command);
	}

	public boolean isRescanLevels() {
		return rescanLevels;
	}

	public void setRescanLevels(boolean rescanLevels) {
		this.rescanLevels = rescanLevels;
	}

	public int getRescanArea() {
		return rescanArea;
	}

	public void setRescanArea(int rescanArea) {
		this.rescanArea = rescanArea;
	}

	public boolean isRescanSingleChannel() {
		return rescanSingleChannel;
	}

	public void setRescanSingleChannel(boolean rescanSingleChannel) {
		this.rescanSingleChannel = rescanSingleChannel;
	}

	public byte getRescanChannel() {
		return rescanChannel;
	}

	public void setRescanChannel(byte rescanChannel) {
		this.rescanChannel = rescanChannel;
	}
}
