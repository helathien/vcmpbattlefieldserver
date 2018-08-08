/*
		Romania Cops N Robbers REDUX
		By NicusorN5(Athanatos) , Angelo22(Angelo) , DRAGOSDRGM12
*/
function onServerStart()
{
	print("Romania Cops N Robbers REDUX")
	print("By NicusorN5(Athanatos) , Angelo22(Angelo) , DRAGOSDRGM12, Mega_Wolf");
	print("Credits to mujdii");
	vdb <- ConnectSQL("vehicles.sqlite");
	 if (vdb) print("Vehicles Database loaded Successfully");
	 ::QuerySQL( vdb, "CREATE TABLE IF NOT EXISTS Vehicles ( Model INT, World INT, PX FLOAT, PY FLOAT, PZ FLOAT, Angle FLOAT, col1 INT, col2 INT)" );
	LoadCars();
}

function onServerStop()
{
}

function onScriptLoad()
{
	CreateObject(638,2,Vector(161.641,-259.323,128.128),100).RotateToEuler(Vector(0,0,2 * 3.1415926 /4),0);
	BattleRoyaleOn <- false;
	BattleRoyaleTimer <- 0;
	print("Loading script...");
	vdb <- ConnectSQL("vehicles.sqlite");
	 if (vdb) print("Vehicles Database loaded Successfully");
	 ::QuerySQL( vdb, "CREATE TABLE IF NOT EXISTS Vehicles ( Model INT, World INT, PX FLOAT, PY FLOAT, PZ FLOAT, Angle FLOAT, col1 INT, col2 INT)" );
	red <- "[#ff0000]";
	green <- "[#00ff00]";
	blue <- "[#0000ff]";
	white <- "[#ffffff]";
	gray <- "[#aaaaaa]";
	sblue <- "[#00ffff]";
	xkey <- BindKey(true,0x58,0,0);
	gunoi <- array(100,0);
	dofile("scripts/map.nut");
	dofile("scripts/cars.nut");
	dofile("scripts/props.nut");
	dofile("scripts/cmds.nut");
	dofile("scripts/NPC.nut");
	//dm event
	dmstatus <- 0;
	dmplrs <- array(100,-1);
	dmprize <- 0;
	dofile("scripts/DM-event.nut")
	//dmgg event
	ggplrs <- array(100,-1);
	ggstatus <- 0;
	dofile("scripts/GG-event.nut")
	//aaaaaaaaaaaaaa
	print("Loading the map...");
	StartServer();
	CreateMap();
	PropsPicks();
	SetWastedSettings( 0, 0, 0, 0, RGB(0,0,0), 5999, 100)
	NewTimer("Update",60000,0);
	NewTimer("HelpMSG",20000,0);
	NewTimer("NewWeather",900000,0);
	CreateRadioStream( 14, "Radio ZU", "http://stream.radiozu.ro:8020/", true );
	CreateRadioStream( 15, "Taraf", "http://asculta.radiotaraf.ro:7100/", true );
	CreateRadioStream( 16, "Trinitas", "http://82.208.137.144:8010/", true );
	print("Script loaded.");
	//incendii
	FireV <- null;
	FireM <- null;
	FireT <- NewTimer("Fire",180000,0);
	FireRespawn <- NewTimer("RespawnFireEx",10000,0);
	//curse
	racestatus <- 0;
	racers <- array(5,-1);
	raceid <- 0;
	raceradar <- null;
	raceprize <- 0;
	racepoint <- null;
	//juggernaut
	jugg <- array(100,0);
	dofile("scripts/CPlayer_newfuncs.nut");
	dofile("scripts/CVehicle_newfuncs.nut");
	
	//NPCS
	NewTimer("NPC_Update",100,0);
	print("[NPC]Loaded NPC system by Athanatos! :)");
	NewTimer("JailUpdate",1000,0); //Jail
	//Mute
	lastmsg <- array(100,"");
	mute <- array(100,false);
	//lottery
	tickets <- array(100,-1);
	//license system
	licensedrv <- -1;
	licensecar <- -1;
}

