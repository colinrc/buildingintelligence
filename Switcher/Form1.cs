using System;
using System.Drawing;
using System.Collections;
using System.Windows.Forms;
using System.Data;
using System.Runtime.InteropServices;
using System.Text;



namespace ToolHelp
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.MainMenu mainMenu1;
		private System.Windows.Forms.MenuItem menuItem1;
		private System.Windows.Forms.MenuItem menuItem2;
		private System.Windows.Forms.ListBox lstProcess;
		private System.Windows.Forms.Label lblId;
		private System.Windows.Forms.Label lblThreadCount;
		private System.Windows.Forms.Label lblBaseAddress;
		private System.Windows.Forms.Button cmdEndTask;
		private System.Windows.Forms.Button cmdRefresh;
		
		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//Populate the process list
			lstProcess.DataSource = Process.GetProcesses();
		}
		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			base.Dispose( disposing );
		}
		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.mainMenu1 = new System.Windows.Forms.MainMenu();
			this.menuItem1 = new System.Windows.Forms.MenuItem();
			this.menuItem2 = new System.Windows.Forms.MenuItem();
			this.cmdEndTask = new System.Windows.Forms.Button();
			this.lstProcess = new System.Windows.Forms.ListBox();
			this.cmdRefresh = new System.Windows.Forms.Button();
			this.lblId = new System.Windows.Forms.Label();
			this.lblThreadCount = new System.Windows.Forms.Label();
			this.lblBaseAddress = new System.Windows.Forms.Label();
			// 
			// mainMenu1
			// 
			this.mainMenu1.MenuItems.Add(this.menuItem1);
			// 
			// menuItem1
			// 
			this.menuItem1.MenuItems.Add(this.menuItem2);
			this.menuItem1.Text = "File";
			// 
			// menuItem2
			// 
			this.menuItem2.Text = "Exit";
			this.menuItem2.Click += new System.EventHandler(this.menuItem2_Click);
			// 
			// cmdEndTask
			// 
			this.cmdEndTask.Location = new System.Drawing.Point(128, 232);
			this.cmdEndTask.Size = new System.Drawing.Size(99, 23);
			this.cmdEndTask.Text = "End Process";
			this.cmdEndTask.Click += new System.EventHandler(this.cmdEndTask_Click);
			// 
			// lstProcess
			// 
			this.lstProcess.Location = new System.Drawing.Point(14, 10);
			this.lstProcess.Size = new System.Drawing.Size(211, 100);
			this.lstProcess.SelectedIndexChanged += new System.EventHandler(this.lstProcess_SelectedIndexChanged);
			// 
			// cmdRefresh
			// 
			this.cmdRefresh.Location = new System.Drawing.Point(17, 232);
			this.cmdRefresh.Size = new System.Drawing.Size(72, 23);
			this.cmdRefresh.Text = "Refresh";
			this.cmdRefresh.Click += new System.EventHandler(this.cmdRefresh_Click);
			// 
			// lblId
			// 
			this.lblId.Location = new System.Drawing.Point(32, 134);
			this.lblId.Size = new System.Drawing.Size(168, 15);
			this.lblId.Text = "Process ID:";
			// 
			// lblThreadCount
			// 
			this.lblThreadCount.Location = new System.Drawing.Point(32, 165);
			this.lblThreadCount.Size = new System.Drawing.Size(170, 15);
			this.lblThreadCount.Text = "ThreadCount:";
			// 
			// lblBaseAddress
			// 
			this.lblBaseAddress.Location = new System.Drawing.Point(32, 197);
			this.lblBaseAddress.Size = new System.Drawing.Size(176, 15);
			this.lblBaseAddress.Text = "Base Address:";
			// 
			// Form1
			// 
			this.Controls.Add(this.lblBaseAddress);
			this.Controls.Add(this.lblThreadCount);
			this.Controls.Add(this.lblId);
			this.Controls.Add(this.cmdRefresh);
			this.Controls.Add(this.lstProcess);
			this.Controls.Add(this.cmdEndTask);
			this.Menu = this.mainMenu1;
			this.MinimizeBox = false;
			this.Text = "Task Manager";
			this.Paint += new System.Windows.Forms.PaintEventHandler(this.Form1_Paint);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>

		static void Main() 
		{
			Application.Run(new Form1());
		}

		private void cmdEndTask_Click(object sender, System.EventArgs e)
		{
			//Get selected process
			Process proc = (Process)lstProcess.SelectedItem;
			proc.Kill();
			//Refresh process list
			lstProcess.DataSource = null;
			lstProcess.DataSource = Process.GetProcesses();			
		}

		private void cmdRefresh_Click(object sender, System.EventArgs e)
		{
			lstProcess.DataSource = null;
			lstProcess.DataSource = Process.GetProcesses();			
		}

		private void menuItem2_Click(object sender, System.EventArgs e)
		{
			Application.Exit();
		}

		private void Form1_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
		{
			Rectangle rc = new Rectangle(8, 122, 224, 100);
			e.Graphics.DrawRectangle(new Pen(Color.Black), rc);
		}

		private void lstProcess_SelectedIndexChanged(object sender, System.EventArgs e)
		{
			//Get selected process
			Process proc = (Process)lstProcess.SelectedItem;
			//Populate labels
			lblId.Text = "Process ID: " + proc.Handle;
			lblThreadCount.Text = "Thread Count: " + proc.ThreadCount;
			lblBaseAddress.Text = "Base Address: " + proc.BaseAddess;
		}

	}
}

