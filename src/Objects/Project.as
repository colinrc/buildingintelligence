package Objects
{
	import flash.events.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("project")]
	[RemoteClass(alias="elifeAdmin.objects.server.project")]
	public class Project extends EventDispatcher implements IExternalizable
	{
		[Bindable]
		public var path:String="";
		[Bindable]
		public var project:String="";
		[Bindable]
		public var job:String="";
		[Bindable]
		public var client_name:String="";
		[Bindable]
		public var client_address:String="";
		[Bindable]
		public var integrator:String="";
		[Bindable]
		public var company:String="";
		[Bindable]
		public var company_address:String="";
		[Bindable]
		public var phone:String="";
		[Bindable]
		public var fax:String="";
		[Bindable]
		public var mobile:String="";
		[Bindable]
		public var email:String="";
		[Bindable]
		public var notes:String="";
		
		
		public function writeExternal(output:IDataOutput):void {
			
			output.writeUTF(path);
			output.writeUTF(project);
			output.writeUTF(job);
			output.writeUTF(client_name);
			output.writeUTF(client_address);
			output.writeUTF(integrator);
			output.writeUTF(company);
			output.writeUTF(company_address);
			output.writeUTF(phone);
			output.writeUTF(fax);
			output.writeUTF(mobile);
			output.writeUTF(email);
			output.writeUTF(notes);
		}
		
		public function readExternal(input:IDataInput):void {
			
			
			path = input.readUTF()as String;
			project = input.readUTF()as String;
			job = input.readUTF()as String;
			client_name = input.readUTF()as String;
			client_address = input.readUTF()as String;
			integrator = input.readUTF()as String;
			company = input.readUTF()as String;
			company_address = input.readUTF()as String;
			phone = input.readUTF()as String;
			fax = input.readUTF()as String;
			mobile = input.readUTF()as String;
			email = input.readUTF()as String;
			notes = input.readUTF()as String;
		}
		
		
		public function Project(project_xml:XML):void {
			path = project_xml.@path;
			project= project_xml.@project;
			job= project_xml.@job;
			client_name= project_xml.@client_name;
			client_address= project_xml.@client_address;
			integrator= project_xml.@integrator;
			company= project_xml.@company;
			company_address= project_xml.@company_address;
			phone= project_xml.@phone;
			fax= project_xml.@fax;
			mobile= project_xml.@mobile;
			email= project_xml.@email;
			notes= project_xml.@notes;
		}
	}
}