function onScriptUnload()
{
}
function onClientScriptData(player) {
    local type = Stream.ReadString();
    if(GetTok(type," ",1) =="Login"){
	if(ReadIniString("Acc.ini","pass",player.Name) ==null){
	MSGPLR(red+"Use register button to create an account.",player,red+"Foloseste butonul 'Register' ca sa creezi un cont.");	
	return 0;
	}
	else if(ReadIniString("Acc.ini","pass",player.Name) == GetTok(type," ",2))
	{
	MSG(blue+"Player "+player.Name+" logged in!",blue+"Jucatorul "+player.Name+" s-a logat!");
	player.Spawn();
	player.RestoreCamera();
	Stream.StartWrite();
	Stream.WriteString("success_login");
    Stream.SendStream(player);
	WriteIniInteger("server.ini","logged",player.Name,1)
	}
	else{
		MSGPLR(red+"Wrong Password",player,red+"Parola gresita!");
	}
	}
	if(GetTok(type," ",1) =="Register"){
		if(ReadIniString("Acc.ini","pass",player.Name) == null)
		{
		WriteIniString("Acc.ini","pass",player.Name,GetTok(type," ",2));
		MSG(green+"Player "+player.Name+" made an account.",green+"Jucatorul "+player.Name+" si-a facut un cont.");
		player.Spawn();
		player.RestoreCamera();
		Stream.StartWrite();
		Stream.WriteString("success_login");
		Stream.SendStream(player);
		player.Cash = 100000;
		} 
		else MSGPLR(red+"You already have an account.",player,red+"Ai deja un cont.");
	}
	if(type == "YES_COP")
	{
		player.Skin = 1;
		player.Color = RGB(0,0,255);
		player.Disarm();
		player.GiveWeapon(17,187);
		player.GiveWeapon(19,25);
		player.GiveWeapon(14,10);
		player.GiveWeapon(23,330);
		player.GiveWeapon(100,1);
		MSG(red+"[JOBS]"+white+player+" is now a cop",red+"[JOBURI]"+white+player+" este acum un politist");
		MSGPLR(white+"You must kill or arrest wanted players.",player,white+"Trebuie sa omori sau sa areztezi jucatori cautati de politie.");
		MSGPLR(white+"To arrest a player, hold the 'OP NIGGA' weapon, then type /arrest <player>",player,white+"Ca sa arestezi un jucator, tine in mana arma 'OP NIGGA' si apoi scrie /arrest <jucator>");
		MSGPLR(white+"Arresting players always will give an higher award than killing them.",player,white+"Arestarea jucatorilor va da un premiu mai mare dacat uciderea lor.");
	}
	if(type == "NO_COP")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(type == "NO_MEDIC")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(type == "YES_MEDIC")
	{
		player.Skin = 5;
		player.Color = RGB(0,255,255);
		MSG(red+"[JOBS]"+white+"Player "+player+" is now a medic",red+"[JOBURI]"+white+"Jucatorul "+player+" e acum un medic.");
		MSGPLR(white+"Your job is healing players with your medkits: /heal",player,white+"Jobul tau e sa vindeci playeri folosing medkitul tau. /heal");
		MSGPLR(white+"You can pick medkits from the hospital.",player,white+"Poti sa iei medkituri de la spital.");
		player.GiveWeapon(101,5);
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(type == "kick") 
	{
		player.Kick();
	}
	if(type == "color<")
	{
		player.Vehicle.Colour1 -= 1;
		if(player.Vehicle.Colour1 == 93) player.Vehicle.Colour1 = 101;
		if(player.Vehicle.Colour1 == 107) player.Vehicle.Colour1 = 1;
		if(player.Vehicle.Colour1 == 100) player.Vehicle.Colour1 = 92;
		if(player.Vehicle.Colour1 == 0) player.Vehicle.Colour1 = 106;
	}
	if(type == "color>")
	{
		player.Vehicle.Colour1 += 1;
		if(player.Vehicle.Colour1 == 93) player.Vehicle.Colour1 = 101;
		if(player.Vehicle.Colour1 == 107) player.Vehicle.Colour1 = 1;
		if(player.Vehicle.Colour1 == 100) player.Vehicle.Colour1 = 92;
		if(player.Vehicle.Colour1 == 0) player.Vehicle.Colour1 = 106;
	}
	if(type == "nos")
	{
		if(player.Cash >= 1500)
		{
			player.Cash -= 1500;
			local nos = ReadIniInteger("Nos.ini","nos",player.Vehicle.ID+"");
			nos += 100;
			if(nos > 900) nos = 900;
			WriteIniInteger("Nos.ini","nos",player.Vehicle.ID+"",nos);
			MessagePlayer(red+"$ -1500",player);
		}
		else MSGPLR(red+"You need $ 1500 to buy NO2",player,red+"Ai nevoie de $ 1500 ca sa cumperi nitro");
	}
	if(type == "buycolor")
	{
		if(player.Cash >= 20000)
		{
		WriteIniInteger("CarsProps.ini","color1",player.Vehicle.ID+"",player.Vehicle.Colour1);
		MessagePlayer(red+"$ -20000",player);
		player.Cash += -20000;
		}
		else MSGPLR(red+"You need $ 20000 to change the car's colour.",player,red+"Ai nevoie de $ 20000 ca sa schimbi culoarea masini.");
	}
	if(type == "buycolor2")
	{
		if(player.Cash >= 10000)
		{
		player.Vehicle.Colour2 = player.Vehicle.Colour1;
		WriteIniInteger("CarsProps.ini","color2",player.Vehicle.ID+"",player.Vehicle.Colour2);
		MessagePlayer(red+"$ -10000",player);
		player.Cash += -10000;
		}
		else MSGPLR(red+"You need $ 10000 to change the car's colour.",player,red+"Ai nevoie de $ 10000 ca sa schimbi culoarea masini.");
	}
	if(type == "cararmour")
	{
		if(player.Cash >= 50000)
		{
			if(player.Vehicle.Health != 100000)
			{
			player.Cash -= 50000;
			MessagePlayer(red+"$ -50000",player);
			player.Vehicle.Health = 100000;
			}
			else MSGPLR(red+"You already have armour to your car.",player,red+"Deja ai armura la masina.");
		}
		else MSGPLR(red+"You need $ 50000 to buy armour for your car.",player,red+"Ai nevoie de $ 20000 ca sa cumperin armura pentru masina ta.");
	}
	if(type == "clothes<")
	{
		player.Skin -= 1
		if(player.Skin == 0) player.Skin = 211;
		if(player.Skin == 187) player.Skin = 201;
		if(player.Skin == 212) player.Skin = 1;
		if(player.Skin == 200) player.Skin = 187
	}
	if(type == "clothes>")
	{
		player.Skin += 1
		if(player.Skin == 0) player.Skin = 211;
		if(player.Skin == 187) player.Skin = 201;
		if(player.Skin == 212) player.Skin = 1;
		if(player.Skin == 200) player.Skin = 187
	}
	if(type == "buyclothes")
	{
		if(player.Cash >= 100000)
		{
		WriteIniInteger("PlayerStats.ini","Skin",player.Name,player.Skin);
		player.Cash -= 100000;
		MessagePlayer(red+"- $ 100000",player);
		MSG(white+"Player "+player+" bought skin "+player.Skin,white+"Jucatorul "+player+" a cumparat skinul "+player.Skin);
		}
		else MSGPLR(red+"You need $ 100000 for a skin.",player,red+"Ai nevoie de 100000 pentru un skin.");
	}
	if(type == "YES_FIREFIGHTER")
	{
		player.Skin = 6;
		player.Color = RGB(255,0,0);
		MSG(red+"[JOBS]"+white+"Player "+player+" is now a firefighter",red+"[JOBURI]"+white+"Jucatorul "+player+" este acum un pompier");
		MSGPLR(white+"Your job is stopping fires around the map.",player,white+"Jobul tau e sa stingi icendiile din mapa.");
	}
	if(type == "YES_TERRORIST")
	{
		player.Skin = 200;
		player.Color = RGB(0,255,0);
		MSG(red+"[JOBS]"+white+"Player "+player+" is now a terorist",red+"[JOBURI]"+white+"Jucatorul "+player+" este acum un terorist");
		player.GiveWeapon(102,150);
		player.GiveWeapon(103,42);
		player.GiveWeapon(30,6);
		player.GiveWeapon(5,1);
		player.GiveWeapon(15,10);
		Stream.StartWrite();
		Stream.WriteString("NO_TERRORIST");
		Stream.SendStream(player);
	}
	if(type == "NO_FIREFIGHTER")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(type == "YES_FIREFIGHTER")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(type == "fix")
	{
		if(player.Cash >= 2500)
		{
		player.Vehicle.Fix();
		player.Cash -= 2500;
		MSGPLR(blue+"You fixed your car. Cost: 2500 $",player,blue+"Ti-ai reparat masina. Cost: 2500 $");
		}
		else MSGPLR(red+"You need $ 2500 cash to fix your car.",player,red+"Ai nevoie de $ 2500 ca sa iti repari masina.");
	}
	if(type == "fuel")
	{
		local Fuel = ReadIniInteger("Nos.ini","fuel",player.Vehicle.ID+"");
		if(Fuel != 100)
		{
			if(player.Cash >= 50)
			{
			Fuel += 10;
			player.Cash -= 50;
			if(Fuel > 100) Fuel = 100;
			MSGPLR(white+"Fuel:"+Fuel,player,white+"Combustibil:"+Fuel);
			MessagePlayer(red+" $ - 50",player);
			WriteIniInteger("Nos.ini","fuel",player.Vehicle.ID+"",Fuel);
			}
			else MSGPLR(red+"You need $ 2500 cash to fuel your car.",player,red+"Ai nevoie de $ 2500 ca sa iti cumperi benzina la masina.");
		}
		else MSGPLR(red+"Your car is completly refilled.",player,red+"Rezorvorul masini tale este acum plin");
	}	
	if(type == "YES_DUSTMAN")
	{
		MSG(white+"Player "+player+" is now a dustman",white+"Jucatorul "+player+" e acum un gunoier.");
		MSGPLR(white+"Your job is collecting trash from the map and bring it to the City Scrap",player,white+"Slujba ta e sa aduci gunoiul din mapa si sa il aduci la groapa de gunoi.");
		MSGPLR(white+"Enter a Trashmaster vehicle firstly.",player,white+"Intai intra intr-o masina Trashmaster.");
		player.Skin = 29;
		player.Color = RGB(128,128,128);
	}
	if(type == "NO_DUSTMAN")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(type == "YES_TAXI")
	{
		MSG(white+"Player "+player+" is now a taxi driver",white+"Jucatorul "+player+" e acum un taximetrist.");
		MSGPLR(white+"Your job is driving other players where they want with your taxi.",player,white+"Slujba ta e sa conduci jocatorii prin oras unde vor cu taxiul tau.");
		player.Skin = 28;
		player.Color = RGB(256,128,0);
	}
	if(type == "NO_TAXI")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(GetTok(type," ",1) == "buywep")
	{
		if(player.Cash >= GetTok(type," ",3).tointeger())
		{
			if(GetTok(type," ",2).tointeger() == 107)
			{
				player.Armour = 100;
				MSG(white+"Player "+player+" bought armour",white+"Jucatorul "+player+" a cumparat armura");
			}
			else if(GetTok(type," ",2).tointeger() == 108)
			{
				player.Armour = 255;
				player.Health = 255;
				player.Skin = 230;
				jugg[player.ID] = 6000;
				player.Immunity = 64;
				MSG(white+"Player "+player+" bought a Juggernaut armour",white+"Jucatorul "+player+" a cumparat o armura de tip Juggernaut");
				player.GiveWeapon(103,42);
				player.GiveWeapon(33,1000);
				player.GiveWeapon(102,330);
			}
			else
			{
				if(GetTok(type," ",2).tointeger() == 105)
				{
					local vip = ReadIniInteger("Acc.ini","VIP",player.Name);
					if(!(vip.tointeger() > 0))
					{
						MSGPLR(red+"You aren't VIP so you can't buy this weapon.",player,red+"Nu esti VIP si nu poti cumpara aceasta arma.");
						Stream.StartWrite();
						Stream.WriteString("buywepend");
						Stream.SendStream(player);
						return 0;
					}
				}
			local wep = WepID(GetTok(type," ",2).tointeger());
			MSG(white+"Player "+player+" bought weapon "+wep,white+"Jucatorul "+player+" a cumparat arma "+wep);
			player.GiveWeapon(GetTok(type," ",2).tointeger(),ClipSize(GetTok(type," ",2).tointeger()) * 11 -1);
			player.GiveWeapon(GetTok(type," ",2).tointeger(),1);
			player.Cash -= GetTok(type," ",3).tointeger();
			}
		}
		else MSGPLR(red+"You need "+GetTok(type," ",3)+" $ to buy this weapon.",player,red+"Ai nevoie de "+GetTok(type," ",3)+" $ ca sa cumperi aceasta arma.");
		Stream.StartWrite();
		Stream.WriteString("buywepend");
		Stream.SendStream(player);
	}
	if(type == "YES_MECHANIC")
	{
		MSG(white+"Player "+player+" is now a mechanic",white+"Jucatorul "+player+" e acum un mecanic.");
		MSGPLR(white+"Your job is fixing other player's cars.",player,white+"Slujba ta e sa repari masinile altor playeri.");
		MSGPLR(white+"To fix a vehicle enter it, and use /fixcar",player,white+"Pentru a repara o masina foloseste /fixcar");
		player.Skin = 160;
		player.Color = RGB(255,128,64);
		player.GiveWeapon(7,1);
	}
	if(type == "NO_MECHANIC")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	if(GetTok(type," ",1) == "buycar")
	{
		local permis = ReadIniInteger("Acc.ini","license",player.Name);
		local text = GetTok(type," ",2);
		if(GetTok(type," ",3) != null) text += GetTok(type," ",3);
		if(GetTok(type," ",4) != null) text += GetTok(type," ",4);
		text.tolower();
		print(text);
		if(permis != 1)
		{
			MSGPLR(red+"You must have a driver license.",player,red+"Trebuie sa ai un permis de conducere.");
			return;
		}
			if(GetVehID(text) != null)
			{
				if(player.Cash >= GetVehCash(text))
				{
						player.Cash -= GetVehCash(text); 
						player.Vehicle = CreateVehicle(GetVehID(text),0,player.Pos,0,1,1);
						local Veh = player.Vehicle;
						if(WriteVeh(player,player.Vehicle.ID+"") != -1)
						{
							QuerySQL( vdb, "INSERT INTO Vehicles ( Model, World, PX, PY, PZ, Angle, col1, col2 ) VALUES ( '" + Veh.Model + "', '" + Veh.World + "', '" + Veh.Pos.x + "', '" + Veh.Pos.y + "', '" + Veh.Pos.z + "', '" + Veh.EulerAngle.z + "', '" + Veh.Colour1 + "', '" + Veh.Colour2 + "')" );
							MessagePlayer(red+"Cost: $ "+GetVehCash(text),player);
							MSG(white+"Player "+player+" bought car "+text,white+"Jucatorul "+player+" a cumparat vehiclul "+text);
							Stream.StartWrite();
							Stream.WriteString("buycarend");
							Stream.SendStream(player);
							Stream.StartWrite();
							Stream.WriteString("buyheliend");
							Stream.SendStream(player);
							Stream.StartWrite();
							Stream.WriteString("buyboatend");
							Stream.SendStream(player);
						}
						else
						{
							player.Cash += GetVehCash(text); 
							player.Vehicle.Remove();
							MSGPLR(red+"You can't have more than 10 vehicles.",player,red+"Nu poti sa ai mai mult de 10 vehiclule.");
						}
				}
				else MSGPLR(red+"You need "+GetVehCash(text).tostring()+" $ to buy this car",player,red+"Ai nevoie de "+GetVehCash(text).tostring()+" $ ca sa cumperi aceasta masina.");
			}
			else MSGPLR(red+"This vehicle does not exist.",player,red+"Acest vehicul nu exista.");
	}
	if(type == "YES_TRUCKER")
	{
		MSG(white+"Player "+player+" is now a trucker",white+"Jucatorul "+player+" e acum un mecanic.");
		MSGPLR(white+"Your job is fixing other player's cars.",player,white+"Slujba ta e sa repari masinile altor playeri.");
		MSGPLR(white+"To fix a vehicle enter it, and use /fixcar",player,white+"Pentru a repara o masina foloseste /fixcar");
		player.Skin = 155;
		player.Color = RGB(255,255,0);
	}
	if(type == "NO_TRUCKER")
	{
		Stream.StartWrite();
		Stream.WriteString(type);
		Stream.SendStream(player);
	}
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.StartWrite();
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.SendStream(player);
}
// =========================================== P L A Y E R   E V E N T S ==============================================

function onPlayerJoin( player )
{
	TXTAddLine("Logs.txt",player.Name+" connected to the server. IP: "+player.IP+", UID: "+player.UniqueID+", UID2: "+player.UniqueID2);
	WriteIniInteger("server.ini","logged",player.Name,0)
	local reason = ReadIniString("Server.ini","Ban",player.Name);
	local kicker = player.Name + " ";
	if(GetTok(kicker,"=",2) != null)
	{
		MSGPLR(red+"Invalid name.",player,red+"Nume invalid.");
		player.Kick();
	}
	if(GetTok(kicker,"[",2) != null)
	{
		MSGPLR(red+"No gang tags allowed.",player,red+"Nu sunt permise tagurile de gang.");
		player.Kick();
	}
	if(GetTok(kicker,"]",2) != null)
	{
		MSGPLR(red+"No gang tags allowed.",player,red+"Nu sunt permise tagurile de gang.");
		player.Kick();
	}
	if(reason != null)
	{
		MSG(red+"Player "+player.Name+" is banned.Reason:"+reason,red+"Jucatorul "+player.Name+" este banat de pe server.Motiv:"+reason);
		player.Kick();
	}
	else
	{
	player.Cash = ReadIniInteger("Cash.ini","cash",player.Name);
	MSG(green+"Player "+player+" has joined!",green+"Jucatorul "+player+" a intrat!");
	MSGPLR(green+"Welcome to Romania Cops N Robbers!",player,green+"Bun venit la Romania Cops N Robbers!");
	MSGPLR(gray+"Please see the rules:"+red+"/rules",player,gray+"Va rugam cititi regulile:"+red+"/rules");
	MSGPLR(gray+"Use "+blue+"/help"+gray+" and "+blue+"/tutorial"+gray+" if you need help.",player,gray+"Foloseste "+blue+"/tutorial"+gray+" daca ai nevoie de ajutor.");
	player.WantedLevel = ReadIniInteger("Others.ini","wantedl",player.Name);
	//player.RequestModuleList();
	}
}

function onPlayerPart( player, reason )
{
	WriteIniInteger("server.ini","logged",player.Name,0)
	TXTAddLine("Logs.txt",player.Name + " left");
	local kicker = player.Name + " ";
	if(GetTok(kicker,"=",2) != null)
	{
		MSG(red+"Player "+player+" was kicked for an not allowed username",red+"Jucatorul "+player+" a primit kick deoarece avea un nume invalid");
	}
	else
	{
	try{
		
	GG_Update(player,"died")
	DM_Refresh(player);
	}
	catch(e) { }
	WriteIniInteger("Cash.ini","cash",player.Name,player.Cash);
	WriteIniInteger("Others.ini","wantedl",player.Name,player.WantedLevel);
	local reas = "Quit";
	switch(reason)
	{
		case 0:
		{
			reas = "Timeout"
			break;
		}
		case 2:
		{
			reas = "Kick/Ban"
			break;
		}
		case 3:
		{
			reas = "Crash"
			break;
		}
		default:
		{		
			break;
		}
	}
	MSG(gray+"Player "+player+" left the server ("+reas+")",gray+"Jucatorul "+player+" a iesit din server("+reas+")");
	}
}

function onPlayerRequestClass( player, classID, team, skin )
{
	return 1;
}

function onPlayerRequestSpawn( player )
{
	if(ReadIniInteger("server.ini","logged",player.Name) != 0)
	{
	return 1;
	}
	else {
		MSGPLR(red+"Please login.",player,red+"Va rugam sa va logati.");
		return 0;
	}
}

function onPlayerSpawn( player )
{
	TXTAddLine("Logs.txt",player.Name + " spawned");
	player.Pos = Vector(-1359.54,-931.44,20.8931);
	local Gang = ReadIniString("Gangs.ini","Member",player.Name);
	try{
		
	local gangspawn = ReadIniString("Gangs.ini","spawn",Gang)
	if(gangspawn != null)
	{
		player.Pos.x = GetTok(gangspawn,"/",1).tofloat();
		player.Pos.y = GetTok(gangspawn,"/",2).tofloat();
		player.Pos.z = GetTok(gangspawn,"/",3).tofloat();
	}
	}
	catch(e) { }
	if(ReadIniInteger("Acc.ini","VIP",player.Name) > 0)
	{
		player.Colour = RGB(255,215,0);
		player.GiveWeapon(33,550);
		player.GiveWeapon(11,1);
		player.GiveWeapon(103,77);
		player.GiveWeapon(15,11);
		player.GiveWeapon(104,320);
		player.GiveWeapon(105,110);
		player.GiveWeapon(20,77);
		player.GiveWeapon(1,1);
	}
	if(ReadIniNumber("Props.ini",player.Name,"propx") != 0) 
	{
		player.Pos.x = ReadIniNumber("Props.ini",player.Name,"propx");
		player.Pos.y = ReadIniNumber("Props.ini",player.Name,"propy");
		player.Pos.z = ReadIniNumber("Props.ini",player.Name,"propz");
	}
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.StartWrite();
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.WriteInt(player.ID);
	Stream.SendStream(player);
	try{
	player.GiveWeapon(ReadIniInteger("Gangs.ini","Wep1",Gang),500)
	player.GiveWeapon(ReadIniInteger("Gangs.ini","Wep2",Gang),500)
	player.GiveWeapon(ReadIniInteger("Gangs.ini","Wep3",Gang),500)
	}
	catch(e)
	{
		
	}
	player.Skin = ReadIniInteger("PlayerStats.ini","Skin",player.Name);
	try {if(player.Skin == 0) player.Skin = ReadIniInteger("Gangs.ini","Skin",Gang); } catch(e)
	if(player.Skin == 0) player.Skin = 15;
	if(Gang) MSGPLR(green+"[GANG]"+white+"Member of gang "+Gang,player,green+"[GANG]"+white+"Membru a gangului "+Gang);
	GG_Update(player,null);
	local seconds = ReadIniInteger("Server.ini","Arrest",player.Name)
	if(seconds > 0)
	{
		MSGPLR(red+"You are arrested for "+seconds+" seconds.",player,red+"Esti arestat pentru "+seconds+" secunde.");
		player.IsFrozen = true;
		MSG(blue+player+" returned to jail.",blue+player+" s-a intors la puscarie");
		player.Pos = Vector(390.152,-508.45,9.39561);
		player.Disarm();
	}
}

function onPlayerDeath( player, reason )
{
	player.World = 0;
	player.HasMarker = true;
	TXTAddLine("Logs.txt",player.Name + " died");
	DropWep(player);
	WriteIniInteger("Cash.ini","cash",player.Name,player.Cash);
	WriteIniInteger("Others.ini","wantedl",player.Name,player.WantedLevel);
	local reas = null;
	switch(reason)
	{
		case 44:
		{
			reas = "felt to the ground"
			break;
		}
		case 41:
		{
			reas = "blew up";
			break;
		}
		case 43:
		{
			reas = "drowned";
			break;
		}
		case 39:
		{
			reas = "had an car accident";
			break;
		}
		default:
		{
			reas = "NPC / suicide";
		}
	}
	MSG(gray+player+" died ("+reas+") in "+GetMapName(player.Pos.x,player.Pos.y),gray+player+" a murit("+reas+") in "+GetMapName(player.Pos.x,player.Pos.y)); 
	GG_Update(player,"died")
	DM_Refresh(player);
}

function onPlayerKill( player, killer, reason, bodypart )
{
	onPlayerTeamKill(player, killer, reason, bodypart);
}

function onPlayerTeamKill( player, killer, reason, bodypart )
{
	killer.World = 0;
	player.HasMarker = true;
	TXTAddLine("Logs.txt",player.Name + " killed " + killer );
	if(reason != player.Weapon) reason = player.Weapon;
	GG_Update(player,"killer");
	if(reason == 11) GG_Update(killer,"died")
	DM_Refresh(killer);
	DropWep(killer);
	MSG(red+killer+" was killed by "+player+" using "+WepID(reason)+" in "+GetMapName(player.Pos.x,player.Pos.y),red+killer+" a fost omorat de "+player+" folosind "+WepID(reason)+" in "+GetMapName(player.Pos.x,player.Pos.y));
	local bluec = RGB(0,0,255);
	local greenc = RGB(0,255,0);
	if(CheckpointColors(player,bluec) == true)
	{
		if(killer.WantedLevel == 0)
		{
			player.Color = RGB(255,255,255);
			player.WantedLevel += 6;
			MSG(red+player+" was kicked from police force for killing a innocent civillan",red+player+" a fost dat afara din politie deoarece a omorat un cetatean inocent.");
		}
		else{
			local bonus = killer.WantedLevel * 1000; 
			player.Cash += bonus;
			killer.WantedLevel = 0;
			local copscore = ReadIniInteger("PlayerStats.ini","cop",player.Name);
			copscore += 1;
			WriteIniInteger("PlayerStats.ini","cop",player.Name,copscore);
			MessagePlayer(green+" $ +"+bonus.tostring(),player);
		}
	}
	else
	{
		player.WantedLevel += 1;
	}
	if(CheckpointColors(player,greenc) == true)
	{
		if(CheckpointColors(killer,blue) != true)
		{
		player.Cash += 5000;
		MSG(red+"Terrorists killed a person!",red+"Teroristi au omorat o persoana.");
		MessagePlayer(green+" $ +5000",player);
		}
		else
		{
			player.Cash += 25000;
			MSG(red+"Terrorists killed a cop!",red+"Teroristi au omorat un politist.");
			MessagePlayer(green+" $ +25000",player);	
		}
		player.WantedLevel += 1;
	}
	if(CheckpointColors(killer,bluec) == true)
	{
		player.WantedLevel += 6;
	}
	Stream.StartWrite();
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.SendStream(player);
}

function onPlayerChat( player, text )
{
	WriteIniInteger("Cash.ini","cash",player.Name,player.Cash);
	WriteIniInteger("Others.ini","wantedl",player.Name,player.WantedLevel);
	if(mute[player.ID] == true)
	{
		MSGPLR(red+"You are muted.",player,red+"Esti amutit.");
		return 0;
	}
	if(text == lastmsg[player.ID])
	{
		MSG(red+"<SERVER>"+player+" was auto-muted for spamming.",red+"<SERVER>"+player+" a fost amutit pentru spam.");
		mute[player.ID] = true;
		return 0;
	}
	lastmsg[player.ID] = text;
	print( player.Name + ": " + text );
	local rolecolor = white+"(Player)"
	local admin = AdminLVL(ReadIniInteger("Acc.ini","Admin",player.Name));
	if(admin != null) rolecolor = admin
	if(ReadIniNumber("Acc.ini","VIP",player.Name) > 0) rolecolor += "[#ffd700][*VIP*][#ffffff]";
	Message(rolecolor+player.Name+": "+text);
	TXTAddLine("Logs.txt",player.Name + ": " + text );
	Stream.StartWrite();
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.SendStream(player);
	return 0;
}
function onPlayerPM( player, playerTo, MSG )
{
	MSGPLR(red+"/msg e dezactivat.",player,red+"/msg is disabled.");
	return 0;
}

function onPlayerBeginTyping( player )
{ 
}

function onPlayerEndTyping( player )
{
}

function onNameChangeable( player )
{
}

function onPlayerSpectate( player, target )
{
}

function onPlayerCrashDump( player, crash )
{
}

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ )
{

}

