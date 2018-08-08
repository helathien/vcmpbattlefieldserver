
class PlayerStats
{
	LastJoined = null;
	Password = null;
	Level = 0;
	UID = null;
	IP = null;
	LoggedIn = false;
	Registered = false;
	Banned = false;
	Clan = null;
	CRank = null;
	Kills = 0;
	Deaths = 0;
}

pCamera <- array( GetMaxPlayers() );

class CCamera
{
	function IsEnabled() { return bEnabled; }
	function Pos() { return vPos; }
	function Target() { return vTarget; }
	function _typeof() { return "CCamera"; }
	function Remove() { this.clear(); }
	vPos = Vector( 0.0, 0.0, 0.0 );
	vTarget = Vector( 0.0, 0.0, 0.0 );
	fYaw = 0.0;
	fPitch = 0.0;
	fSpeed = 1.5;
	Player = null;
	bEnabled = false;
	bMovingForward = null;
	bMovingLeft = null;
	bMovingBackward = null;
	bMovingRight = null;
	bRotatingUp = null;
	bRotatingLeft = null;
	bRotatingDown = null;
	bRotatingRight = null;
}

function CCamera::Enable()
{
	vPos = Player.Pos;
	fPitch = 0.0;
	fYaw = 0.0;
	Rotate( -1 * Player.Angle * PI/180.0, 0.0 );
	Player.SetCameraPos( vPos, vTarget );
	Player.Frozen = true;
	bEnabled = true;
}

function CCamera::Disable()
{
	Player.Pos = vPos;
	Player.Frozen = false;
	Player.RestoreCamera();
	bEnabled = false;
}

function CCamera::Rotate( fHoriz, fVert )
{
	fYaw += fHoriz;
	fPitch += fVert;
	vTarget.x = vPos.x + cos( fPitch ) * sin( fYaw );
	vTarget.y = vPos.y + cos( fPitch ) * cos( fYaw );
	vTarget.z = vPos.z + sin( fPitch );
}

function CCamera::Move( fDist )
{
	vPos.x += fDist * cos( fPitch ) * sin( fYaw );
	vPos.y += fDist * cos( fPitch ) * cos( fYaw );
	vPos.z += fDist * sin( fPitch );
	Rotate( 0.0, 0.0 );
}

function CCamera::MoveSideways( fDist )
{
	vPos.x += fDist * cos( fPitch ) * sin( fYaw + PI/2 );
	vPos.y += fDist * cos( fPitch ) * cos( fYaw + PI/2 );
	Rotate( 0.0, 0.0 );
}

function CCamera::Process()
{
	local bMoving = false;
	local fCamSpeed = fSpeed;
	if ( bMovingForward )
	{
		Move( fCamSpeed );
		bMoving = true;
	}
	if ( bMovingBackward )
	{
		Move( -fCamSpeed );
		bMoving = true;
	}
	if ( bMovingLeft )
	{
		MoveSideways( -fCamSpeed );
		bMoving = true;
	}
	if ( bMovingRight )
	{
		MoveSideways( fCamSpeed );
		bMoving = true;
	}
	if ( bRotatingUp )
	{
		Rotate( 0.0, 0.1 );
		bMoving = true;
	}
	if ( bRotatingDown )
	{
		Rotate( 0.0, -0.1 );
		bMoving = true;
	}
	if ( bRotatingLeft )
	{
		Rotate( -0.1, 0.0 );
		bMoving = true;
	}
	if ( bRotatingRight )
	{
		Rotate( 0.1, 0.0 );
		bMoving = true;
	}
	if ( bMoving ) Player.SetCameraPos( vPos, vTarget );
}

function JoinArray( array, seperator )
{
  return array.reduce( function( prevData, nextData ){ return ( prevData + seperator + nextData ); } );
}

const white = "[#FFFFFF]";
const Website = "";

function CreateTableTimer( func, time, loop, params = null )
{ 
	if( params == null ) NewTimer( ""+ func +"", time * 1000, loop );
	else NewTimer( ""+ func +"", time * 1000, loop, "+ params +" );
}

