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
::Health <- null;

function Script::ScriptLoad()
{
}

function Script::ScriptProcess()
{
	Timer.Process();
	if( HUD.Left.Radar_Window != null )
	{
		local plr = World.FindLocalPlayer();
		if( plr.Health.tointeger() > 66 && plr.Health.tointeger() < 99 ) ::Health = GUISprite( "Bf4_bloodsplatter1.png", VectorScreen( 0, 0 ) );
		else if( plr.Health.tointeger() > 33 && plr.Health.tointeger() < 66 ) ::Health = GUISprite( "Bf4_bloodsplatter2.png", VectorScreen( 0, 0 ) );
		else ::Health = GUISprite( "Bf4_bloodsplatter3.png", VectorScreen( 0, 0 ) );
		if( ::Health != null )
		{
			::Health.Size = VectorScreen( sX, sY );
			local alph = ( 100 - plr.Health.tointeger() ) + 40;
			if( alph == 40 ) ::Health.Alpha = 0;
			else if( alph == 140 ) ::Health = null;
			else ::Health.Alpha = alph;
		}	
	}
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
			else if( StreamString == "acc_create_failed" ) ErrorDialog( "This account has already been created. Please log-in to continue." );
		break;
		case 3:
			if( StreamString == "acc_login" ) Dialog( "You've been logged in successfully." );
			else if( StreamString == "acc_login_failed" ) ErrorDialog( "Incorrect password." );
			else if( StreamString == "acc_notexists" ) ErrorDialog( "This account does not exists. Please register to create one." );
		break;
		case 4: 
			local params = split( StreamString, "," ), idx = params[0], val = params[1];
			if( idx == "create" ) CreateHUD( val );
			else if( idx == "update" )
			{
				if( HUD.Right.Weapon != null ) HUD.Right.Weapon.Text = val;
			}
		break;
		case 5:
			AddDeathLogLine( StreamString );
		break;
		case 6: 
			RemoveHUD();
		break;
	}
}

function Player::PlayerShoot( player, weapon, hitEntity, hitPosition )
{
	//Console.Print( ""+ player.Name +" attacking with weapon "+ weapon +"." );
}

function GUIFadeIn( spr, alph = 25 )
{
	spr.Alpha -= alph;
	if( spr.Alpha < 2 ) spr.Alpha = 0;
	else
	{
		if( alph != 25 ) Timer.Create( this, SpriteFadeIn, 100, 1, spr, alph );
		else Timer.Create( this, SpriteFadeIn, 100, 1, spr );
	}
}