function onPlayerHealthChange( player, lastHP, newHP )
{
	if(player.Skin == 230)
	{
		if(jugg[player.ID] >= 0)
		{
			jugg[player.ID] -= abs(lastHP - newHP); //DeltaHP
			player.Health = 255;
		}
		else
		{
			MSG(white+player+"'s "+red+"Juggernaut"+white+" armour is destroyed.",white+"Armura de tip "+red+" Juggernaut "+white+" a lui "+player+" e distrusa.");
			player.Skin = ReadIniInteger("PlayerStats.ini","Skin",player.Name);
		}
	}
	Stream.StartWrite();
	Stream.WriteString("hp "+player.Health);
	Stream.SendStream(player);	
}

function onPlayerArmourChange( player, lastArmour, newArmour )
{
	Stream.StartWrite();
	Stream.WriteString("arm "+player.Armour);
	Stream.SendStream(player);
}

function onPlayerWeaponChange( player, oldWep, newWep )
{
}

function onPlayerAwayChange( player, status )
{
}

function onPlayerNameChange( player, oldName, newName )
{
}

function onPlayerActionChange( player, oldAction, newAction )
{
}

function onPlayerStateChange( player, oldState, newState )
{
}

function onPlayerOnFireChange( player, IsOnFireNow )
{
}

