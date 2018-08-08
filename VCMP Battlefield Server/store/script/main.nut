function errorHandling(err)
{
	local stackInfos = getstackinfos(2);
	if (stackInfos)
	{
		local locals = "";
		foreach(index, value in stackInfos.locals)
		{
			if (index != "this")
				locals = locals + "[" + index + "] " + value + "\n";
		}
		local callStacks = "";
		local level = 2;
		do {
			callStacks += "*FUNCTION [" + stackInfos.func + "()] " + stackInfos.src + " line [" + stackInfos.line + "]\n";
			level++;
		} while ((stackInfos = getstackinfos(level)));

		local errorMsg = "AN ERROR HAS OCCURRED [" + err + "]\n";
		errorMsg += "\nCALLSTACK\n";
		errorMsg += callStacks;
		errorMsg += "\nLOCALS\n";
	}
	errorMsg += locals;
	Console.Print(errorMsg);
}

seterrorhandler(errorHandling);

Timer <- {
 Timers = {}

 function Create(environment, listener, interval, repeat, ...)
 {
  // Prepare the arguments pack
  vargv.insert(0, environment);

  // Store timer information into a table
  local TimerInfo = {
   Environment = environment,
   Listener = listener,
   Interval = interval,
   Repeat = repeat,
   Args = vargv,
   LastCall = Script.GetTicks(),
   CallCount = 0
  };

  local hash = split(TimerInfo.tostring(), ":")[1].slice(3, -1).tointeger(16);
  // Store the timer information
  Timers.rawset(hash, TimerInfo);

  // Return the hash that identifies this timer
  return hash;
 }

 function Destroy(hash)
 {
  // See if the specified timer exists
  if (Timers.rawin(hash))
  {
   // Remove the timer information
   Timers.rawdelete(hash);
  }
 }

 function Exists(hash)
 {
  // See if the specified timer exists
  return Timers.rawin(hash);
 }

 function Fetch(hash)
 {
  // Return the timer information
  return Timers.rawget(hash);
 }

 function Clear()
 {
  // Clear existing timers
  Timers.clear();
 }

 function Process()
 {
  local CurrTime = Script.GetTicks();
  foreach (hash, tm in Timers)
  {
   if (tm != null)
   {
    if (CurrTime - tm.LastCall >= tm.Interval)
    {
     tm.CallCount++;
     tm.LastCall = CurrTime;

     tm.Listener.pacall(tm.Args);

     if (tm.Repeat != 0 && tm.CallCount >= tm.Repeat)
      Timers.rawdelete(hash);
    }
   }
  }
 }
};

sX <- GUI.GetScreenSize().X;
sY <- GUI.GetScreenSize().Y;

function Script::ScriptLoad()
{
}

function Script::ScriptProcess()
{
	Timer.Process();
}

function Server::ServerData( stream )
{
	local StreamInt = stream.ReadInt(), StreamString = stream.ReadString();
	switch( StreamInt.tointeger() )
	{
		case 1:
			if( StreamString == "intro_start" ) IntroScreen();
			else if( StreamString == "intro_end" ) LoginScreen();
			else if( StreamString == "intro_delete" ) DeleteIntroScreen();
		break;
		case 2:
			if( StreamString == "acc_created" ) Dialog( "Your account has been created and registered. Please log-in to continue.", true );
		break;
		case 3:
			if( StreamString == "acc_login" ) Dialog( "You've been logged in successfully.", true );
			else if( StreamString == "acc_login_failed" ) ErrorDialog( "Incorrect password." );
		break;
	}
}

Intro <- {
	BlackScreen = null,
	WhiteScreen = null,
	BFWallpaper = null,
	BFLogo = null,
	Timer = null
}

function IntroScreen()
{
	Hud.RemoveFlags( HUD_FLAG_CASH | HUD_FLAG_CLOCK | HUD_FLAG_HEALTH | HUD_FLAG_WEAPON | HUD_FLAG_WANTED | HUD_FLAG_RADAR );
	Intro.BFWallpaper = GUISprite( "VCMP Battlefield Background.png", VectorScreen( 0, 0 ) );
	Intro.BFWallpaper.Size = VectorScreen( sX, sY );
	Intro.BFLogo = GUISprite( "VCMP Battlefield Logo.png", VectorScreen( 0, 0 ) );
	Intro.BFLogo.Alpha = 0;
	Intro.BFLogo.Size = VectorScreen( 540, 360 );
	Intro.BlackScreen = GUISprite( "Black screen.jpg", VectorScreen( 0, 0 ) );
	Intro.BlackScreen.Size = VectorScreen( sX, sY );
	Intro.Timer = Timer.Create( this, FadeOutBlackScreen, 100, 0 );
}

