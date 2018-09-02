/*
	Changes 9/2:
	- Fixed the camera not setting after the player joined the server.
	- Fixed SaveStats storing a null variable to the database.
	- Added /wep command for testing purposes.
	- Fixed ServerMsg not sending the message to a specific player.
	- Set the player to another world until they log in to avoid killing the unspawned player.
	- Fixed the errors in the client-side concerning indexes not existing.
	- Added a military skin, more will be added soon.
	- Custom HUD created essentialy for gamemodes.
	- Hit impact sounds/blood splatter added.
	- Health regeneration system added.
	- Sorted the script by categories.
	- Added a function named "GetTeamHex" to retrieve the hex of the player's team.
	- You can message players on the same world as you're on.
	- Added a team chat by defining '!'.
	- Added a function named "GetOnlinePlayers" to retrieve the amount of players they're online, a better version of the GetMaxPlayers function to avoid memory leaks, along with a array to store the player's ID.
	- Commands will be restricted if you're not logged in.
	- Added a parachute system, credits for the creator, Sebastian, modified by TdZ.KuRuMi^.
	- Deathlog has been added whenever someone dies.
*/

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

//================================ Constants =====================================================

const white = "[#ffffff]";
const Website = "";

//================================ Misc. Functions ===============================================

function CreateTableTimer( func, time, loop, params = null )
{ 
	if( params == null ) NewTimer( ""+ func +"", time * 1000, loop );
	else NewTimer( ""+ func +"", time * 1000, loop, "+ params +" );
}

//================================================================================================

function onScriptLoad()
{
	//==================== Key binds =================================
	KEY_W <- BindKey( true, 0x57, 0, 0 );
	KEY_A <- BindKey( true, 0x41, 0, 0 );
	KEY_S <- BindKey( true, 0x53, 0, 0 );
	KEY_D <- BindKey( true, 0x44, 0, 0 );
	KEY_UP <- BindKey( true, 0x26, 0, 0);
	KEY_LEFT <- BindKey( true, 0x25, 0, 0 );
	KEY_RIGHT <- BindKey( true, 0x27, 0, 0 );
	KEY_DOWN <- BindKey( true, 0x28, 0, 0 );
	//==================== Queries ===================================
	DB <- ConnectSQL( "databases/MainDatabase.db" );
	QuerySQL( DB, "CREATE TABLE if not exists Accounts ( Name TEXT, LowerName TEXT, Password VARCHAR ( 255 ), Level NUMERIC DEFAULT 1, TimeRegistered VARCHAR ( 255 ) DEFAULT CURRENT_TIMESTAMP, UID VARCHAR ( 255 ), IP VARCHAR ( 255 ), Banned TEXT, Clan VARCHAR ( 255 ), ClanRank VARCHAR ( 255 ), Kills VARCHAR ( 255 ), Deaths VARCHAR ( 255 ), LastJoined VARCHAR ( 255 ) ) ");
	//==================== Arrays/Tables =============================
	status <- array( GetMaxPlayers(), null );
	onlinePlrs <- [];
	intro <- array( GetMaxPlayers(), false );
	max_ammo <- array( GetMaxPlayers(), 0 );
	next_mag <- array( GetMaxPlayers(), 0 );
	regenTimer <- array( GetMaxPlayers(), null );
	regenTimer2 <- array( GetMaxPlayers(), null );
	isRegen <- array( GetMaxPlayers(), false );
	nogoto <- array( GetMaxPlayers(), false );
	//==================== Misc. =====================================
	pUpdateTimer <- NewTimer( "Update", 1000/30, 0 );
	SetPassword( "acclog8194" );
	SetWastedSettings( 2000, 1000, 2, 2, RGB( 0, 0, 0 ), 1000, 1000 );
	//=================== Classes ====================================
	AddClass( 1, RGB( 0, 206, 247 ), 200, Vector( -378.79, -537.962, 17.2832 ), 140.020, 21, 60, 23, 90, 26, 60 );
}

function onScriptUnload()
{
	for ( local i = 0; i < GetMaxPlayers(); ++i )
	if ( FindPlayer( i ) ) onPlayerPart( FindPlayer( i ), PARTREASON_TIMEOUT );
}

//============================== Camera System Functions ======================================

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