function onPlayerCrouchChange( player, IsCrouchingNow )
{
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
}

// ========================================== V E H I C L E   E V E N T S =============================================

function onPlayerEnteringVehicle( player, vehicle, door )
{
	return 1;
}

function onPlayerEnterVehicle( player, vehicle, door )
{
	local owner = ReadIniString("Vehicle2.ini","vehicle",vehicle.ID+"");
	if(owner == null) owner = "For Sale"
	local fuel = ReadIniInteger("Nos.ini","Fuel",vehicle.ID+"");
	local nos = ReadIniInteger("Nos.ini","nos",vehicle.ID+"")
	local SharedCar = ReadIniString("PlayerStats.ini","Sharedcar",vehicle.ID+"");
	if(SharedCar == null) SharedCar = " "; 
	MessagePlayer(white+"ID:"+vehicle.ID+" Owner:"+owner+" Fuel:"+fuel+" NOS:"+nos+" Shared with:"+SharedCar,player);
	Announce("ID:"+vehicle.ID+" Owner:"+owner+" Fuel:"+fuel+" NOS:"+nos+" Shared with:"+SharedCar,player,0);
	if(vehicle.Model == 137)
	{
		if(player.Skin ==6)
		{
			MSGPLR(white+"You can now stop fires using /stopfire",player,white+"Poti sa opresti incendii folosind /stopfire");
		}
	}
	if(vehicle.Model == 150)
	{
		if(player.Skin == 28 && door == 0)
		{
			MSGPLR(white+"You can now drive players around the map and get money",player,white+"Poti sa conduci jucatori prin oras si sa obtii bani");
			MSG(red+"[TAXI]"+white+"You can now ask taxi driver "+player+" to drive you",red+"[TAXI]"+white+"Poti sa il intrebi soferul de taxi"+player+" sa te conduca")
		}
		if(vehicle.Driver.Skin == 28 && door != 0 && player != vehicle.Driver)
		{
			MSGPLR(white+"Tell the driver where he should drive you.",player,white+"Spunei soferului unde sa te conduca");
		}
	}
	if(vehicle.Model == 6406)
	{
		PlaySound(0,50000,vehicle.Pos);
	}
	if(fuel <= 0){
		if(door == 0){
			vehicle.Health = 0;
			MSGPLR(red+"No more fuel remaining.",player,red+"Nu a mai ramas combustibil.");
		}
	}
	Stream.StartWrite();
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.SendStream(player);
}