function FadeOutBlackScreen()
{
	Intro.BlackScreen.Alpha -= 4;
	if( Intro.BlackScreen.Alpha < 2 )
	{
		RandomizeBFLogo();
		Timer.Destroy( Intro.Timer );
		Intro.BlackScreen.Alpha = 0;
	}
}

function CreateWhiteScreen()
{
	Intro.WhiteScreen = GUISprite( "White Screen.jpg", VectorScreen( 0, 0 ) );
	Intro.WhiteScreen.Size = VectorScreen( sX, sY );
	Intro.WhiteScreen.Alpha = 127.5;
}

function RemoveWhiteScreen() if( Intro.WhiteScreen != null ) Intro.WhiteScreen = null;

function RandomizeBFLogo( num = 1 )
{
	if( Intro.BFLogo )
	{
		switch( num )
		{
			case 1:
				CreateWhiteScreen();
				Intro.BFLogo.Alpha = 42.5;
				Intro.BFLogo.Position = VectorScreen( ( sX * 0.60 ), ( sY * 0.40 ) );
				Timer.Create( this, RemoveWhiteScreen, 100, 1 );
				Timer.Create( this, RandomizeBFLogo, 200, 1, 2 );
			break;
			case 2:
				CreateWhiteScreen();
				Intro.BFLogo.Alpha = 85;
				Intro.BFLogo.Position = VectorScreen( ( sX * 0.20 ), ( sY * 0.60 ) );
				Timer.Create( this, RemoveWhiteScreen, 100, 1 );
				Timer.Create( this, RandomizeBFLogo, 200, 1, 3 );
			break;
			case 3:
				CreateWhiteScreen();
				Intro.BFLogo.Alpha = 127.5;
				Intro.BFLogo.Position = VectorScreen( ( sX * 0.45 ), ( sY * 0.80 ) );
				Timer.Create( this, RemoveWhiteScreen, 100, 1 );
				Timer.Create( this, RandomizeBFLogo, 200, 1, 4 );
			break;
			case 4:
				CreateWhiteScreen();
				Intro.BFLogo.Alpha = 170;
				Intro.BFLogo.Position = VectorScreen( ( sX * 0.60 ), ( sY * 0.40 ) );
				Timer.Create( this, RemoveWhiteScreen, 100, 1 );
				Timer.Create( this, RandomizeBFLogo, 200, 1, 5 );
			break;
			case 5:
				CreateWhiteScreen();
				Intro.BFLogo.Alpha = 212.5;
				Intro.BFLogo.Position = VectorScreen( ( sX * 0.20 ), ( sY * 0.60 ) );
				Timer.Create( this, RemoveWhiteScreen, 100, 1 );
				Timer.Create( this, RandomizeBFLogo, 200, 1, 6 );
			break;
			case 6:
				CreateWhiteScreen();
				Intro.BFLogo.Alpha = 255;
				Intro.BFLogo.Position = VectorScreen( ( sX * 0.25 ), ( sY * 0.3 ) );
				Timer.Create( this, RemoveWhiteScreen, 100, 1 );
				SendDataToServer( "intro_ended", 1 );
			break;
		}
	}
}

AccountSys <- {
	LoginButton = null,
	RegisterButton = null,
	Wind = null,
	FilterBox = null,
	FilterBox2 = null,
	//Pwd = null,
	//CPwd = null,
	LoginB = null,
	RegisterB = null,
	ErrorD_Wind = null,
	ErrorD_Label = null,
	Dialog_Wind = null,
	Dialog_Label = null,
	Dialog_WIcon = null
}

function LoginScreen()
{
	GUI.SetMouseEnabled( true );
	AccountSys.LoginButton = GUIButton( VectorScreen( ( sX * 0.25 ), ( sY * 0.7 ) ), VectorScreen( 200, 80 ), Colour( 205, 230, 255 ), "Login" );
	AccountSys.RegisterButton = GUIButton( VectorScreen( ( sX * 0.55 ), ( sY * 0.7 ) ), VectorScreen( 200, 80 ), Colour( 205, 230, 255 ), "Register" );
}