function GUIFadeOut( spr, alph = 25 )
{
	spr.Alpha -= alph;
	if( spr.Alpha < 2 ) spr.Alpha = 0;
	else
	{
		if( alph != 25 ) Timer.Create( this, SpriteFadeOut, 100, 1, spr, alph );
		else Timer.Create( this, SpriteFadeOut, 100, 1, spr );
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

function DeleteIntroScreen()
{
	Intro.BFWallpaper = null;
	Intro.BFLogo = null;
	Intro.BlackScreen = 0;
	AccountSys.LoginB = null;
	AccountSys.RegisterB = null;
	AccountSys.Wind = null;
	AccountSys.Dialog_Wind = null;
	GUI.SetMouseEnabled( false );
}

AccountSys <- {
	LoginButton = null,
	RegisterButton = null,
	Wind = null,
	FilterBox = null,
	FilterBox2 = null,
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

function ErrorDialog( text )
{
	Intro.BlackScreen.Alpha = 127.5;
	if( AccountSys.RegisterB != null ) AccountSys.RegisterB.Alpha = 127.5;
	else if( AccountSys.LoginB != null ) AccountSys.LoginB.Alpha = 127.5;
	AccountSys.ErrorD_Wind = GUIWindow( VectorScreen( ( sX / 3.5 ), ( sY / 3.5 ) ), VectorScreen( 400, 160 ), Colour( 123, 123, 122 ), "Error!" );
	AccountSys.ErrorD_Wind.RemoveFlags( GUI_FLAG_DRAGGABLE | GUI_FLAG_WINDOW_RESIZABLE );
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
	AccountSys.Dialog_Wind.RemoveFlags( GUI_FLAG_DRAGGABLE | GUI_FLAG_WINDOW_RESIZABLE );
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
	if( AccountSys.Dialog_Label.Text == "You've been logged in successfully." )
	{	
		AccountSys.LoginButton = null;
		AccountSys.RegisterButton = null;
	}
}

GameKeys <- {
	One = "Bf4_key1.png",
	Two = "Bf4_key2.png",
	Three = "Bf4_key3.png",
	Four = "Bf4_key4.png",
	Five = "Bf4_key5.png",
	Six = "Bf4_key6.png",
	Seven = "Bf4_key7.png",
	Eight = "Bf4_key8.png",
	Nine = "Bf4_key9.png",
	Zero = "Bf4_key0.png",
	Q = "Bf4_keyQ.png",
	W = "Bf4_keyW.png",
	E = "Bf4_keyE.png",
	R = "Bf4_keyR.png",
	T = "Bf4_keyT.png",
	Y = "Bf4_keyY.png",
	U = "Bf4_keyU.png",
	I = "Bf4_keyI.png",
	O = "Bf4_keyO.png",
	P = "Bf4_keyP.png",
	A = "Bf4_keyA.png",
	S = "Bf4_keyS.png",
	D = "Bf4_keyD.png",
	F = "Bf4_keyF.png",
	G = "Bf4_keyG.png",
	H = "Bf4_keyH.png",
	J = "Bf4_keyJ.png",
	K = "Bf4_keyK.png",
	L = "Bf4_keyL.png",
	Z = "Bf4_keyZ.png",
	X = "Bf4_keyX.png",
	C = "Bf4_keyC.png",
	V = "Bf4_keyV.png",
	B = "Bf4_keyB.png",
	N = "Bf4_keyN.png",
	M = "Bf4_keyM.png"
}

HUD <- {
	Right = {
		Weapon = null
	},
	Middle = {
		ButtonW1 = null,
		ButtonW2 = null,
		ButtonW3 = null,
		ButtonW4 = null,
		Lethal = null,
		Tactical = null,
		Melee = null,
		Button1 = null,
		Button2 = null,
		Button3 = null,
		Button4 = null
	},
	Left = {
		Radar_Window = null,
		Timer = null,
		Team1 = null,
		Team2 = null,
		Tickets_1 = null,
		Tickets_2 = null,
		Tickets = null,
		Tickets2 = null,
		ObjectivePoints = {
			Obj1 = null,
			Obj2 = null,
			Obj3 = null,
			Obj4 = null,
			Obj5 = null
		}
	}
}

DeathLog <- {
	CurrentLines = 4,
	MaxLines = 10,
	TextSize = 30,
	Font = "Purista Bold",
	Messages = [],
	Msgs = [ "empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty" ]
}

function CreateHUD( strread )
{
	Hud.AddFlags( HUD_FLAG_RADAR | HUD_FLAG_HEALTH | HUD_FLAG_WEAPON );
	HUD.Right.Weapon = GUILabel( VectorScreen( ( sX * 0.68 ), ( sY * 0.1 ) ), Colour( 227, 246, 255 ), strread );
	HUD.Right.Weapon.FontName = "Purista Bold";
	HUD.Right.Weapon.FontSize = 20;
	HUD.Right.Weapon.FontFlags = GUI_FFLAG_OUTLINE;
	//====================================================================================================================================
	HUD.Middle.ButtonW1 = GUIWindow( VectorScreen( ( sX * 0.45 ), ( sY * 0.8 ) ), VectorScreen( 100, 50 ), Colour( 47, 46, 44 ), "" );
	HUD.Middle.ButtonW1.RemoveFlags( GUI_FLAG_WINDOW_TITLEBAR | GUI_FLAG_WINDOW_CLOSEBTN | GUI_FLAG_WINDOW_RESIZABLE | GUI_FLAG_SHADOW );
	HUD.Middle.ButtonW1.Alpha = 170;
	HUD.Middle.ButtonW2 = GUIWindow( VectorScreen( ( sX * 0.45 ), ( sY * 0.9 ) ), VectorScreen( 100, 50 ), Colour( 47, 46, 44 ), "" );
	HUD.Middle.ButtonW2.RemoveFlags( GUI_FLAG_WINDOW_TITLEBAR | GUI_FLAG_WINDOW_CLOSEBTN | GUI_FLAG_WINDOW_RESIZABLE | GUI_FLAG_SHADOW );
	HUD.Middle.ButtonW2.Alpha = 170;
	HUD.Middle.ButtonW3 = GUIWindow( VectorScreen( ( sX * 0.35 ), ( sY * 0.85 ) ), VectorScreen( 100, 50 ), Colour( 47, 46, 44 ), "" );
	HUD.Middle.ButtonW3.RemoveFlags( GUI_FLAG_WINDOW_TITLEBAR | GUI_FLAG_WINDOW_CLOSEBTN | GUI_FLAG_WINDOW_RESIZABLE | GUI_FLAG_SHADOW );
	HUD.Middle.ButtonW3.Alpha = 170;
	HUD.Middle.ButtonW4 = GUIWindow( VectorScreen( ( sX * 0.55 ), ( sY * 0.85 ) ), VectorScreen( 100, 50 ), Colour( 47, 46, 44 ), "" );
	HUD.Middle.ButtonW4.RemoveFlags( GUI_FLAG_WINDOW_TITLEBAR | GUI_FLAG_WINDOW_CLOSEBTN | GUI_FLAG_WINDOW_RESIZABLE | GUI_FLAG_SHADOW );
	HUD.Middle.ButtonW4.Alpha = 170;
	//====================================================================================================================================
	Game.Gamemode = "Rush";
	HUD.Left.Radar_Window = GUIWindow( VectorScreen( ( sX * 0.035 ), ( sY * 0.60 ) ), VectorScreen( 161, 250 ), Colour( 47, 46, 44 ), "" );
	HUD.Left.Radar_Window.RemoveFlags( GUI_FLAG_WINDOW_TITLEBAR | GUI_FLAG_WINDOW_CLOSEBTN | GUI_FLAG_WINDOW_RESIZABLE | GUI_FLAG_BORDER | GUI_FLAG_SHADOW );
	HUD.Left.Radar_Window.Alpha = 170;
	HUD.Left.ObjectivePoints.Obj1 = GUISprite( "Bf4_A.png", VectorScreen( 5, 10 ) );
	HUD.Left.ObjectivePoints.Obj1.Size = VectorScreen( 30, 30 );
	HUD.Left.ObjectivePoints.Obj2 = GUISprite( "Bf4_B.png", VectorScreen( 35, 10 ) );
	HUD.Left.ObjectivePoints.Obj2.Size = VectorScreen( 30, 30 );
	HUD.Left.ObjectivePoints.Obj3 = GUISprite( "Bf4_C.png", VectorScreen( 65, 10 ) );
	HUD.Left.ObjectivePoints.Obj3.Size = VectorScreen( 30, 30 );
	HUD.Left.ObjectivePoints.Obj4 = GUISprite( "Bf4_D.png", VectorScreen( 95, 10 ) );
	HUD.Left.ObjectivePoints.Obj4.Size = VectorScreen( 30, 30 );
	HUD.Left.ObjectivePoints.Obj5 = GUISprite( "Bf4_E.png", VectorScreen( 125, 10 ) );
	HUD.Left.ObjectivePoints.Obj5.Size = VectorScreen( 30, 30 );
	HUD.Left.Timer = GUILabel( VectorScreen( 55, 70 ), Colour( 255, 255, 255 ), Game.Time );
	HUD.Left.Timer.FontSize = 17;
	HUD.Left.Team1 = GUILabel( VectorScreen( 2, 50 ), Colour( 0, 206, 247 ), Game.Team1 );
	HUD.Left.Team1.FontSize = 10;
	HUD.Left.Team2 = GUILabel( VectorScreen( 130, 50 ), Colour( 244, 159, 0 ), Game.Team2 );
	HUD.Left.Team2.FontSize = 10;
	if( Game.Gamemode == "Rush" ) 
	{ 
		HUD.Left.Tickets_2 = GUIProgressBar( VectorScreen( 30, 50 ), VectorScreen( 100, 15 ), Colour( 214, 169, 0 ), Colour( 244, 159, 0 ) ); 
		HUD.Left.Tickets_2.MaxValue = 500;
		HUD.Left.Tickets_2.Value = 500;
		Game.Tickets2 = ""+HUD.Left.Tickets_2.Value+"";
		HUD.Left.Tickets = GUILabel( VectorScreen( 2, 70 ), Colour( 0, 206, 247 ), ""+ Game.Tickets +"" );
		HUD.Left.Tickets.FontSize = 17;
		HUD.Left.Tickets2 = GUILabel( VectorScreen( 110, 70 ), Colour( 244, 159, 0 ), ""+ Game.Tickets2 +"" );
		HUD.Left.Tickets2.FontSize = 17;
	}
	HUD.Left.Radar_Window.AddChild( HUD.Left.ObjectivePoints.Obj1 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.ObjectivePoints.Obj2 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.ObjectivePoints.Obj3 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.ObjectivePoints.Obj4 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.ObjectivePoints.Obj5 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.Timer );
	HUD.Left.Radar_Window.AddChild( HUD.Left.Team1 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.Team2 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.Tickets_2 );
	HUD.Left.Radar_Window.AddChild( HUD.Left.Tickets );
	HUD.Left.Radar_Window.AddChild( HUD.Left.Tickets2 );
}

function AddDeathLogLine( str )
{
	DeathLog.Messages.push( str );
	local maxLines = DeathLog.MaxLines, _array = DeathLog.Messages, chatbox = DeathLog.Msgs;
	for( local i = 0; i < _array.len(); i++ )
	{
		if( i <= DeathLog.CurrentLines )
		{
			if( chatbox[i] == "empty" )
			{
				chatbox[i] = GUILabel();
				if( i > 0 && chatbox[0] != "empty" ) chatbox[i].Position = VectorScreen( chatbox[0].Position.X, chatbox[i-1].Position.Y + 20 );
				else chatbox[i].Position = VectorScreen( ( sX * 0.7 ), ( sY * 0.3 ) );
				chatbox[i].Colour = Colour( 255, 255, 255 );
				chatbox[i].FontName = DeathLog.Font;
				chatbox[i].FontSize = DeathLog.TextSize;
				chatbox[i].AddFlags( GUI_FLAG_TEXT_TAGS );
				chatbox[i].Text = _array[i];
				break;
			}
		}
		else
		{
			local line1 = _array[i-5], line2 = _array[i-4], line3 = _array[i-3], line3 = _array[i-2], line4 = _array[i-1];
			chatbox[4].Text = _array[i]; // 5th line
			chatbox[3].Text = line4; // 4th line
			chatbox[2].Text = line3; // 3rd line
			chatbox[1].Text = line2; // 2nd line
			chatbox[0].Text = line1; // 1st line
		}
	}
}

function RemoveHUD()
{
	if( HUD.Right.Weapon != null )
	{
		HUD.Right.Weapon = null;
		HUD.Middle.ButtonW1 = null;
		HUD.Middle.ButtonW2 = null;
		HUD.Middle.ButtonW3 = null;
		HUD.Middle.ButtonW4 = null;
		::Health = null;
		Hud.RemoveFlags( HUD_FLAG_HEALTH | HUD_FLAG_WEAPON );
	}
}

Game <- {
	Gamemode_Label = null,
	Team1_Label = null,
	Team2_Label = null,
	Gamemode = "None",
	Team1 = "N/A",
	Team2 = "N/A",
	Time = "0:00",
	Tickets = "INF",
	Tickets2 = "INF"
}

function GUI::ElementClick( element, mouseX, mouseY )
{
	//Console.Print( element );
	if( element == AccountSys.RegisterButton && AccountSys.Wind == null )
	{
		AccountSys.RegisterButton.Alpha = 127.5;
		AccountSys.LoginButton.Alpha = 127.5;
		AccountSys.Wind = GUIWindow( VectorScreen( ( sX / 3.5 ), ( sY / 3.5 ) ), VectorScreen( 400, 160 ), Colour( 123, 123, 122 ), "Register Now To Fight In The Battlefield!" );
		AccountSys.Wind.RemoveFlags( GUI_FLAG_DRAGGABLE | GUI_FLAG_WINDOW_RESIZABLE );
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
		AccountSys.Wind.RemoveFlags( GUI_FLAG_DRAGGABLE | GUI_FLAG_WINDOW_RESIZABLE );
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

seterrorhandler(errorHandling);