function onPlayerExitVehicle( player, vehicle )
{
	if(vehicle.Driver != player)
	{
		try{
		if(vehicle.Driver.Skin == 28)
		{
			player.Cash -= 2000;
			vehicle.Driver.Cash += 10000;
			MessagePlayer(green+"$ +10000",vehicle.Driver);
			MessagePlayer(red+"$ -2000",player);
		}
		}
		catch(e)
		{
			
		}
	}
	if(vehicle.Model == 6406)
	{
		PlaySound(0,50000,vehicle.Pos);
	}
}

function onVehicleExplode( vehicle )
{
	if(vehicle.ID == licensecar)
	{
		local player = FindPlayer(licensedrv);
		MSGPLR(red+"Your car was blown up.",player,red+"Masina ta a explodat.");
		licensedrv = -1;
		licensecar = -1;
		MSG(red+"Player "+player+" failed the driver license test.",red+"Jucatorul "+player+" nu a putut lua permisul de conducere");
	}
}

function onVehicleRespawn( vehicle )
{
	if(ReadIniString("CarsProps.ini","park",vehicle.ID.tostring()) != null)
	{
		local vehdata = ReadIniString("CarsProps.ini","park",vehicle.ID.tostring());
		vehicle.Pos.x = GetTok(vehdata," ",1).tofloat();
		vehicle.Pos.y = GetTok(vehdata," ",2).tofloat();
		vehicle.Pos.z = GetTok(vehdata," ",3).tofloat();
		vehicle.Rotation.x = GetTok(vehdata," ",4).tofloat();
		vehicle.Rotation.y = GetTok(vehdata," ",5).tofloat();
		vehicle.Rotation.z = GetTok(vehdata," ",6).tofloat();
		vehicle.Rotation.w = GetTok(vehdata," ",7).tofloat();
	}
	else {
		vehicle.World = 2;
	}
	vehicle.Colour1 = ReadIniInteger("CarsProps.ini","color1",vehicle.ID.tostring());
	vehicle.Colour2 = ReadIniInteger("CarsProps.ini","color2",vehicle.ID.tostring());
}

function onVehicleHealthChange( vehicle, oldHP, newHP )
{
}

function onVehicleMove( vehicle, lastX, lastY, lastZ, newX, newY, newZ )
{
}

// =========================================== P I C K U P   E V E N T S ==============================================

function onPickupClaimPicked( player, pickup )
{
	return 1;
}

function onPickupPickedUp( player, pickup )
{
	if(pickup.Model == 407)
	{
		pickup.RespawnTime = 2000;
		local prop = PropName(pickup.Pos.x,pickup.Pos.y,pickup.Pos.z);
		local owner = ReadIniString("Props.ini","prop",prop);
		if(owner == null) owner = "For Sale";
		NAnnounce("Prop name:"+prop+" Prop price: "+PropPrice(prop)+" Owned by:"+owner,player,0,"Nume:"+prop+" Pret: "+PropPrice(prop)+" Detinator:"+owner);
		MSGPLR(white+"Prop name:"+prop+" Prop price: "+PropPrice(prop)+" Owned by:"+owner,player,white+"Nume:"+prop+" Pret: "+PropPrice(prop)+" Detinator:"+owner);
	}
	if(pickup.Model == 408)
	{
		local cop = RGB(0,0,255);
		if(CheckpointColors(player,cop) == true)
		{
			MSGPLR(red+"Cops do not steal.",player,red+"Politistii nu fura.");
		}
		local cash = rand() % 5000;
		MSG(red+"[CRIME]"+white+player+" robbed a place in "+GetMapName(player.Pos.x,player.Pos.y),red+"[INFRACTIUNE]"+white+player+" a jefuit un loc in "+GetMapName(player.Pos.x,player.Pos.y));
		player.Cash += cash;
		MessagePlayer(green+"$ +"+cash,player);
		player.WantedLevel += 1;
		local robberyskill = ReadIniInteger("PlayerStats.ini","Rob",player.Name);
		robberyskill += 1;
		WriteIniInteger("PlayerStats.ini","Rob",player.Name,robberyskill);
		pickup.RespawnTime = 30000;
	}
	if(pickup.Model == 335)
	{
		local cop = RGB(0,0,255);
		if(CheckpointColors(player,cop) == true)
		{
			MSGPLR(red+"Cops do not steal.",player,red+"Politistii nu fura.");
		}
		local cash = rand() % 100000;
		MSG(red+"[CRIME]"+white+player+" stole the boat",red+"[INFRACTIUNE]"+white+player+" a furat din barca");
		player.WantedLevel += 20;
		player.Cash += cash;
		MessagePlayer(green+"$ +"+cash,player);
		pickup.RespawnTime = 300000;
		player.Health = 100;
		player.Armour = 100;
		player.GiveWeapon(rand() % 34, rand() % 5000);
		player.GiveWeapon(rand() % 34, rand() % 5000);
		player.GiveWeapon(rand() % 34, rand() % 5000);
		local robberyskill = ReadIniInteger("PlayerStats.ini","Rob",player.Name);
		robberyskill += 10;
		WriteIniInteger("PlayerStats.ini","Rob",player.Name,robberyskill);
	}
	if(pickup.ID == 1)
	{
		pickup.RespawnTime = 60000;
	}
	if(pickup.Model == 291)
	{
		player.GiveWeapon(13,pickup.Quantity);
		pickup.Remove();
	}
	for(local i=259; i < 291 ; i++)
	{
		if(pickup.Model == i) {
			pickup.Remove();
			break;
		}
	}
	if(pickup.Model == 399)
	{
		local graycolor = RGB(128,128,128);
		if(CheckpointColors(player,graycolor) == true)
		{
			if(player.Vehicle.Model == 138)
			{
				gunoi[player.ID] += 1;
				MSGPLR(gray+"You collected trash.Take it to the city scrap.",player,gray+"Ai luat gunoi. Du-l la groapa de gunoi.");
				pickup.RespawnTime = 180000;
			}
			else MSGPLR(red+"You need to be in a Trashmaster.",player,red+"Trebuie sa fii intrun Trashmaster.");
		}
	}
	if(pickup.Model == 6000){
		player.GiveWeapon(101,pickup.Quantity);
		if(pickup.ID != 0) pickup.Remove();
	}
	if(pickup.Model ==  6500) 
	{
		player.GiveWeapon(102,pickup.Quantity);
		pickup.Remove();
	}
	if(pickup.Model ==  6501) 
	{
		player.GiveWeapon(103,pickup.Quantity);
		pickup.Remove();
	}
	if(pickup.Model ==  6502) 
	{
		player.GiveWeapon(104,pickup.Quantity);
		pickup.Remove();
	}
	if(pickup.Model ==  6503) 
	{
		player.GiveWeapon(105,pickup.Quantity);
		pickup.Remove();
	}
	if(pickup.Model ==  6504) 
	{
		player.GiveWeapon(106,pickup.Quantity);
		pickup.Remove();
	}
	if(pickup.Model == 375)
	{
		local cop = RGB(0,0,255);
		if(CheckpointColors(player,cop) == true)
		{
			MSGPLR(red+"Cops do not steal.",player,red+"Politistii nu fura.");
		}
		if(player.Weapon == 16)
		{
			local prize =  20000 + rand() % 10000;
			player.Cash += prize;
			MSG(red+"[CRIME]"+white+player+" robbed the bank",red+"[INFRACTIUNE]"+white+player+" a jefuit banca");
			MessagePlayer(green+"$ +"+prize,player);
			pickup.RespawnTime = 120000;
			player.GiveWeapon(16,-1);
			player.WantedLevel += 6;
			local robberyskill = ReadIniInteger("PlayerStats.ini","Rob",player.Name);
			robberyskill += 5;
			WriteIniInteger("PlayerStats.ini","Rob",player.Name,robberyskill);
		}
	}
	if(pickup.Model == 405)
	{
		local prize = rand() % 18;
		local name = "";
		if(prize == 0) prize = 1;
		switch(prize)
		{
			case 1:
			{
				player.GiveWeapon(33,500);
				name = "Minigun";
				break;
			}
			case 2:
			{
				player.GiveWeapon(105,100);
				name = "AWP";
				break;
			}
			case 3:
			{
				player.Armour = 255;
				player.Health = 255;
				player.Skin = 230;
				jugg[player.ID] = 6000;
				player.Immunity = 64;
				player.GiveWeapon(103,42);
				player.GiveWeapon(33,1000);
				player.GiveWeapon(102,330);
				name = "Juggernaut Armour"
				break;
			}
			case 4:
			{
				player.Cash += 1000000;
				name = "1 000 000 $";
				break;
			}
			case 5:
			{
				player.Armour = 100;
				name = "Armour";
				break;
			}
			case 6:
			{
				local vip = ReadIniInteger("Acc.ini","VIP",player.Name);
				vip += 10;
				WriteIniInteger("Acc.ini","VIP",player.Name,vip);
				name = "VIP +10 Mins";
				break;
			}
			case 7:
			{
				player.Health = 0;
				name = "Death";
				MessagePlayer(red+"Surprize motherfucker xD",player);
				break;
			}
			case 8:
			{
				player.Immunity = -1;
				name = "Immunity except some weapons";
				break;
			}
			case 9:
			{
				player.GiveWeapon(17,500)
				name = "Colt 45"
				break;
			}
			case 10:
			{
				player.GiveWeapon(26,500);
				name = "M4";
				break;
			}
			case 11:
			{
				name = "Despacito 6.9"
				break;
			}
			case 12:
			{
				name = "Maximum wanted level"
				player.WantedLevel = 255;
				break;
			}
			case 13:
			{
				name = "Maximum armour";
				player.Armour = 255;
				break;
			}
			case 14:
			{
				name = "Maximum health";
				player.Health = 255;
				break;
			}
			case 15:
			{
				name = "1 Smoke grenade";
				player.GiveWeapon(14,1);
				break;
			}
			case 16:
			{
				name = "No wanted level";
				player.WantedLevel = 0;
				break;
			}
			case 17:
			{
				name = "RPG"
				player.GiveWeapon(30,25);
				break;
			}
			default:
			{
				break;
			}
		}
		MSG(green+"Event box was taken by "+player+" prize:"+white+name,green+"Un event box a fost luat de "+player+" premiu: "+white+name);
		pickup.Remove();
	}
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.StartWrite();
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.WriteInt(player.ID);
	Stream.SendStream(player);
}