function DeleteIntroScreen()
{
	Intro.BFWallpaper = null;
	Intro.BFLogo = null;
	Intro.BlackScreen = 0;
	AccountSys.LoginButton = null;
	AccountSys.LoginB = null;
	AccountSys.RegisterButton = null;
	AccountSys.RegisterB = null;
	AccountSys.Wind = null;
	AccountSys.Dialog_Wind = null;
	Hud.AddFlags( HUD_FLAG_RADAR );
	GUI.SetMouseEnabled( false );
}

function ErrorDialog( text )
{
	Intro.BlackScreen.Alpha = 127.5;
	if( AccountSys.RegisterB != null ) AccountSys.RegisterB.Alpha = 127.5;
	else if( AccountSys.LoginB != null ) AccountSys.LoginB.Alpha = 127.5;
	AccountSys.ErrorD_Wind = GUIWindow( VectorScreen( ( sX / 3.5 ), ( sY / 3.5 ) ), VectorScreen( 400, 160 ), Colour( 123, 123, 122 ), "Error!" );
	AccountSys.ErrorD_Wind.RemoveFlags( GUI_FLAG_DRAGGABLE );
	AccountSys.ErrorD_Label = GUILabel( VectorScreen( 30, 15 ), Colour( 255, 255, 255 ), text );
	if( AccountSys.ErrorD_Label.Text.len() < 12 ) AccountSys.Dialog_Label.FontSize = 15;
	else AccountSys.ErrorD_Label.FontSize = 10;
	AccountSys.ErrorD_Wind.AddChild( AccountSys.ErrorD_Label );
}

function Dialog( text, btn = false, waiticon = false )
{
	Intro.BlackScreen.Alpha = 127.5;
	if( AccountSys.RegisterB != null ) AccountSys.RegisterB.Alpha = 127.5;
	else if( AccountSys.LoginB != null ) AccountSys.LoginB.Alpha = 127.5;
	AccountSys.Dialog_Wind = GUIWindow( VectorScreen( ( sX / 3.5 ), ( sY / 3.5 ) ), VectorScreen( 400, 160 ), Colour( 123, 123, 122 ), "Message" );
	AccountSys.Dialog_Wind.RemoveFlags( GUI_FLAG_DRAGGABLE );
	if( btn == false ) AccountSys.Dialog_Wind.RemoveFlags( GUI_FLAG_WINDOW_CLOSEBTN );
	AccountSys.Dialog_Label = GUILabel( VectorScreen( 30, 15 ), Colour( 255, 255, 255 ), text );
	if( AccountSys.Dialog_Label.Text.len() < 12 ) AccountSys.Dialog_Label.FontSize = 15;
	else AccountSys.Dialog_Label.FontSize = 10;
	/*
	if( waiticon == true )
	{
		AccountSys.Dialog_WIcon = GUIProgressBar( VectorScreen( ( sX / 3 ), ( sY / 3.5 ), VectorScreen( 50, 50 ), Colour( 205, 230, 255 ), Colour( 170, 191, 213 ) );
		AccountSys.Dialog_WIcon.MaxValue = 
	}
	*/
	AccountSys.Dialog_Wind.AddChild( AccountSys.Dialog_Label );
}