//========================================= Server-related Functions ============================

function ServerMsg( text, player = null )
{
	if( player == null ) ClientMessageToAll( "[#FFC552][SERVER] "+ text +"", 255, 255, 255 );
	else ClientMessage( "[#FFC552][INFO] "+ text +"", player, 255, 255, 255 );
}

function GetTeamHex( p )
{
	local player = FindPlayer( p );
	switch( player.Team )
	{
		case 1: return "[#00CEF7]";
		break;
		case 2: return "[#F49F00]";
		break;
		default: return "[#D3D3D3]";
	}
}

function GetOnlinePlayers()
{
	local n = 0;
	foreach( ID in onlinePlrs )
	{
		local plr = FindPlayer( ID );
		if( plr ) n++;
	}
	return n;
}

function RegisterDeathLog( enemy, player, reason )
{
	for( local i = 0; i <= GetOnlinePlayers(); i++ )
	{
		local plr = FindPlayer( i );
		if( plr && ( plr.World == enemy.World && plr.World == player.World ) ) SendDataToClient( plr, 5, ""+GetTeamHex( enemy.ID ).tolower() + enemy.Name + white +" ["+reason+"] "+ GetTeamHex( player.ID ).tolower() + player.Name + white +"" );
	}
}

function GetWeaponFiringMode( wepID )
{
	if( wepID >= 0 && wepID <= 15 || wepID == 28 || wepID == 29 ) return "Single";
	else if( wepID > 15 && wepID <= 21 ) return "Semi";
	else if( wepID > 21 && wepID <= 27 || wepID >= 30 && wepID <= 34 ) return "Full-Auto";
}

srand( GetTickCount() ); // KAKAN's suggestion for a pure random coloring
local vehParaID = 6400;  // the vehicle ID of the parachute
local plrParachute = array( GetMaxPlayers(), 0 );
local forParachute = array( GetMaxPlayers(), 0 );
local isOnParachuteHeight = array( GetMaxPlayers(), false );
local g_PlayerFallAccum = array(GetMaxPlayers(), 0.0);

function onPlayerFall( player, speed )
{
	if( speed > 5 ) 
	{
		Announce( "Open your parachute using SPACEBAR!", player, 1 );
		isOnParachuteHeight[ player.ID ] = true;
	}
} 

function _PlayerFallResetFunc()
{
	g_PlayerFallAccum.apply(@(v) 0.0);
	for( local i = 0; i <= GetMaxPlayers(); i++ )
	{
		local player = FindPlayer( i );
		if( player )
		{
			if( (player.Vehicle) && (plrParachute[player.ID]) && (player.Vehicle.ID == plrParachute[player.ID].ID) ) 
			{
				if( forParachute[player.ID] == 1 )
				{
				 local vSpd = player.Vehicle.Speed;
				 player.Vehicle.AddSpeed( Vector( vSpd.x *1.5, vSpd.y *1.5, vSpd.z +0.2 ) );
				 forParachute[player.ID] = 0;
				}
				else if( ( player.Vehicle.Speed.z < 0.01 ) && ( player.Vehicle.Speed.z > -0.01 ) ) 
				onPlayerExitVehicle( player, player.Vehicle );
			}
		}
	}
}

local _PlayerFallResetTimer = NewTimer( "_PlayerFallResetFunc", 500, 0 );

function random( start, finish )
{
   local t;
   if (start < 0) t = ((rand() % (-start + finish)) + start)
   else
   {
      t = ((rand() % (finish - start)) + start);
   }
   return t;
}

//========================================= Client-related Functions ============================