function onPickupRespawn( pickup )
{
}

// ========================================== O B J E C T   E V E N T S ==============================================

function onObjectShot( object, player, weapon )
{
	NPC_Hurted(object,player);
}

function onObjectBump( object, player )
{
	NPC_DoDamage(object,player);
	if(player.Health == 0) MSG(red+player+" was killed by "+NPC_name[FindNPC(object)],red+player+" a fost omorat de "+NPC_name[FindNPC(object)]);
}

function onCheckpointEntered( player, checkpoint )
{
	local bluec = RGB(0,0,255);
	local skyblue = RGB(0,255,255);
	local tunningshop = RGB(128,255,255);
	local clothesshop = RGB(255,102,0);
	local greenc = RGB(0,255,0);
	local redc = RGB(255,0,0);
	local carfix = RGB(128,255,128);
	local grayc = RGB(128,128,128);
	local trashc = RGB(153,53,0);
	local orange =  RGB(255,128,0);
	local whitec = RGB(255,255,255);
	local racecolor = RGB(255,150,150);
	local mechanic = RGB(255,128,64);
	local lotteryc = RGB(255,254,255);
	local license = RGB(254,0,0);
	local license2 = RGB(253,0,0);
	local carbuy = RGB(0,161,255);
	local boatbuy = RGB(255,250,250);
	local helibuy = RGB(235,0,0);
    if(CheckpointColors(checkpoint,bluec) == true)
	{
		if(player.WantedLevel == 0)
		{
			if(CheckpointColors(player,bluec) != true)
			{
			Stream.StartWrite();
			Stream.WriteString("cop");
			Stream.SendStream(player);
			}
		}
		else MSGPLR(red+"You are wanted by the police.",player,red+"Esti cautat de politie");
	}
	if(CheckpointColors(checkpoint,skyblue) == true)
	{
			if(CheckpointColors(player,skyblue) != true)
			{
			Stream.StartWrite();
			Stream.WriteString("medic");
			Stream.SendStream(player);
			}
		else MSGPLR(red+"You are already a medic.",player,red+"Esti deja un medic");
	}	
	if(CheckpointColors(checkpoint,tunningshop) == true)
	{
		local plrc = 0;
		if(player.Vehicle != null)
		{
			for(local i = 0; i < 10;i++)
			{
				local veh = ReadIniInteger("Vehicle.ini",player.Name,i.tostring())
				if(veh == player.Vehicle.ID) 
				{
					Stream.StartWrite();
					Stream.WriteString("tunecar");
					Stream.SendStream(player);
					plrc = 1;
				}
			}
			if(plrc == 0) MSGPLR(red+"This car isn't yours",player,red+"Masina aceasta nu este a ta.");
		}
		else MSGPLR(red+"You need to be in your any of your cars to tune it.",player,red+"Trebuie sa fii intro masina de a ta ca sa o poti tuna.");
	}
	if(CheckpointColors(checkpoint,clothesshop) == true)
	{
		Stream.StartWrite();
		Stream.WriteString("clothes");
		Stream.SendStream(player);
	}
	if(CheckpointColors(checkpoint,whitec) == true)
	{
		Stream.StartWrite();
		Stream.WriteString("gun");
		Stream.SendStream(player);
	}
	if(CheckpointColors(checkpoint,redc) == true)
	{
		if(CheckpointColors(player,redc) != true)
		{
			Stream.StartWrite();
			Stream.WriteString("firefighter");
			Stream.SendStream(player);
		}
		else MSGPLR(red+"You are already a firefighter.",player,red+"Esti deja un pompier");
	}
	if(CheckpointColors(checkpoint,greenc) == true)
	{
		if(CheckpointColors(player,greenc) != true)
		{
			Stream.StartWrite();
			Stream.WriteString("terrorist");
			Stream.SendStream(player);
		}
		else MSGPLR(red+"You are already a terrorist.",player,red+"Esti deja un terrorist");
	}
	if(CheckpointColors(checkpoint,carfix) == true)
	{
		if(player.Vehicle != null)
		{
			Stream.StartWrite();
			Stream.WriteString("fixcar");
			Stream.SendStream(player);
		}
		else MSGPLR(red+"You need to be in a car.",player,red+"Trebuie sa fii intro masina");
	}
	if(CheckpointColors(checkpoint,grayc) == true)
	{
		if(CheckpointColors(player,grayc) != true)
		{
			Stream.StartWrite();
			Stream.WriteString("dustman");
			Stream.SendStream(player);
		}
		else MSGPLR(red+"You are already a dustman.",player,red+"Esti deja un gunoier ce mai vrei de la viata");
	}
	if(CheckpointColors(checkpoint,trashc) == true)
	{
		if(player.Vehicle != null)
		{
			if(player.Vehicle.Model ==  138)
			{
				local bonus = gunoi[player.ID] * (rand() % 6000);
				player.Cash += bonus;
				gunoi[player.ID] = null;
				MSG(gray+"Player "+player+" cleared the map.",gray+"Jucatorul "+player+" a curatat orasul.");
				MessagePlayer(green+"$ +"+bonus,player);
			}
		}
	}
	if(CheckpointColors(checkpoint,orange) == true)
	{
		if(CheckpointColors(player,orange) != true)
		{
			Stream.StartWrite();
			Stream.WriteString("taxi");
			Stream.SendStream(player);
		}
		else MSGPLR(red+"You are already a taxi driver.",player,red+"Esti deja un taximetrist.");
	}
	if(CheckpointColors(checkpoint,racecolor) == true)
	{
		local racersjoined = 0;
		for(local i =0 ; i < 5; i++)
		{
			if(racers[i] != -1)
			{
				racersjoined += 1;
			}
		}
		for(local i =0 ; i < 5; i++)
		{
			if(racers[i] == player.ID)
			{
				player.Cash += raceprize *  racersjoined;
				racestatus = 0;
				for(local j = 0 ; j < 5; j++)
				{
					racers[j] = -1;
				}
				DestroyMarker(raceradar);
				racepoint.Remove();
				MSG(red+"[RACE]"+white+"Player "+player+" won the race.",red+"[CURSE]"+white+"Jucatorul "+player+" a castigat cursa.");
				MessagePlayer(green+"$ +"+raceprize *  racersjoined,player);
				local racesw = ReadIniInteger("PlayerStats.ini","racesw",player.Name);
				racesw += 1;
				WriteIniInteger("PlayerStats.ini","racesw",player.Name,racesw);
			}
		}
	}
	if(CheckpointColors(checkpoint,mechanic) == true)
	{
		if(CheckpointColors(player,mechanic) != true)
		{
			Stream.StartWrite();
			Stream.WriteString("mechanic");
			Stream.SendStream(player);
		}
		else MSGPLR(red+"You are already a mechanic.",player,red+"Esti deja un mecanic.");
	}
	if(CheckpointColors(checkpoint,lotteryc) == true)
	{
		MSGPLR(white+"You can use /ticket <number>",player,white+"Poti folosi /ticket");
	}
	if(CheckpointColors(checkpoint,license) == true)
	{
		local permis = ReadIniInteger("Acc.ini","license",player.Name);
		if(player.Vehicle != null)
		{
			if(player.Cash >= 50000)
			{
				if(licensedrv == -1)
				{
					if(permis != 1)
					{
					player.Vehicle.Pos = Vector(-7.34432,-1571.45,10.0582);
					player.Vehicle.Angle = Quaternion(-0.0018862, 0.00012233, -0.0640463, 0.997945)
					player.Vehicle.Fix();
					player.Cash -= 50000;
					MSGPLR(white+"To take the driving license you should drive the car to the Stadium without crashing it.",player,white+"Pentru a lua permisul trebuie sa conduci masina la Stadium fara sa o distrugi");
					MSGPLR(white+"It is marked as a red map icon.",player,white+"Este marcata ca un punct rosu pe mini-mapa");
					licensedrv <- player.ID;
					licensecar = player.Vehicle.ID;
					}
					else MSGPLR(red+"You already own a driver license.",player,red+"Deja ai permis de conducere.");
				}
			}
			else MSGPLR(red+"You must have 50000 $",player,red+"Trebuie sa ai 50000 $");
		}
		else MSGPLR(red+"You must be in a vehicle.",player,red+"Trebuie sa fii intro masina.");
	}
	if(CheckpointColors(checkpoint,license2) == true)
	{
		if(licensedrv == player.ID)
		{
			if(player.Vehicle != null)
			{
				if(player.Vehicle.Health > 950)
				{
					if(player.Vehicle.ID == licensecar)
					{
						if(player.Vehicle.Health < 1001)
						{
							licensecar = -1;
							licensedrv = -1;
							WriteIniInteger("Acc.ini","license",player.Name,1);
							MSG(green+"Player "+player+" passed the driver license test.",green+"Jucatorul "+player+" a trecut testul pentru permisul de conducere.");
						}
						else 
						{
							MSGPLR(red+"Armoured cars aren't allowed.",player,red+"Masinile cu armura nu sunt permise.");
							licensedrv = -1;
							licensecar = -1;
							MSG(red+"Player "+player+" failed the driver license test.",red+"Jucatorul "+player+" nu a putut lua permisul de conducere");
						}
					}
					else
					{
						MSGPLR(red+"This car isnt the one you started the test.",player,red+"Aceasta nu este masina cu care ai inceput testul.");
						licensedrv = -1;
						licensecar = -1;
						MSG(red+"Player "+player+" failed the driver license test.",red+"Jucatorul "+player+" nu a putut lua permisul de conducere");

					}
				}
				else 
				{
					MSGPLR(red+"Your car was wrecked.",player,red+"Masina ta este lovita.");
					licensedrv = -1;
					licensecar = -1;
					MSG(red+"Player "+player+" failed the driver license test.",red+"Jucatorul "+player+" nu a putut lua permisul de conducere");
				}
			}
		}
	}
	if(CheckpointColors(checkpoint,carbuy) == true)
	{
		Stream.StartWrite();
		Stream.WriteString("buycar");
		Stream.SendStream(player);
	}
	if(CheckpointColors(checkpoint,boatbuy) == true)
	{
		Stream.StartWrite();
		Stream.WriteString("buyboat");
		Stream.SendStream(player);
	}
	if(CheckpointColors(checkpoint,helibuy) == true)
	{
		Stream.StartWrite();
		Stream.WriteString("buyheli");
		Stream.SendStream(player);
	}
	local xp = ReadIniInteger("Acc.ini","XP",player.Name);
	Stream.StartWrite();
	Stream.WriteString("spawn "+player.Name+" "+player.Cash+" "+player.WantedLevel+" "+xp);
	Stream.SendStream(player);
}

