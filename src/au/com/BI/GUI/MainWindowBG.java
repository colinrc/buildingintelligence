/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Graphics;
import java.awt.Image;
import java.util.Vector;
import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.ActiveGroup;
import au.com.BI.DataModel.ActiveRoom;
import au.com.BI.DataModel.eLifeActiveLoader;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageLoader;
/**
 *
 * @author David
 */
public class MainWindowBG extends java.awt.Container {
	private Page currentPage;
	private MainWindowTitleBar titleBar;
	private ImageLoader imageLoader;
	private ServerHandler serverHandle;
	private SerialHandler serialHandle;
	private eLifeActiveLoader client;
	private Vector rooms;
	private int currentRoom;
	private int currentDevice;
	private boolean room;
	//private Tree 
	protected int bufferWidth;
	protected int bufferHeight;
	protected Image bufferImage;
	protected Graphics bufferGraphics;
	public void paint(Graphics g) {
		resetBuffer();
		if (bufferGraphics != null) {
			//this clears the offscreen image, not the onscreen one
			bufferGraphics.clearRect(0, 0, bufferWidth, bufferHeight);
			//calls the paintbuffer method with 
			//the offscreen graphics as a param
			paintBuffer(bufferGraphics);
			//we finaly paint the offscreen image onto the onscreen image
			g.drawImage(bufferImage, 0, 0, this);
		}
	}
	public void paintBuffer(Graphics g) {
		//in classes extended from this one, add something to paint here!
		//always remember, g is the offscreen graphics
		g.setColor(new java.awt.Color(82, 104, 141));
		g.fillRect(0, 0, 240, 320);
		super.paint(g);
	}
	private void resetBuffer() {
		// always keep track of the image size
		bufferWidth = getSize().width;
		bufferHeight = getSize().height;
		//    clean up the previous image
		if (bufferGraphics != null) {
			bufferGraphics.dispose();
			bufferGraphics = null;
		}
		if (bufferImage != null) {
			bufferImage.flush();
			bufferImage = null;
		}
		System.gc();
		//    create the new image with the size of the panel
		bufferImage = createImage(bufferWidth, bufferHeight);
		bufferGraphics = bufferImage.getGraphics();
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	/** Creates a new instance of MainWindowBG */
	public MainWindowBG(
		ImageLoader inImageLoader,
		ServerHandler inServerHandler,
		eLifeActiveLoader client, SerialHandler serialHandle) {
		imageLoader = inImageLoader;
		serverHandle = inServerHandler;
		this.serialHandle = serialHandle;
		serialHandle.setWindowBG(this);
		this.client = client;
		titleBar = new MainWindowTitleBar(inImageLoader, inServerHandler, "Main");
		titleBar.setBounds(0, 0, 240, 80);
		rooms = client.getRooms();
		currentRoom = 0;
		currentDevice = -1;
		if (rooms.size() > 0) {
			buildRoomPage((ActiveRoom) rooms.get(currentRoom));
		}
		add(titleBar);
		room = true;
	}
	public SerialHandler getSerialHandle() {
		return serialHandle;
	}
	public void upPage() {
		if (room) {
			if (currentRoom == 0) {
				if (currentRoom != rooms.size() - 1) {
					currentRoom = rooms.size() - 1;
				} else {
					return;
				}
			} else {
				currentRoom--;
			}
			buildRoomPage((ActiveRoom) rooms.get(currentRoom));			
		} else {
			if (currentDevice == 0) {
				if (currentDevice
					!= ((ActiveRoom) rooms.get(currentRoom)).getGroups().size() - 1) {
					currentDevice = ((ActiveRoom) rooms.get(currentRoom)).getGroups().size() - 1;
				} else {
					return;
				}
			} else {
				currentDevice--;
			}
			buildDevicePage(
				((ActiveGroup) ((ActiveRoom) rooms.get(currentRoom))
					.getGroups()
					.get(currentDevice)));
		}
	}
	public void downPage() {
		if (room) { //
			if (currentRoom == rooms.size() - 1) {
				if (currentRoom != 0) {
					currentRoom = 0;
				} else {
					return;
				}
			} else {
				currentRoom++;
			}
			buildRoomPage((ActiveRoom) rooms.get(currentRoom));
		} else {
			if (currentDevice == ((ActiveRoom) rooms.get(currentRoom)).getGroups().size() - 1) {
				if (currentDevice != 0) {
					currentDevice = 0;
				} else {
					return;
				}
			} else {
				currentDevice++;
			}
			buildDevicePage(
				((ActiveGroup) ((ActiveRoom) rooms.get(currentRoom))
					.getGroups()
					.get(currentDevice)));
		}
	}
	public void goHome(){
		if (!room) {
			buildRoomPage((ActiveRoom) rooms.get(currentRoom));
		} else{
			if(currentRoom != 0){
				currentRoom = 0;
				buildRoomPage((ActiveRoom) rooms.get(currentRoom));
			}
		}
	}
	public void buildRoomPage(ActiveRoom currentRoom) {
		if (currentPage != null) {
			this.remove(currentPage);
			try {
				currentPage.finalize();
			} catch (Throwable e) {
			}
			currentPage = null;
		}
		currentPage = new RoomPage(imageLoader, serverHandle,serialHandle, currentRoom.getGroups());
		currentPage.setBounds(0, 80, 240, 240);
		add(currentPage);
		titleBar.setTitle(currentRoom.getName());
		currentDevice = -1;
		currentPage.repaint();
		room = true;
		if (this.currentRoom ==0){
			serialHandle.sendSerialMessage("B1Off");
		} else{
			serialHandle.sendSerialMessage("B1Blue");
		}
		//currentPage.setButtonsOn();
	}
	public void buildDevicePage(ActiveGroup currentDevice) {
		if (currentPage != null) {
			this.remove(currentPage);
			try {
				currentPage.finalize();
			} catch (Throwable e) {
			}
			currentPage = null;
		}
		currentPage =
			new DevicePage(imageLoader, serverHandle,serialHandle, currentDevice.getControls(), currentDevice);
		currentPage.setBounds(0, 80, 240, 240);
		add(currentPage);
		titleBar.setTitle(
			((ActiveRoom) rooms.get(currentRoom)).getName() + "/" + currentDevice.getName());
		for (int index = 0;
			index < ((ActiveRoom) rooms.get(currentRoom)).getGroups().size();
			index++) {
			if (((ActiveGroup) ((ActiveRoom) rooms.get(currentRoom)).getGroups().get(index))
				.equals(currentDevice)) {
				this.currentDevice = index;
			}
		}
		room = false;
		currentPage.repaint();
	}
	public void upButton() {
		currentPage.upButton();
	}
	public void downButton() {
		currentPage.downButton();
	}
	public void backPage() {
		currentPage.cancel();
	}
	public void ok() {
		currentPage.select();
	}
	public void select() {
		currentPage.click();
	}
	public void rotEncChange(int inValue) {
		currentPage.encChange(inValue);
	}
}