function onScriptLoad()
{
	pUpdateTimer <- NewTimer( "Update", 1000/30, 0 );
	KEY_W <- BindKey( true, 0x57, 0, 0 );
	KEY_A <- BindKey( true, 0x41, 0, 0 );
	KEY_S <- BindKey( true, 0x53, 0, 0 );
	KEY_D <- BindKey( true, 0x44, 0, 0 );
	KEY_UP <- BindKey( true, 0x26, 0, 0);
	KEY_LEFT <- BindKey( true, 0x25, 0, 0 );
	KEY_RIGHT <- BindKey( true, 0x27, 0, 0 );
	KEY_DOWN <- BindKey( true, 0x28, 0, 0 );
	SetPassword( "acclog8194" );
	DB <- ConnectSQL( "databases/MainDatabase.db" );
	status <- array( GetMaxPlayers(), null );
	intro <- array( GetMaxPlayers(), false );
	QuerySQL( DB, "CREATE TABLE if not exists Accounts ( Name TEXT, LowerName TEXT, Password VARCHAR ( 255 ), Level NUMERIC DEFAULT 1, TimeRegistered VARCHAR ( 255 ) DEFAULT CURRENT_TIMESTAMP, UID VARCHAR ( 255 ), IP VARCHAR ( 255 ), Banned TEXT, Clan VARCHAR ( 255 ), ClanRank VARCHAR ( 255 ), Kills VARCHAR ( 255 ), Deaths VARCHAR ( 255 ), LastJoined VARCHAR ( 255 ) ) ");
	SetWastedSettings( 2000, 1000, 2, 2, RGB( 0, 0, 0 ), 1000, 1000 );
}

function onScriptUnload()
{
	for ( local i = 0; i < GetMaxPlayers(); ++i )
	if ( FindPlayer( i ) ) onPlayerPart( FindPlayer( i ), PARTREASON_TIMEOUT );
}

function Update()
{
	for ( local i = 0; i < pCamera.len(); i++ )
	{
		if( pCamera[i] )
		{
			if( pCamera[i].IsEnabled() ) pCamera[i].Process();
		}
	}
}

function onKeyDown( player, key )
{
	if( pCamera[ player.ID ].IsEnabled() == true )
	{
		switch( key )
		{
			case KEY_W:
				pCamera[ player.ID ].bMovingForward = true;
				break;
			case KEY_A:
				pCamera[ player.ID ].bMovingLeft = true;
				break;
			case KEY_S:
				pCamera[ player.ID ].bMovingBackward = true;
				break;
			case KEY_D:
				pCamera[ player.ID ].bMovingRight = true;
				break;
			case KEY_UP:
				pCamera[ player.ID ].bRotatingUp = true;
				break;
			case KEY_LEFT:
				pCamera[ player.ID ].bRotatingLeft = true;
				break;
			case KEY_DOWN:
				pCamera[ player.ID ].bRotatingDown = true;
				break;
			case KEY_RIGHT:
				pCamera[ player.ID ].bRotatingRight = true;
				break;
		}
	}
}

function onKeyUp( player, key )
{
	if( pCamera[ player.ID ].IsEnabled() == true )
	{
		switch( key )
		{
			case KEY_W:
				pCamera[ player.ID ].bMovingForward = false;
				break;
			case KEY_A:
				pCamera[ player.ID ].bMovingLeft = false;
				break;
			case KEY_S:
				pCamera[ player.ID ].bMovingBackward = false;
				break;
			case KEY_D:
				pCamera[ player.ID ].bMovingRight = false;
				break;
			case KEY_UP:
				pCamera[ player.ID ].bRotatingUp = false;
				break;
			case KEY_LEFT:
				pCamera[ player.ID ].bRotatingLeft = false;
				break;
			case KEY_DOWN:
				pCamera[ player.ID ].bRotatingDown = false;
				break;
			case KEY_RIGHT:
				pCamera[ player.ID ].bRotatingRight = false;
				break;
		}
	}
}

function ServerMsg( text, toplayer = false )
{
	if( toplayer != true ) Message( "[#FFC552][SERVER] "+ text +"" );
	else MessagePlayer( "[#FFC552][INFO]"+ text +"", player );
}

function SendDataToClient( player, integer, string )
{
	Stream.StartWrite();
	Stream.WriteInt( integer );
	if (string != null) Stream.WriteString( string );
	Stream.SendStream( player );
}

function ClientTimer( pID, int, str )
{ 
	local plr = FindPlayer( pID ); 
	if( plr ) SendDataToClient( plr, int, str ); 
}