// =========================================== B I N D   E V E N T S ==============================================
function VecPlusV(vector1,x,y,z)
{
	Vector1.x += x;
	Vector1.y += y;
	Vector1.z += z;
}
function onKeyDown( player, key )
{
	if(key == xkey)
	{
		try{
		 local vehicle = player.Vehicle;
		 local nos = ReadIniInteger("Nos.ini","nos",player.Vehicle.ID+"")
		 if(nos > 0)
		 {
			if(vehicle.Model < 5000)
			{
				vehicle.SetHandlingData(14, vehicle.GetHandlingData(14) + 100.0);
				vehicle.SetHandlingData(13,vehicle.GetHandlingData(13)+100);
			}
			else vehicle.RelativeSpeed *= 1.1;
			PlaySound( 1, 65, vehicle.Pos );
			vehicle.Lights = true;
			nos -= 1;
			WriteIniInteger("Nos.ini","nos",player.Vehicle.ID+"",nos)
		 }
		 else MSGPLR(red+"You have no NO2",player,red+"Nu ai nitro.");
		}
		catch(e) {}
	}
}

function onKeyUp( player, key )
{
	if(key == xkey)
	{
		try{
		 local vehicle = player.Vehicle;
		 if(vehicle.Model < 5000)
		 {
			vehicle.ResetHandlingData(14);
			vehicle.ResetHandlingData(13);
		 }
		 local Nos = ReadIniInteger("Nos.ini","nos",player.Vehicle.ID+"");
		 vehicle.Lights = false;
		 nos -= 1;
		 WriteIniInteger("Nos.ini","nos",player.Vehicle.ID+"",nos)
		}
		catch(e) {}
	}
}