function SendDataToClient( player, integer, string )
{
	Stream.StartWrite();
	Stream.WriteInt( integer );
	if (string != null) Stream.WriteString( string );
	Stream.SendStream( player );
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
			if( status[ player.ID ].Registered == true ) SendDataToClient( player, 2, "acc_create_failed" );
		    else 
			{
				if ( !q ) QuerySQL( DB, "INSERT INTO Accounts ( Name, LowerName, Password, Level, UID, IP, Banned, Clan, ClanRank, Kills, Deaths, LastJoined ) VALUES ( '"+ escapeSQLString( player.Name ) +"', '"+ escapeSQLString( player.Name.tolower() ) +"', '"+ SHA256(string) +"', '1', '"+ player.UID +"', '"+ player.IP +"', 'No', null, null, '0', '0', '"+ dat +"' )" );
				status[ player.ID ].Password = SHA256( string );
				status[ player.ID ].Level = 1;
				status[ player.ID ].UID = player.UID;
				status[ player.ID ].IP = player.IP;
				status[ player.ID ].Banned = "false";
				status[ player.ID ].LastJoined = dat;
				status[ player.ID ].Registered = true;
				SendDataToClient( player, 2, "acc_created" );
			}
		break;
		case 3:
			if( status[ player.ID ].Registered == true )
			{
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
			}
			else SendDataToClient( player, 3, "acc_notexists" );
		break;
	}
}

function CreateHUD( player ) 
{
	local isfirearm = "No";
	if( player.Weapon > 15 && player.Weapon < 34 ) isfirearm = "Yes";
	SendDataToClient( player, 4, ""+GetWeaponDataValue( player.Weapon, 5 )+","+player.Ammo+","+GetWeaponFiringMode( player.Weapon )+","+player.GetAmmoAtSlot( 2 )+","+player.Health+","+ isfirearm +"" );
}

function UpdateHUD( player, index, value )
{
	local isfirearm = "No";
	if( player.Weapon > 15 && player.Weapon < 34 ) isfirearm = "Yes";
	SendDataToClient( player, 5, index +","+ value +","+ isfirearm +"" );
}

function ClientTimer( pID, int, str )
{ 
	local plr = FindPlayer( pID ); 
	if( plr ) SendDataToClient( plr, int, str ); 
}

//=============================================== S E R V E R  E V E N T S ==========================================

function onPlayerJoin( player )
{
	ServerMsg( ""+ player.Name +" joined the server!" );
	print( ""+ player.Name +" joined the server!" );
	status[ player.ID ] = PlayerStats();
	AccInfo( player );
	onlinePlrs.push( player.ID );
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
	if( onlinePlrs.find( player.ID ) != null ) onlinePlrs.remove( onlinePlrs.find( player.ID ) );
	intro[ player.ID ] = false;
	status[ player.ID ] = null;
	pCamera[ player.ID ] = null;
}

function onPlayerRequestClass( player, classID, team, skin )
{
	player.Angle = 1.41637;
	if( !status[ player.ID ].LoggedIn )
	{
		player.World = 20;
		player.Spawn();
		player.IsFrozen = true;
		SendDataToClient( player, 1, "intro_start" );
		player.PlaySound( 50000 );
		intro[ player.ID ] = true;
	}
	else 
	{
		player.World = 1;
		intro[ player.ID ] = false;
		SendDataToClient( player, 6, "" );
	}
	return 1;
} 

function onPlayerRequestSpawn( player )
{ 
	if( status[ player.ID ].LoggedIn ) return 1;
	else return 0;
}

function onPlayerSpawn( player )
{
	if( status[ player.ID ].LoggedIn ) SendDataToClient( player, 4, "create,"+ GetWeaponName( player.Weapon ) +"" );
	else player.SetCameraPos( Vector( -440.053 ,349.587 ,145.701 ), Vector( -245.228 ,162.131 ,223.928 ) );
}