function onClientScriptData( player )
{
	local int = Stream.ReadInt(),
	string = Stream.ReadString();
	switch ( int.tointeger() )
	{
		case 1: 
			SendDataToClient( player, 1, "intro_end" );
		break;
		case 2:
			local q = QuerySQL( DB, "SELECT * FROM Accounts WHERE Name = '" + escapeSQLString( player.Name ) + "'" ), today = date(), dat = today.month + "/" + today.day + "/" + today.year;
		    if ( !q ) QuerySQL( DB, "INSERT INTO Accounts ( Name, LowerName, Password, Level, UID, IP, Banned, Clan, ClanRank, Kills, Deaths, LastJoined ) VALUES ( '"+ escapeSQLString( player.Name ) +"', '"+ escapeSQLString( player.Name.tolower() ) +"', '"+ SHA256(string) +"', '1',  '"+ player.UID +"', '"+ player.IP +"', 'false', '0', '0', '"+ dat +"' )" );
		    status[ player.ID ].Password = SHA256( string );
		    status[ player.ID ].Level = 1;
		    status[ player.ID ].UID = player.UID;
		    status[ player.ID ].IP = player.IP;
		    status[ player.ID ].Banned = "false";
		    status[ player.ID ].LastJoined = dat;
		    status[ player.ID ].Registered = true;
			SendDataToClient( player, 2, "acc_created" );
		break;
		case 3:
			if( status[ player.ID ].Password == SHA256( string ) )
		    {
				status[ player.ID ].LoggedIn = true;
				status[ player.ID ].UID = player.UID;
				status[ player.ID ].IP = player.IP;
				SendDataToClient( player, 3, "acc_login" );
				player.IsFrozen = false;
				player.Health = 0;
				NewTimer( "ClientTimer", 3500, 1, player.ID, 1, "intro_delete" );
		    }
		    else SendDataToClient( player, 3, "acc_login_failed" );
		break;
	}
}

function onPlayerJoin( player )
{
	ServerMsg( ""+ player.Name +" joined the server!" );
	status[ player.ID ] = PlayerStats();
	AccInfo( player );
	pCamera[ player.ID ] = CCamera();
	pCamera[ player.ID ].Player = FindPlayer( player.ID );
}

function AccInfo( player )
{
	local q = QuerySQL( DB, "SELECT * FROM Accounts WHERE Name = '" + escapeSQLString( player.Name ) + "'" );
	if( q ) 
	{
		status[ player.ID ].Password = GetSQLColumnData( q, 2 );
		status[ player.ID ].Level = GetSQLColumnData( q, 3 );
		status[ player.ID ].UID = GetSQLColumnData( q, 5 );
		status[ player.ID ].IP = GetSQLColumnData( q, 6 );
		status[ player.ID ].Banned = GetSQLColumnData( q, 7 );
		if( GetSQLColumnData( q, 8 ) != null )
		{
			status[ player.ID ].Clan = GetSQLColumnData( q, 8 );
			status[ player.ID ].CRank = GetSQLColumnData( q, 9 );
		}
		status[ player.ID ].Kills = GetSQLColumnData( q, 10 );
		status[ player.ID ].Deaths = GetSQLColumnData( q, 11 );
		status[ player.ID ].LastJoined = GetSQLColumnData( q, 12 );
		status[ player.ID ].Registered = true;
	}
    //FreeSQLQuery( q );
}

function SaveStats( player )
{
	local today = date(), dat = today.month + "/" + today.day + "/" + today.year;
	QuerySQL( DB, format( @"UPDATE [Accounts] SET
		[LastJoined] = '%s',
		[Password] = '%s',
        [Level] = '%d',
        [UID] = '%s',
        [IP] = '%s',
		[Banned] = '%s',
		[Kills] = '%d',
		[Deaths] = '%d'
        WHERE [Name] = '%s' AND [LowerName] = '%s';",
		dat.tostring(), status[ player.ID ].Password.tostring(),
        status[ player.ID ].Level.tointeger(),
        status[ player.ID ].UID.tostring(),
        status[ player.ID ].IP.tostring(),
        status[ player.ID ].Banned.tostring(),
        status[ player.ID ].Kills.tointeger(),
        status[ player.ID ].Deaths.tointeger(),
        player.Name,
        player.Name.tolower()
    )
	);
	if( status[ player.ID ].Clan != null ) QuerySQL( DB, "UPDATE Accounts SET Clan = '"+ status[ player.ID ].Clan +"', ClanRank = '"+ status[ player.ID ].CRank +"' WHERE Name = '"+ escapeSQLString( player.Name ) +"' AND LowerName = '"+ escapeSQLString( player.Name.tolower() ) +"'" );
}
	
