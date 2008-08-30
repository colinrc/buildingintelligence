/**
 * 
 */
package au.com.BI.Comms;

/**
 * @author colin
 *
 */
public class HTTP extends BaseComms implements CommDevice {

	public void close() throws ConnectionFail {

	}

	public boolean isConnected() {
		return true;
	}

	public void setETXArray(int[] etxArray) {
	}

	public void setPenultimateArray(int[] penultimateArray) {
	}

	public void setSTXArray(int[] stxArray) {
	}

}

/*
/**
 * A Simple HTTP POST/GET Helper Class for Groovy 
 *
 * @author 		Tony Landis
 * @copyright 	2007 Tony Landis
 * @website 	http://www.tonylandis.com
 * @license 	BSD License (http://www.opensource.org/licenses/bsd-license.php)
 * @example 	h = new GroovyHTTP('http://www.google.com/search')		 
 *				h.setMethod('GET') 
 *				h.setParam('q', 'groovy')
 *				h.open()
 *				h.write()
 *				h.read() 
 *				println h.getHeader('Server')  
 *				println h.getContent() 
 *				h.close()

class GroovyHTTP {
	public method='POST'
	public uri
	public host
	public path
	public port
	public params=null
	public socket=null
	public writer=null
	public reader=null
	public writedata
	public headers = []
	public content

	// set the url and create new URI object
	def GroovyHTTP(url) {
		uri = new URI(url)
		host = uri.getHost()
		path = uri.getRawPath() 
		port = uri.getPort() 
		def tpar = uri.getQuery()
		if(tpar != null && tpar != '') {
			tpar.tokenize('&').each{
				def pp = it.tokenize('=');
				this.setParam(pp[0],pp[1]);
			}
		} 
		if(port == null || port < 0) port = 80
		if(path == null || path.length() == 0) path = "/" 		
	}

	// sets the method (GET or POST)
	def setMethod(setmethod) {
		method = setmethod
	}

	// push params into this request
	def setParam(var,value) {
		if(params != null) 
			params += '&'
		else
			params=''
		params += var +'='+URLEncoder.encode(value) 
	}

	// clear params
	def clearParams() {
		params = null
	}

	// open a new socket
	def open() { 
		socket = new Socket(host, port)
	}

	// write data to the socket
	def write() { 
		def contentLen = 0
		if(params!=null) contentLen = params.length()	
		def writedata = '';
		
		if(this.method == 'GET')	 
			writedata += "GET " + path +'?'+ params + " HTTP/1.0\r\n"
		else
			writedata += "POST " + path + " HTTP/1.0\r\n"
		
		writedata +=
			"Host: " + host + "\r\n" + 
			"Content-Type: application/x-www-form-urlencoded\r\n" + 
			"Content-Length: " + contentLen + "\r\n\r\n" + 
			params + "\r\n"
			"Connection: close\r\n\r\n"  
			   
		writer = new PrintWriter(socket.getOutputStream(), true)
		writer.write(writedata)
		writer.flush() 
	}

	// read response from the server
	def read() { 
		reader = new DataInputStream(socket.getInputStream())
		def c = null
		while (null != ((c = reader.readLine()))) {   
			if(c=='') break 
			headers.add(c) 	 
		} 
	} 

	// get header value by name
	def getHeader(name) {
		def pattern = name + ': ' 
		def result
		headers.each{ 
			if(it ==~ /${pattern}.* /) { 
				result = it.replace(pattern,'').trim()
				return 2
			}   
		}
		return result
	}

	// get the response content
	def getContent() { 
		def row 
		content = ''
		while (null != ((row = reader.readLine()))) content += row + "\r\n"  
		return content = content.trim();
	}

	// close the socket
	def close() {
		reader.close() 
		writer.close()
		socket.close()
	}
}
*/