function onPlayerDeath( player, reason )
{
	switch( reason )
    {
        case 41:
        {
            RegisterDeathLog( player, player, "EXPLODED" );
            break;
        }
        case 43:
        {
            RegisterDeathLog( player, player, "DROWNED" );
            break;
        }
        case 39:
        {
            RegisterDeathLog( player, player, "ROAD-KILLED" );
            break;
        }
        case 70:
        {
			if( intro[ player.ID ] == true ) return ServerMsg( ""+ player.Name +" successfully logged in." );
			else RegisterDeathLog( player, player, "SUICIDE" );
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
	RegisterDeathLog( killer, player, GetWeaponName( reason ) );
	NewTimer( "onSpectateKiller", 2000, 1, player.ID, killer.ID );
}

function onSpectateKiller( pID, tID, spec = true )
{
	local target = FindPlayer( tID ), player = FindPlayer( pID );
	if( ( target && player ) && ( target.IsSpawned ) )
	{	
		if( spec )
		{
			player.SpectateTarget = target;
			NewTimer( "onSpectateKiller", 5000, 1, player.ID, target.ID, false );
		}
		else player.SpectateTarget = player;
	}	
}

function onPlayerChat( player, text )
{
	for( local i = 0; i <= GetOnlinePlayers(); i++ )
	{
		local plr = FindPlayer( i );
		if( plr && plr.World == player.World )
		{
			if( text.slice( 0, 1 ) == "!" )
			{
				if( plr.Team == player.Team ) ClientMessage( GetTeamHex( player.ID ) +"[TEAM] "+ player.Name +": "+ text.slice( 1, text.len() ) +"", plr, 255, 255, 255 );
			}
			else ClientMessage( "[ALL] "+ GetTeamHex( player.ID ) + player.Name + white +": "+ text +"", plr, 255, 255, 255 );
		}
	}
	return 0;
}

function onPlayerWeaponChange( player, oldWep, newWep )
{
	switch( newWep )
	{
		case 33: player.RemoveWeapon( newWep );
		break;
		default: 
			SendDataToClient( player, 4, "update,"+ GetWeaponName( player.Weapon ) +"" );
		return 1;
	}
}

function onPlayerHealthChange( player, lastHP, newHP )
{
	if( intro[ player.ID ] == false && lastHP != 0 )
	{
		if( newHP < lastHP && newHP < 100 ) onPlayerHealthRegenerate( player, lastHP, newHP );
		if( ( newHP > 65 && newHP < 100 ) && ( !isRegen[ player.ID ] ) ) player.PlaySound( 50002 );
		else if( ( newHP > 0 && newHP < 65 ) && ( !isRegen[ player.ID ] ) ) player.PlaySound( 50001 );
		else if( newHP == 0 )
		{
			player.SetAnim( 0,13 );
			if( !isRegen[ player.ID ] )
			{
				local c = random( 1, 8 );
				if( c == 4 ) player.PlaySound( 50003 );
				else player.PlaySound( 50001 );
			}
		}
	}
}

function onPlayerHealthRegenerate( player, lHP, nHP )
{
	if( isRegen[ player.ID ] )
	{
		if( regenTimer2[ player.ID ] != null )
		{
			regenTimer2[ player.ID ].Delete();
			regenTimer2[ player.ID ] = null;
		}
		HealthRegeneration( player.ID, 1, true ); 
	}
	if( regenTimer[ player.ID ] == null ) regenTimer[ player.ID ] = NewTimer( "HealthRegeneration", 4000, 1, player.ID, 10 ); 	
	else
	{
		regenTimer[ player.ID ].Delete();
		regenTimer[ player.ID ] = null;
		regenTimer[ player.ID ] = NewTimer( "HealthRegeneration", 4000, 1, player.ID, 10 );
	}
}
	
function HealthRegeneration( p, nhp, cancel = false )
{	
	local player = FindPlayer( p );
	if( player && player.IsSpawned )
	{
		if( !cancel )
		{
			if( !isRegen[ player.ID ] ) isRegen[ player.ID ] = true;
			if( regenTimer[ player.ID ] != null )
			{
				regenTimer[ player.ID ].Delete();
				regenTimer[ player.ID ] = null;
			}
			else if( regenTimer2[ player.ID ] != null )
			{
				regenTimer2[ player.ID ].Delete();
				regenTimer2[ player.ID ] = null;
			}
			if( player.Health < 100 && isRegen[ player.ID ] )
			{
				regenTimer2[ player.ID ] = NewTimer( "HealthRegeneration", 1000, 1, player.ID, nhp );	
				player.Health += nhp;
				if( player.Health > 100 ) player.Health = 100;
			}
			else HealthRegeneration( player.ID, nhp, true );
		}
		else
		{
			isRegen[ player.ID ] = false;
			return 0;
		}
	}
}

function onPlayerCrouchChange( player, isCrouchingNow )
{
    if ( isCrouchingNow ) player.CanAttack = false;
	else player.CanAttack = true;
}

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ )
{
	if( !player.Vehicle )
	{
		// Get the speed to avoid too many table lookups
		local speed = g_PlayerFallAccum[player.ID];
		// Update the accumulated speed
		speed += lastZ > newZ ? lastZ - newZ : 0.0;
		// Check the accumulated speed
		if (speed > 5) onPlayerFall(player, speed);
		// Save the accumulated speed
		g_PlayerFallAccum[player.ID] = speed;
	}
}

function onPlayerActionChange( player, oldAction, newAction )
{
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
	if( ( newKeys == KEY_ONFOOT_JUMP ) && ( !player.Vehicle )  && ( g_PlayerFallAccum[player.ID] != 0 ) && ( isOnParachuteHeight[ player.ID ] ) ) 
	{ 
		isOnParachuteHeight[ player.ID ] = false;
		plrParachute[player.ID] = CreateVehicle( vehParaID, 0, player.Pos, 0, 0, 0 );
		plrParachute[player.ID].EulerAngle.z = player.Angle;
		plrParachute[player.ID].Colour1 = random( 2, 59 );
		plrParachute[player.ID].Colour2 = random( 0, 59 );
		player.Vehicle = plrParachute[player.ID];
		player.Vehicle.Radio = 10; 
		Announce( "", player, 1 );
		forParachute[player.ID] = 1;
		player.SetAnim( 0, 161 );
	}
}

function onPlayerExitVehicle( player, vehicle )
{
	if( plrParachute[player.ID] && vehicle.ID == plrParachute[player.ID].ID )
	{
		vehicle.Delete();
		player.SetAnim( 0, 144 );
	}
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

function onPlayerCommand( player, command, text )
{
	if( !status[ player.ID ].LoggedIn ) return MessagePlayer( "[#FFC552][ERROR] You need to log in the server to have access to the commands available.", player );
	local cmd = command.tolower();
	if( cmd == "s" )
	{
	    local Message = "Your coordinates: " + player.Pos.x + " ," + player.Pos.y + " ," + player.Pos.z + " | Angle: "+ player.Angle +"";
	    if( player.Vehicle ) Message += "| Vehicle Angle: "+ player.Vehicle.Angle +" | Euler Angle: "+ player.Vehicle.EulerAngle +" | Rotation: "+ player.Vehicle.Rotation +".";
		ServerMsg( Message , player );
	}
	else if( cmd == "cam" )
	{
		if( !pCamera[ player.ID ].IsEnabled() )
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
	else if( cmd == "ffa" )
	{
		ServerMsg( "You've joined Free For All. You can kill anyone.", player );
		player.Team = 255;
	}
	else if( cmd == "wep" || cmd == "we" )
    {
     if( !text ) return ServerMsg( "Error: /wep <wep 1> <wep 2> <...>", player );
     else
     {
      local params = split( text, " " ); // Take out the space array
      local weapons; // Create a new null variable which will be holding the list of weapons player took.
      for( local i = 0; i <= params.len() - 1; i++ ) // since the 'len' returns value from 1 and array's starting value point is 0, we will use len() - 1 otherwise we'll receive an error.
      {
       if( !IsNum( params[i] ) && GetWeaponID( params[i] ) && GetWeaponID( params[i] ) > 0 && GetWeaponID( params[i] ) <= 32 ) // if Name was specified. 
       {
        player.SetWeapon( GetWeaponID( params[i] ), 100 ); // Get the weapon ID from its Name
        if ( weapons ) weapons = weapons + ", "+ GetWeaponName( GetWeaponID( params[i] ) ) +""; // Add the weapon name to given weapon list
		else weapons = ""+ GetWeaponName( GetWeaponID( params[i] ) ) +"";
       }
       else if( IsNum( params[i] ) && params[i].tointeger() < 113 && params[i].tointeger() > 0 ) // if ID was specified
       {
        player.SetWeapon( params[i].tointeger(), 100 ); // Then just give player that weapon
        if ( weapons ) weapons = weapons + ", "+ GetWeaponName( params[i].tointeger() ) +""; // Get the weapon name from the ID and add it.
		else weapons = ""+ GetWeaponName( params[i].tointeger() ) +"";
       }
       else ServerMsg( "Error: Invalid Weapon Name/ID", player ); // if the invalid ID/Name was given
      }
      if( weapons != null ) ServerMsg( "Received weapons: "+ weapons +"", player );
      else ServerMsg( "Error: No weapons specified", player );
     }
    }
}