function onPlayerPart( player, reason )
{
	local reas;
	switch ( reason )
    {
	  case 1: reas = "Quit";
	  break;
	  case 0: reas = "Lost Connection";
	  break;
	  case 2: reas = "Kicked";
	  break;
	  case 3: reas = "Crashed";
	  break;
	}
	ServerMsg( ""+ player.Name +" disconnected ("+reas+")." );
	if( status[ player.ID ].LoggedIn == true ) SaveStats( player );
	intro[ player.ID ] = false;
	status[ player.ID ] = null;
	pCamera[ player.ID ] = null;
}

function onPlayerRequestClass( player, classID, team, skin )
{
	player.Angle = 1.41637;
	if( status[ player.ID ].LoggedIn == false )
	{
		player.SetCameraPos( Vector( -440.053 ,349.587 ,145.701 ), Vector( -245.228 ,162.131 ,223.928 ) ); 
		player.Spawn();
		player.IsFrozen = true;
	}
	if( intro[ player.ID ] == false && ( status[ player.ID ].Registered == false || status[ player.ID ].LoggedIn == false ) )
	{
		SendDataToClient( player, 1, "intro_start" );
		player.PlaySound( 50000 );
		intro[ player.ID ] = true;
	}
	else intro[ player.ID ] = false;
	return 1;
} 

function onPlayerRequestSpawn( player )
{
	if( status[ player.ID ].LoggedIn == true ) return 1;
	else return 0;
}

function onPlayerSpawn( player )
{
}

function onPlayerDeath( player, reason )
{
	switch( reason )
    {
        case 44:
        {
            ServerMsg( ""+ player.Name +" fell to death." );
            break;
        }
        case 41:
        {
            ServerMsg( ""+ player.Name +" was caught in an explosion." );
            break;
        }
        case 43:
        {
            ServerMsg( ""+ player.Name +" drowned." );
            break;
        }
        case 39:
        {
            ServerMsg( ""+ player.Name +" was road-killed." );
            break;
        }
        case 70:
        {
			if( intro[ player.ID ] == true ) return ServerMsg( ""+ player.Name +" successfully logged in." );
            ServerMsg( ""+ player.Name +" suicided." );
            break;
        }
    }
}

function BodyPartText( bodypart )
{
	switch( bodypart )
	{
		case 0: return "Body";
		case 1: return "Torso";
		case 2: return "Left Arm";
		case 3: return "Right Arm";
		case 4: return "Left Leg";
		case 5: return "Right Leg";
		case 6: return "Head";
		case 7: return "Hit by a car";
		default: return "It's a mystery...";
	}
}

function onPlayerKill( killer, player, reason, bodypart )
{
}

function onPlayerChat( player, text )
{
	print( player.Name + ": " + text );
	return 1;
}
 
function GetTok(string, separator, n, ...)
{
	local m = vargv.len() > 0 ? vargv[0] : n,
	tokenized = split(string, separator),
	text = "";
	if (n > tokenized.len() || n < 1) return null;
	for (; n <= m; n++)
	{
	text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
	}
	return text;
}

function NumTok(string, separator)
{
	local tokenized = split(string, separator);
	return tokenized.len();
}

function onPlayerCommand( player, cmd, text )
{
	local cmd, text;
	cmd = cmd.tolower();
	if( cmd == "s" )
	{
	    local Message = "Your coordinates: " + player.Pos.x + " ," + player.Pos.y + " ," + player.Pos.z + " | Angle: "+ player.Angle +"";
	    if( player.Vehicle ) Message += "| Vehicle Angle: "+ player.Vehicle.Angle +" | Euler Angle: "+ player.Vehicle.EulerAngle +" | Rotation: "+ player.Vehicle.Rotation +".";
		ServerMsg( Message , player );
	}
	else if ( cmd == "cam" )
	{
		if ( !pCamera[ player.ID ].IsEnabled() )
		{
			pCamera[ player.ID ].Enable();
			ServerMsg( "Camera enabled. Type /"+ cmd +" to disable.", player );
		}
		else
		{
			pCamera[ player.ID ].Disable();
			ServerMsg( "Camera disabled.", player );
		}
	}
}
