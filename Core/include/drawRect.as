MovieClip.prototype.drawRect = function(x, y, w, h, cornerRadius) {
	if (arguments.length < 4) return;
	if (cornerRadius != undefined && (cornerRadius > 0 || typeof(cornerRadius) == "object")) {
		// init vars
		var theta, angle, cx, cy, px, py, tlCorner, trCorner, brCorner, blCorner;
		
		if(typeof(cornerRadius) == "object") {
			tlCorner = cornerRadius.tl;
			trCorner = cornerRadius.tr;
			brCorner = cornerRadius.br;
			blCorner = cornerRadius.bl;
		} else {
			tlCorner = trCorner = brCorner = blCorner = cornerRadius;
		}
				
		// theta = 45 degrees in radians
		theta = Math.PI/4;

		/*
		// make sure that w + h are larger than 2*cornerRadius
		if (cornerRadius>Math.min(w, h)/2) {
			cornerRadius = Math.min(w, h)/2;
		}
		*/
				
		// draw top line
		this.moveTo(x+tlCorner, y);
		this.lineTo(x+w-trCorner, y);
		//angle is currently 90 degrees
		angle = -Math.PI/2;
		
		// draw tr corner in two parts
		cx = x+w-trCorner+(Math.cos(angle+(theta/2))*trCorner/Math.cos(theta/2));
		cy = y+trCorner+(Math.sin(angle+(theta/2))*trCorner/Math.cos(theta/2));
		px = x+w-trCorner+(Math.cos(angle+theta)*trCorner);
		py = y+trCorner+(Math.sin(angle+theta)*trCorner);
		this.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x+w-trCorner+(Math.cos(angle+(theta/2))*trCorner/Math.cos(theta/2));
		cy = y+trCorner+(Math.sin(angle+(theta/2))*trCorner/Math.cos(theta/2));
		px = x+w-trCorner+(Math.cos(angle+theta)*trCorner);
		py = y+trCorner+(Math.sin(angle+theta)*trCorner);
		this.curveTo(cx, cy, px, py);
		
		// draw right line
		this.lineTo(x+w, y+h-brCorner);
		
		// draw br corner
		angle += theta;
		cx = x+w-brCorner+(Math.cos(angle+(theta/2))*brCorner/Math.cos(theta/2));
		cy = y+h-brCorner+(Math.sin(angle+(theta/2))*brCorner/Math.cos(theta/2));
		px = x+w-brCorner+(Math.cos(angle+theta)*brCorner);
		py = y+h-brCorner+(Math.sin(angle+theta)*brCorner);
		this.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x+w-brCorner+(Math.cos(angle+(theta/2))*brCorner/Math.cos(theta/2));
		cy = y+h-brCorner+(Math.sin(angle+(theta/2))*brCorner/Math.cos(theta/2));
		px = x+w-brCorner+(Math.cos(angle+theta)*brCorner);
		py = y+h-brCorner+(Math.sin(angle+theta)*brCorner);
		this.curveTo(cx, cy, px, py);
		
		// draw bottom line
		this.lineTo(x+blCorner, y+h);
		
		// draw bl corner
		angle += theta;
		cx = x+blCorner+(Math.cos(angle+(theta/2))*blCorner/Math.cos(theta/2));
		cy = y+h-blCorner+(Math.sin(angle+(theta/2))*blCorner/Math.cos(theta/2));
		px = x+blCorner+(Math.cos(angle+theta)*blCorner);
		py = y+h-blCorner+(Math.sin(angle+theta)*blCorner);
		this.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x+blCorner+(Math.cos(angle+(theta/2))*blCorner/Math.cos(theta/2));
		cy = y+h-blCorner+(Math.sin(angle+(theta/2))*blCorner/Math.cos(theta/2));
		px = x+blCorner+(Math.cos(angle+theta)*blCorner);
		py = y+h-blCorner+(Math.sin(angle+theta)*blCorner);
		this.curveTo(cx, cy, px, py);
		
		// draw left line
		this.lineTo(x, y+tlCorner);
		
		// draw tl corner
		angle += theta;
		cx = x+tlCorner+(Math.cos(angle+(theta/2))*tlCorner/Math.cos(theta/2));
		cy = y+tlCorner+(Math.sin(angle+(theta/2))*tlCorner/Math.cos(theta/2));
		px = x+tlCorner+(Math.cos(angle+theta)*tlCorner);
		py = y+tlCorner+(Math.sin(angle+theta)*tlCorner);
		this.curveTo(cx, cy, px, py);
		angle += theta;
		cx = x+tlCorner+(Math.cos(angle+(theta/2))*tlCorner/Math.cos(theta/2));
		cy = y+tlCorner+(Math.sin(angle+(theta/2))*tlCorner/Math.cos(theta/2));
		px = x+tlCorner+(Math.cos(angle+theta)*tlCorner);
		py = y+tlCorner+(Math.sin(angle+theta)*tlCorner);
		this.curveTo(cx, cy, px, py);
	} else {
		// cornerRadius was not defined or = 0. This makes it easy.
		this.moveTo(x, y);
		this.lineTo(x+w, y);
		this.lineTo(x+w, y+h);
		this.lineTo(x, y+h);
		this.lineTo(x, y);
	}
};