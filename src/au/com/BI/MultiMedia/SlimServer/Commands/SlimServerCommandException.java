package au.com.BI.MultiMedia.SlimServer.Commands;

public class SlimServerCommandException extends Exception {
	
	public SlimServerCommandException() {
		super();
	}

	public SlimServerCommandException(String arg0, Throwable arg1) {
		super(arg0, arg1);
	}

	public SlimServerCommandException(String arg0) {
		super(arg0);
	}

	public SlimServerCommandException(Throwable arg0) {
		super(arg0);
	}
}