function GUI::ElementClick( element, mouseX, mouseY )
{
	//Console.Print( element );
	if( element == AccountSys.RegisterButton && AccountSys.Wind == null )
	{
		AccountSys.RegisterButton.Alpha = 127.5;
		AccountSys.LoginButton.Alpha = 127.5;
		AccountSys.Wind = GUIWindow( VectorScreen( ( sX / 3.5 ), ( sY / 3.5 ) ), VectorScreen( 400, 160 ), Colour( 123, 123, 122 ), "Register Now To Fight In The Battlefield!" );
		AccountSys.Wind.RemoveFlags( GUI_FLAG_DRAGGABLE );
		AccountSys.FilterBox = GUIEditbox( VectorScreen( 50, 15 ), VectorScreen( 300, 30 ), Colour( 255, 255, 255 ), "Password" );
		AccountSys.FilterBox2 = GUIEditbox( VectorScreen( 50, 55 ), VectorScreen( 300, 30 ), Colour( 255, 255, 255 ), "Confirm Password" );
		AccountSys.RegisterB = GUIButton( VectorScreen( 150, 90 ), VectorScreen( 70, 40 ), Colour( 205, 230, 255 ), "Register" );
		AccountSys.Wind.AddChild( AccountSys.FilterBox );
		AccountSys.Wind.AddChild( AccountSys.FilterBox2 );
		AccountSys.Wind.AddChild( AccountSys.RegisterB );
	}
	else if( element == AccountSys.LoginButton && AccountSys.Wind == null )
	{
		AccountSys.RegisterButton.Alpha = 127.5;
		AccountSys.LoginButton.Alpha = 127.5;
		AccountSys.Wind = GUIWindow( VectorScreen( ( sX / 3.5 ), ( sY / 3.5 ) ), VectorScreen( 400,150 ), Colour( 123, 123, 122 ), "Login Now!" );
		AccountSys.Wind.RemoveFlags( GUI_FLAG_DRAGGABLE );
		AccountSys.FilterBox = GUIEditbox( VectorScreen( 50, 20 ), VectorScreen( 300, 30 ), Colour( 255, 255, 255 ), "Password" );
		AccountSys.LoginB = GUIButton( VectorScreen( 150, 70 ), VectorScreen( 70, 40 ), Colour( 205, 230, 255 ), "Login" );
		AccountSys.Wind.AddChild( AccountSys.FilterBox );
		AccountSys.Wind.AddChild( AccountSys.LoginB );
	}
	else if( element == AccountSys.FilterBox && AccountSys.FilterBox.Text == "Password" )
	{
		AccountSys.FilterBox.Text = "";
		AccountSys.FilterBox.AddFlags( GUI_FLAG_EDITBOX_MASKINPUT );
	}
	else if( element == AccountSys.FilterBox2 && AccountSys.FilterBox2.Text == "Confirm Password" )
	{
		AccountSys.FilterBox2.Text = "";
		AccountSys.FilterBox2.AddFlags( GUI_FLAG_EDITBOX_MASKINPUT );
	}
	else if( element == AccountSys.RegisterB )
	{
		if( AccountSys.FilterBox.Text.len() == 0 ) ErrorDialog( "You must enter a password to continue." );
		else if( AccountSys.FilterBox.Text.len() > 0 && AccountSys.FilterBox.Text.len() < 7 ) ErrorDialog( "Your password must be more than 7 characters." );
		else if( AccountSys.FilterBox2.Text.len() == 0 ) ErrorDialog( "You must confirm the password to continue." );
		else if( AccountSys.FilterBox.Text != AccountSys.FilterBox2.Text ) ErrorDialog( "Both passwords do not match." );
		else
		{
			Dialog( "Please wait..." );
			Timer.Create( this, SendDataToServer, 2000, 1, AccountSys.FilterBox.Text, 2 );
		}
	}
	else if( element == AccountSys.LoginB )
	{
		if( AccountSys.FilterBox.Text.len() == 0 ) ErrorDialog( "You must enter your password to continue." );
		else
		{
			Dialog( "Please wait..." );
			Timer.Create( this, SendDataToServer, 2000, 1, AccountSys.FilterBox.Text, 3 );
		}
	}
}

function GUI::WindowClose( window )
{
	if( window == AccountSys.Wind )
	{
		AccountSys.Wind = null;
		AccountSys.RegisterButton.Alpha = 255;
		AccountSys.LoginButton.Alpha = 255;
	}
	else if( window == AccountSys.ErrorD_Wind )
	{
		AccountSys.ErrorD_Wind = null;
		if( AccountSys.Dialog_Wind != null ) AccountSys.Dialog_Wind = null;
		if( AccountSys.RegisterB != null ) AccountSys.RegisterB.Alpha = 255;
		else if( AccountSys.LoginB != null ) AccountSys.LoginB.Alpha = 255;
		Intro.BlackScreen.Alpha = 0;
	}
	else if( window == AccountSys.Dialog_Wind )
	{
		AccountSys.Dialog_Wind = null;
		if( AccountSys.RegisterB != null || AccountSys.LoginB != null ) AccountSys.Wind = null;
		AccountSys.RegisterButton.Alpha = 255;
		AccountSys.LoginButton.Alpha = 255;
		Intro.BlackScreen.Alpha = 0;
	}
}

function SendDataToServer( str, int )
{
	local message = Stream();
	message.WriteInt( int.tointeger() );
	message.WriteString( str );
	Server.SendData( message );
}