// ================================== E N D   OF   O F F I C I A L   E V E N T S ======================================
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
function HelpMSG()
{
	local a = rand() % 7;
	switch(a)
	{
		case 0:
		{
			MSG(green+"[TIP]"+white+"Use /help for commands.",green+"[SFAT]"+white+"Foloseste /help pentru comenzi.");
			break;
		}
		case 1:
		{
			MSG(green+"[TIP]"+white+"Use /lang to switch your language.",green+"[SFAT]"+white+"Foloseste /lang pentru a schimba limba.");
			break;
		}
		case 2:
		{
			MSG(green+"[TIP]"+white+"There are robbery pickups in the map.They are easy to recognize, because the have the $ sign.",green+"[SFAT]"+white+"Sunt pickupuri de jefuire prin mapa.Sunt usor de recunoscut, deoarece au semnul $.");
			break;
		}
		case 3:
		{
			MSG(green+"[TIP]"+white+"Use /mycars for a list with your vehicles.",green+"[SFAT]"+white+"Foloseste /mycars pentru a vedea lista vehiculelor care le detii.");
			break;
		}
		case 4:
		{
			MSG(green+"[TIP]"+white+"Wanna go fast with your car?Use [X] to use N02.",green+"[SFAT]"+white+"Vrei sa mergi repede cu masina?Foloseste tasta [X] ca sa folosesti N02ul.");
			break;
		}
		case 5:
		{
			MSG(green+"[TIP]"+white+"It's recommended to use the highest resolution to fix the GUI size bugs.",green+"[SFAT]"+white+"Este recomandat sa folositi cea mai mare rezolutie sa ca reparati problemele cu marimea imaginilor, a barelelor,etc");
			break;
		}
		case 6:
		{
			MSG(green+"[TIP]"+white+"There are NPCs in the map. Make sure you always got a weapon.",green+"[SFAT]"+white+"Sunt NPC-uri in mapa.Asigura-te ca tot timpul ai o arma la tine.");
			break;
		}
	}
	for(local i=0 ; i < 100 ; i++)
	{
		if(mute[i] != false){
			MSG(white+"Player "+FindPlayer(i)+" is unmuted.",white+"Jucatorul "+FindPlayer(i)+" nu mai este amutit.");
			mute[i] = false;
		}
	}
}
function CheckpointColors(checkpoint,Colour)
{
	if(checkpoint.Color.r == Colour.r)
	{
		if(checkpoint.Color.g == Colour.g)
		{
			if(checkpoint.Color.b == Colour.b) return true;
			else return false;
		}
		else return false;
	}
	else return false;
}
function Update()
{
	local lottery_winner = rand() % 100;
	if(tickets[lottery_winner] != -1)
	{
		local winner = FindPlayer(tickets[lottery_winner]);
		if(winner != null)
		{
			local cash = rand() % 100000 + 1000000;
			MSG(sblue+"[LOTTERY]"+white+"Player "+winner+" won $ "+cash,sblue+"[LOTERIE]"+white+"Jucatorul "+winner+" a castigat $ "+cash);
			winner.Cash += cash;
			for(local i2 = 0; i2 < 100; i2++)
			{
				tickets[i2] = -1;
			}
		}
	}
	else MSG(sblue+"[LOTTERY]"+white+"No winner was chosen yet.",sblue+"[LOTERIE]"+white+"Nu s-a ales niciun castigator.");
	for(local i=0;i < 100;i++)
	{
		local Plr = FindPlayer(i)
		if(Plr != null)
		{
			local xp = ReadIniInteger("Acc.ini","XP",Plr.Name);
			if(!xp) xp = 0;
			xp += 1;
			MessagePlayer(green+"XP:"+xp.tostring(),Plr);
			WriteIniInteger("Acc.ini","XP",Plr.Name,xp);
			local vip = ReadIniInteger("Acc.ini","VIP",Plr.Name);
			if(vip > 0)
			{
				vip -= 1;
				WriteIniInteger("Acc.ini","VIP",Plr.Name,vip);
				MSGPLR(white+"VIP time remaining:"+vip+" minutes",Plr,white+"Timp VIP ramas:"+vip+" minute.")
			}
			Stream.StartWrite();
			Stream.WriteString("spawn "+FindPlayer(i).Name+" "+FindPlayer(i).Cash+" "+FindPlayer(i).WantedLevel+" "+xp);
			Stream.SendStream(Plr);
			local veh = Plr.Vehicle;
			if(veh != null)
			{
				local Fuel = ReadIniInteger("Nos.ini","fuel",veh.ID+"");
				Fuel += -1;
				if(Fuel == 0){
					MSGPLR(red+"No more fuel",FindPlayer(i),red+"Nu mai e combustibil.");
					Plr.Eject()
					veh.Health = 0;
				}
				if(Fuel < 0) Fuel = 0;
				WriteIniInteger("Nos.ini","fuel",veh.ID+"",Fuel);
				NAnnounce("Car fuel:"+Fuel,FindPlayer(i),1,"Combustibilul masini:"+Fuel);
			}
		}
	}
}
function LoadCars()
{
 CreateVehicle(GetVehicleModelFromName("sentinel"),0,Vector(-1421.55,-805.579,14.7006),Quaternion(-0.00309049, 0.000147335, -0.0476415, 0.99886),14,0);
 RegisterDefaultVehicle(FindVehicle(1));
 CreateVehicle(GetVehicleModelFromName("idaho"),0,Vector(-1424.97, -810.695, 14.6712),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),70,1);
 RegisterDefaultVehicle(FindVehicle(2));
 CreateVehicle(GetVehicleModelFromName("landstalker"),0,Vector(-1428.67,-816.167,14.8714),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),0,0);
 RegisterDefaultVehicle(FindVehicle(3));
 CreateVehicle(6420,0,Vector(-1435.22,-819.84,14.8714),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),3,3);
 RegisterDefaultVehicle(FindVehicle(4));
 CreateVehicle(6400,0,Vector(-1431.65,-819.286,14.8716),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),102,103);
 RegisterDefaultVehicle(FindVehicle(5));
 CreateVehicle(6407,0,Vector(-1438.84,-818.789,14.8713),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),103,104);
 RegisterDefaultVehicle(FindVehicle(6));
 CreateVehicle(GetVehicleModelFromName("caddy"),0,Vector(-1443.22,-816.189,14.8714),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),35,1);
 RegisterDefaultVehicle(FindVehicle(7));
 CreateVehicle(GetVehicleModelFromName("bf injection"),0,Vector(-1452.58,-802.157,14.8715),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),12,5);
 RegisterDefaultVehicle(FindVehicle(8));
 CreateVehicle(GetVehicleModelFromName("stallion"),0,Vector(-1446.84,-813.364,14.8712),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),44,2);
 RegisterDefaultVehicle(FindVehicle(9));
 CreateVehicle(GetVehicleModelFromName("manana"),0,Vector(-1447.96,-805.614,14.8715),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),2,44);
 RegisterDefaultVehicle(FindVehicle(10));
 CreateVehicle(GetVehicleModelFromName("maverick"),0,Vector(-1432.54,-796.166,14.8713),Quaternion(-3.13594e-006, 8.14485e-006, -0.0124738, 0.999922),3,2);
 RegisterDefaultVehicle(FindVehicle(11));
 CreateVehicle(GetVehicleModelFromName("police"),0,Vector(-863.194,-666.07,11.1189),Quaternion(0.000876087, 0.0068225, 0.0415569, 0.999112),44,1);
 RegisterDefaultVehicle(FindVehicle(12));
 CreateVehicle(GetVehicleModelFromName("enforcer"),0,Vector(-860.194,-666.07,11.1189),Quaternion(0.000876087, 0.0068225, 0.0415569, 0.999112),44,1);
 RegisterDefaultVehicle(FindVehicle(13));
 CreateVehicle(6402,0,Vector(-856.194,-666.07,11.1189),Quaternion(0.000876087, 0.0068225, 0.0415569, 0.999112),44,1);
 RegisterDefaultVehicle(FindVehicle(14));
 CreateVehicle(GetVehicleModelFromName("firetruck"),0,Vector(-697.806, 860.673, 10.8289),Quaternion(-8.81767e-005, 0.00189914, -0.998968, 0.0453875),3,1);
 RegisterDefaultVehicle(FindVehicle(15));
 CreateVehicle(GetVehicleModelFromName("police"),0,Vector(-665.163, 766.456, 10.8263),Quaternion(0.00678734, 6.72877e-005, -0.00634888, 0.999957),44,1);
 RegisterDefaultVehicle(FindVehicle(16));
 CreateVehicle(GetVehicleModelFromName("enforcer"),0,Vector(-665.163, 772.456, 10.8263),Quaternion(0.00678734, 6.72877e-005, -0.00634888, 0.999957),44,1);
 RegisterDefaultVehicle(FindVehicle(17));
 CreateVehicle(GetVehicleModelFromName("police"),0,Vector(-650.626, 754.318, 11.1733),Quaternion(0.0324041, 0.00997431, -0.725869, 0.686997),44,1);
 RegisterDefaultVehicle(FindVehicle(18));
 CreateVehicle(GetVehicleModelFromName("ambulance"),0,Vector(-870.836,-490.684,10.8484),Quaternion(-0.00128187, 0.00140311, -0.738872, 0.673844),1,3);
 RegisterDefaultVehicle(FindVehicle(19));
  CreateVehicle(GetVehicleModelFromName("securicar"),0,Vector(-871.912, -352.376, 10.961),Quaternion(0.00186046, 0.00463174, -0.0205933, 0.999776),1,3);
 RegisterDefaultVehicle(FindVehicle(20));
 CreateVehicle(GetVehicleModelFromName("stretch"),0,Vector(-380.145, -513.315, 12.6764),Quaternion(0.00279921, 0.00284421, -0.711946, 0.702223),0,0);
 RegisterDefaultVehicle(FindVehicle(21));
 CreateVehicle(GetVehicleModelFromName("infernus"),0,Vector(-366.565, -529.595, 12.5071),Quaternion(-0.00189923, -5.45498e-006, 0.0241144, 0.999707),1,3);
 RegisterDefaultVehicle(FindVehicle(22));
 CreateVehicle(GetVehicleModelFromName("admiral"),0,Vector(-400.695, -534.771, 12.5403),Quaternion(-0.00346705, 0.0011784, -0.364033, 0.931379),1,3);
 RegisterDefaultVehicle(FindVehicle(23));
 CreateVehicle(GetVehicleModelFromName("hunter"),0,Vector(-389.791, -573.797, 41.9073),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),1,3);
 RegisterDefaultVehicle(FindVehicle(24));
 CreateVehicle(GetVehicleModelFromName("ambulance"),0,Vector(-770.223,1152.6,12.4111),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),1,3);
 RegisterDefaultVehicle(FindVehicle(25));
 CreateVehicle(GetVehicleModelFromName("ambulance"),0,Vector(-1026.63,12.4279,11.3934),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),0,3);
 RegisterDefaultVehicle(FindVehicle(26));
 CreateVehicle(GetVehicleModelFromName("trashmaster"),0,Vector(-1297.78,43.104,11.3538),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),0,3);
 RegisterDefaultVehicle(FindVehicle(27));
 CreateVehicle(GetVehicleModelFromName("police"),0,Vector(351.769,-505.901,12.3246),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),44,1);
 RegisterDefaultVehicle(FindVehicle(28));
  CreateVehicle(GetVehicleModelFromName("enforcer"),0,Vector(408.489,-457.862,10.1198),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),44,1);
 RegisterDefaultVehicle(FindVehicle(29));
   CreateVehicle(6402,0,Vector(372.482,-525.578,12.3246),Quaternion(-0.00159927, 0.00429777, 0.682787, 0.730603),44,1);
 RegisterDefaultVehicle(FindVehicle(30));
 WriteIniString("Server.ini","FirstRun","trash","eee")
 local q = QuerySQL( vdb, "SELECT * FROM Vehicles" ), i = 0;
 while( GetSQLColumnData( q, 0 ) )
 {
  local
   Model = GetSQLColumnData( q, 0 ),
   World = GetSQLColumnData( q, 1 ),
   PX= GetSQLColumnData( q, 2 ),
   PY = GetSQLColumnData( q, 3 ),
   PZ = GetSQLColumnData( q, 4 ),
   Angle = GetSQLColumnData( q, 5 ),
   col1 = GetSQLColumnData( q, 6 ),
   col2 = GetSQLColumnData( q, 7 );
  
  CreateVehicle( Model.tointeger(), World.tointeger(), Vector( PX.tofloat(), PY.tofloat(), PZ.tofloat() ), Angle.tofloat(), col1, col2 );
  GetSQLNextRow( q );
  i++;
 }
 print( "Bought by players vehicles loaded - " + i );
 for(local i =30; i < 1000; i++)
 {
	 if(FindVehicle(i) != null) FindVehicle(i).Kill();
 }
 print("Vehicles respawned.");
}
function NewWeather()
{
	local Weather = rand() % 5;
	SetWeather(Weather);
}
function onPlayerModuleList(Player, string)
{
	local result = 0;
	string = string.tolower();
	for(local i =0 ; i < 1000 ; i++)
	{
		try{
		local result1 = split(string,".")[i];
		if((result1[0] == 97 ) && (result1[1] == 115 ) && (result1[2] == 105 ))
		{
			result++;
		}
		if(result > 1) break;
		}
		catch(e) { }
	}
	if(result > 1) {
		Message(red+"[RCNR-ANTICHEAT v1.0]"+white+Player+"'s hacks were detected.");
		Player.Kick();
	}
}