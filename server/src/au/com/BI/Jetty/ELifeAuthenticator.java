/**
 * 
 */
package au.com.BI.Jetty;

import java.io.IOException;
import org.eclipse.jetty.server.Authentication;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Response;
import org.eclipse.jetty.security.Authenticator;
import org.eclipse.jetty.security.authentication.FormAuthenticator;
import org.eclipse.jetty.security.ServerAuthException;


/**
 * @author colin
 *
 */

public class ELifeAuthenticator extends FormAuthenticator  implements Authenticator {


	
	public  ELifeAuthenticator (String login, String error, boolean dispatch)  {
		super(login,error,dispatch);
	}

	public Authentication validateRequest(Request request, Response response,boolean mandatory) throws IOException, ServerAuthException {

		return super.validateRequest(  request,  response, mandatory);
		
	}
}
