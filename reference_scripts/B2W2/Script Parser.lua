local rshift, lshift=bit.rshift, bit.lshift
local wd,ww,wb=memory.writedword,memory.writeword,memory.writebyte
local rd,rw,rb=memory.readdwordunsigned,memory.readwordunsigned,memory.readbyteunsigned

mb=function(SRP)
return rb(SRP) 
end

mw=function(SRP)
return rb(SRP)+rb(SRP+1)*0x100 
end

md=function(SRP)
return rb(SRP)+rb(SRP+1)*0x100+rb(SRP+2)*0x10000+rb(SRP+3)*0x1000000
end

local gt,sf=gui.text,string.format
local table={}
local start=md(0x02000024)+0x459A4
local startscr=md(md(0x02000024)+0x459A4)+md(0x02000024)+0x0459A8
local SRP=start
local goscrp=0
local iterhead=0
local iterscr=0
local scrt={}
local scrnum=0
local scrindex=mw(md(0x02000024)+0x41B32)
local printiter=0
local catcherror=1
local itercatch=290



function main()
--Notify when analysis is starting:
		if SRP==start then	
			print(""..string.format("~Script File %d~",scrindex))
		end

	while goscrp==0 and mw(SRP)~=0xFD13 and iterhead<35 do 
		readval=md(SRP)
		scrt[scrnum] = readval
		if rd(start) > 4000 then 
			print(""..sf("~Error Catch, Start Read Error~",curscr))
			goscrp=-1 end
		SRP=SRP+4
		scrnum=scrnum+1
		print(""..sf("Script %d: %08X",scrnum,readval))
		iterhead=iterhead+1
	end

if scrnum>0 then gt(1,00,sf("%08X",scrt[0])) end
if scrnum>1 then gt(1,10,sf("%08X",scrt[1])) end
if scrnum>2 then gt(1,20,sf("%08X",scrt[2])) end
if scrnum>3 then gt(1,30,sf("%08X",scrt[3])) end
if scrnum>4 then gt(1,40,sf("%08X",scrt[4])) end

--Notify that Lua is ready to parse the script data
	if mw(SRP)==0xFD13 and goscrp==0 then
		---print(""..sf("Finished Offset Parse")) 
		goscrp=1					--proceed to next phase
		SRP=SRP+2
		curscr=1
		end

--Begin 
	while goscrp==1 and scrnum>=curscr and catcherror==1 and iterscr<300 do
			printiter=printiter+1
		if printiter>20 or iterscr>itercatch then 
			print(""..sf("~Error Catch, Command Read Error~",curscr))
			catcherror=0
			break 
		end

		print(""..sf("~~~~~Script %d~~~~~~",curscr))
			iterscr=1
			done=0
		while done==0 and md(SRP-2)~=0x0002 and (mw(SRP)~=0x5544 or mw(SRP)~=0x0000 or mw(SRP)~=0x4652) and iterscr<300 do
		if printiter>20 or iterscr>itercatch then 
			print(""..sf("~Error Catch, Command Read Error~",curscr))
			catcherror=0
			break 
		end
			cmd=mw(SRP)
			SRP=SRP+2
				if cmd==0x02 then 
				print(""..sf("End (0x0002)"))
				curscr=curscr+1
				if scrnum>=curscr then print(""..sf("~~~~~Script %d~~~~~~",curscr)) 
				else done=1
				end

			elseif cmd==0x04 then
				rt=md(SRP) SRP=SRP+4
				print(""..sf("CallRoutine (0x0004) 0x%08X",rt))

			elseif cmd==0x05 then 
				print(""..sf("End???[*TR] (0x0005)")) 

			elseif cmd==0x08 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("Logic08 (0x0008)  %s%d",fa,u16a))

			elseif cmd==0x09 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("Logic09 (0x0009)  %s%d",fa,u16a)) 

			elseif cmd==0x0A then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("Logic0A (0x000A)  %s%02X",fa,u16a))  

			elseif cmd==0x10 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("Readflag (0x0010)  %s%d",fa,u16a)) 

			elseif cmd==0x11 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("Logic11 (0x0011)  %s%d",fa,u16a)) 

			elseif cmd==0x19 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("CompareAtoB (0x0019) A=%s%d B=%s%d",fa,u16a,fb,u16b))


			elseif cmd==0x1C then
				std=mw(SRP) SRP=SRP+2
				print(""..sf("CallStd (0x001C) 0x%04X",std))


			elseif cmd==0x1D then
				std=mw(SRP) SRP=SRP+2
				print(""..sf("EndStdReturn[**] (0x001D)"))

			elseif cmd==0x1E then
				jump=md(SRP) SRP=SRP+4
				print(""..sf("GoTo (0x001E) jump=0x%08X",jump))

			elseif cmd==0x1F then
				logic=mb(SRP) SRP=SRP+1
				jump=md(SRP) SRP=SRP+4
				print(""..sf("IfThenGoTo (0x001F) 0x%02X jump=0x%08X",logic,jump))

			elseif cmd==0x21 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("?????? (0x0021)  %s%d",fa,u16a)) 

			elseif cmd==0x23 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("SetFlag (0x0023)  %s%d",fa,u16a))  

			elseif cmd==0x24 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("ClearFlag (0x0023)  %s%d",fa,u16a)) 

			elseif cmd==0x26 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("SetVarEqCont (0x0028) %s%d %s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0x27 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("SetVar27 (0x0027) %s%d %s%d",fa,u16a,fb,u16b)) 


			elseif cmd==0x28 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("SetVarEqVal (0x0028) %s%d %s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0x2A then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("SetVarEq28 (0x002A) %s%d %s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0x2E then 
				print(""..sf("LockAll (0x002E)"))  

			elseif cmd==0x2F then 
				print(""..sf("UnlockAll (0x002F)"))

			elseif cmd==0x30 then 
				print(""..sf("WaitMoment (0x0030)"))
		
			elseif cmd==0x32 then 
				print(""..sf("WaitKeyPress (0x0032)"))

			elseif cmd==0x33 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("EventMessage (0x0033) id=%s%d",fa,u16a))

			elseif cmd==0x34 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("GreyMessage (0x0034) id=%s%d view=%s%d",fa,u16a,fb,u16b))

			elseif cmd==0x35 then 
				print(""..sf("CloseEventMessage (0x0035)"))

			elseif cmd==0x36 then 
				print(""..sf("CloseGreyMessage (0x0036)"))



			elseif cmd==0x38 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u8a=mb(SRP) SRP=SRP+1
					if u8a/0x8000>=1 then fb="Var_" u8a=u8a%0x4000
					elseif u8a/0x4000>=1 then fb="Cont_" u8a=u8a%0x4000
					else fb="Num_"
					end
				print(""..sf("BubbleMessage (0x0038) %s%d %s%d",fa,u16a,fb,u8a)) 

			elseif cmd==0x39 then 
				print(""..sf("CloseBubbleMessage (0x0039)"))

			elseif cmd==0x3C then
				u8a=mb(SRP) SRP=SRP+1
				u8b=mb(SRP) SRP=SRP+1
				mid=mw(SRP)  SRP=SRP+2
					if mid/0x8000>=1 then fm="Var_" mid=mid%0x4000
					elseif mid/0x4000>=1 then fm="Cont_" mid=mid%0x4000
					else fm="Num_"
					end
				npc=mw(SRP) SRP=SRP+2
				view=mw(SRP) SRP=SRP+2
				type=mw(SRP) SRP=SRP+2
				print(""..sf("Message1 (0x003C) MID=%s%X NPC=%d",fm,mid,npc))

			elseif cmd==0x3D then
				u8a=mb(SRP) SRP=SRP+1
				u8b=mb(SRP) SRP=SRP+1
				mid=mw(SRP)  SRP=SRP+2
					if mid/0x8000>=1 then fm="Var_" mid=mid%0x4000
					elseif mid/0x4000>=1 then fm="Cont_" mid=mid%0x4000
					else fm="Num_"
					end
				view=mw(SRP) SRP=SRP+2
				type=mw(SRP) SRP=SRP+2
				print(""..sf("Message2 (0x003D) 0x%X 0x%X mid=%s%X view=%d type=%d",u8a,u8b,fm,mid,view,type))

			elseif cmd==0x3E then 
				print(""..sf("CloseMessage (0x003E)"))

			elseif cmd==0x3F then 
				print(""..sf("CloseMessage2[*] (0x003F)"))

			elseif cmd==0x43 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("BorderMessage (0x0028) id=%s%d color=%s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0x44 then 
				print(""..sf("CloseBorderMessage (0x0044)")) 

			elseif cmd==0x47 then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("PopYesNoVar (0x0047) 0x%04X",u16a))


			elseif cmd==0x48 then 
				u8a=mw(SRP) SRP=SRP+1
					if 	u8a/0x8000>=1 then 	f1="Var_"  u8a=u8a%0x4000
					elseif 	u8a/0x4000>=1 then 	f1="Cont_" u8a=u8a%0x4000
					else 				f1=""
					end
				u8b=mw(SRP) SRP=SRP+1
					if 	u8b/0x8000>=1 then 	f2="Var_"  u8b=u8b%0x4000
					elseif 	u8b/0x4000>=1 then 	f2="Cont_" u8b=u8b%0x4000
					else 				f2=""
					end
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if 	u16d/0x8000>=1 then 	fd="Var_"  u16d=u16d%0x4000
					elseif 	u16d/0x4000>=1 then 	fd="Cont_" u16d=u16d%0x4000
					else 				fd=""
					end
				u16e=mw(SRP) SRP=SRP+2
					if 	u16e/0x8000>=1 then 	fe="Var_"  u16e=u16e%0x4000
					elseif 	u16e/0x4000>=1 then 	fe="Cont_" u16e=u16e%0x4000
					else 				fe=""
					end
				print(""..sf("Message3 (0x0048) %s0x%d %s0x%d %s%d %s%d %s%d %s%d %s%d",f1,u8a,f2,u8b,fa,u16a,fb,u16b,fc,u16c,fd,u16d,fe,u16e))

			elseif cmd==0x49 then 
				u8a=mw(SRP) SRP=SRP+1
					if 	u8a/0x8000>=1 then 	f1="Var_"  u8a=u8a%0x4000
					elseif 	u8a/0x4000>=1 then 	f1="Cont_" u8a=u8a%0x4000
					else 				f1=""
					end
				u8b=mw(SRP) SRP=SRP+1
					if 	u8b/0x8000>=1 then 	f2="Var_"  u8b=u8b%0x4000
					elseif 	u8b/0x4000>=1 then 	f2="Cont_" u8b=u8b%0x4000
					else 				f2=""
					end
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if 	u16d/0x8000>=1 then 	fd="Var_"  u16d=u16d%0x4000
					elseif 	u16d/0x4000>=1 then 	fd="Cont_" u16d=u16d%0x4000
					else 				fd=""
					end
				u16e=mw(SRP) SRP=SRP+2
					if 	u16e/0x8000>=1 then 	fe="Var_"  u16e=u16e%0x4000
					elseif 	u16e/0x4000>=1 then 	fe="Cont_" u16e=u16e%0x4000
					else 				fe=""
					end
				print(""..sf("VersionMessage (0x0049) %s%d %s%d bmid=%s%d wmid=%s%d npc=%s%d view=%s%d type=%s%d",f1,u8a,f2,u8b,fa,u16a,fb,u16b,fc,u16c,fd,u16d,fe,u16e))

			elseif cmd==0x4A then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u8a=mw(SRP) SRP=SRP+1
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("AngryyMessage (0x004A) NPC=%s%d unk=0x%X view=%s%d",fa,u16a,u8a,fb,u16b))

			elseif cmd==0x4B then 
				print(""..sf("CloseAngryMessage (0x004B)"))

			elseif cmd==0x4C then 
				u8a=mb(SRP) SRP=SRP+1
				print(""..sf("???? (0x004C), 0x%02X",u8a))

			elseif cmd==0x4E then 
				u8a=mb(SRP) SRP=SRP+1
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				u8b=mb(SRP) SRP=SRP+1
				print(""..sf("???? (0x004E) unk1=0x%X A=%s%d B=%s%d unk2=0x%X",u8a,fa,u16a,fb,u16b,u8b)) 

			elseif cmd==0x5C then 				
				u8a=mw(SRP) SRP=SRP+1
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("SetVarQualNumberBadges?? (0x005C) unk=0x%X NPC=%s%d  view=%s%d",u8a,fa,u16a,fb,u16b))



			elseif cmd==0x64 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u32a=md(SRP) SRP=SRP+4
				print(""..sf("Movement[***] (0x0064) A=%s%d B=%08X",fa,u16a,u32a)) 

			elseif cmd==0x65 then 
				print(""..sf("WaitMovement (0x0065)"))

			elseif cmd==0x67 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa=""
					end
					varct67=0
				while mw(SRP)>=0x8000 do
					varct67=varct67+1
					SRP=SRP+2 end
				print(""..sf("MultiVar???? (0x0067)  %s%d vars total=%d",fa,u16a,varct67)) 

			elseif cmd==0x68 then 		
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("StoreHeroPosition (0x0068) X=%s%d  Z=%s%d",fa,u16a,fb,u16b))

			elseif cmd==0x69 then
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb="Num_"
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc="Num_"
					end
				print(""..sf("StoreNPCPosition (0x0069) NPC=%s%d X=%s%d Z=%s%d",fa,u16a,fb,u16b,fc,u16c))


			elseif cmd==0x6B then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("AddNPC (0x06B) %s%d",fa,u16a))

			elseif cmd==0x6C then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("RemoveNPC (0x06C) %s%d",fa,u16a))





			elseif cmd==0x6D then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if u16c/0x8000>=1 then fc="Var_" u16c=u16c%0x4000
					elseif u16c/0x4000>=1 then fc="Cont_" u16c=u16c%0x4000
					else fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if u16d/0x8000>=1 then fd="Var_" u16d=u16d%0x4000
					elseif u16d/0x4000>=1 then fd="Cont_" u16d=u16d%0x4000
					else fd=""
					end
				u16e=mw(SRP) SRP=SRP+2
					if u16e/0x8000>=1 then fe="Var_" u16e=u16e%0x4000
					elseif u16e/0x4000>=1 then fe="Cont_" u16e=u16e%0x4000
					else fe=""
					end
				print(""..sf("SetOWPos (0x006D) npc=%s%d x=%s%d y=%s%d z=%s%d dir=%s%d",fa,u16a,fb,u16b,fc,u16c,fd,u16d,fe,u16e))  

			elseif cmd==0x6E then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("???? (0x006E)  %s%d",fa,u16a)) 


			elseif cmd==0x74 then
				print(""..sf("FacePlayer"))

			elseif cmd==0x7C then
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb="Num_"
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc="Num_"
					end
				print(""..sf("?????????? (0x007C) A=%s%d B=%s%d C=%s%d",fa,u16a,fb,u16b,fc,u16c))



			elseif cmd==0x85 then
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb="Num_"
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc="Num_"
					end
				print(""..sf("TrBattle (0x0085) Opp1=%s%d Opp2=%s%d Logic=%s%d",fa,u16a,fb,u16b,fc,u16c))

			elseif cmd==0x8C then 
				print(""..sf("EndBattle (0x008C)")) 

			elseif cmd==0x8D then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("SetVarBattleResult (0x008D) %s%d",fa,u16a))

			elseif cmd==0x8E then 
				print(""..sf("DisableTrainer (0x008E)")) 

			elseif cmd==0xA6 then
				u16a=mw(SRP) SRP=SRP+2
				print(""..sf("PlaySound (0x00A6) id=0x%X",u16a))

			elseif cmd==0xAB then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("PlayCry (0x00AB) dexID=%s%d strain=%s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0xAC then 
				print(""..sf("Waitcry (0x00AC)")) 

			elseif cmd==0xAF then
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb="Num_"
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc="Num_"
					end
				print(""..sf("ScriptText??? (0x00AF) A=%s%d B=%s%d C=%s%d",fa,u16a,fb,u16b,fc,u16c))

			elseif cmd==0xB0 then 
				print(""..sf("CloseMulti (0x00B0)"))

			elseif cmd==0xB2 then 
				u8a=mw(SRP) SRP=SRP+1
				u8b=mw(SRP) SRP=SRP+1
				u8c=mw(SRP) SRP=SRP+1
				u8d=mw(SRP) SRP=SRP+1
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa=""
					end
				u8e=mw(SRP) SRP=SRP+1
				print(""..sf("?????Multi2 (0x00B2) A=0x%X B=0x%X C=0x%X D=0x%X 16=%s0x%X E=%d",u8a,u8b,u8c,u8d,fa,u16a,u8e))  


			elseif cmd==0xBF then 
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if 	u16d/0x8000>=1 then 	fd="Var_"  u16d=u16d%0x4000
					elseif 	u16d/0x4000>=1 then 	fd="Cont_" u16d=u16d%0x4000
					else 				fd=""
					end
				print(""..sf("WarpSpin (0x00BF) Map=%s%d X=%s%d Y=%s%d Z=%s%d",fa,u16a,fb,u16b,fc,u16c,fd,u16d))


			elseif cmd==0xC2 then 
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if 	u16d/0x8000>=1 then 	fd="Var_"  u16d=u16d%0x4000
					elseif 	u16d/0x4000>=1 then 	fd="Cont_" u16d=u16d%0x4000
					else 				fd=""
					end
				u16e=mw(SRP) SRP=SRP+2
					if 	u16e/0x8000>=1 then 	fe="Var_"  u16e=u16e%0x4000
					elseif 	u16e/0x4000>=1 then 	fe="Cont_" u16e=u16e%0x4000
					else 				fe=""
					end
				print(""..sf("TeleportWarpC2 (0x00C2) Map=%s%d X=%s%d Y=%s%d Z=%s%d Face=%s%d",fa,u16a,fb,u16b,fc,u16c,fd,u16d,fe,u16e))

			elseif cmd==0xC4 then 
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if 	u16c/0x8000>=1 then 	fc="Var_"  u16c=u16c%0x4000
					elseif 	u16c/0x4000>=1 then 	fc="Cont_" u16c=u16c%0x4000
					else 				fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if 	u16d/0x8000>=1 then 	fd="Var_"  u16d=u16d%0x4000
					elseif 	u16d/0x4000>=1 then 	fd="Cont_" u16d=u16d%0x4000
					else 				fd=""
					end
				u16e=mw(SRP) SRP=SRP+2
					if 	u16e/0x8000>=1 then 	fe="Var_"  u16e=u16e%0x4000
					elseif 	u16e/0x4000>=1 then 	fe="Cont_" u16e=u16e%0x4000
					else 				fe=""
					end
				print(""..sf("WarpC4 (0x00C4) Map=%s%d X=%s%d Y=%s%d Z=%s%d Face=%s%d",fa,u16a,fb,u16b,fc,u16c,fd,u16d,fe,u16e))




			elseif cmd==0xCB then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
				print(""..sf("StoreRand (0x00CB) %s%d rand(0x%d)",fa,u16a,u16b)) 


			elseif cmd==0xCC then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("SetVarQualItem (0x00CC) %s%d",fa,u16a))

			elseif cmd==0xCD then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("SetVarQual???? (0x00CD) %s%d",fa,u16a))

			elseif cmd==0xCE then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("SetVarQual???? (0x00CE) %s%d",fa,u16a))

			elseif cmd==0xCF then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("SetVarQual???? (0x00CF) %s%d",fa,u16a))

			elseif cmd==0xD1 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("?????? (0x00D1) A=%s%d B=%s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0xD5 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb=""
					end
				print(""..sf("StoreVarBadge (0x00D5) %s%d badge=%s%d",fa,u16a,fb,u16b))

			elseif cmd==0xD7 then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("BadgeVar?? (0x0D7) %s%d",fa,u16a))

			elseif cmd==0x11F then
				u16a=mw(SRP) SRP=SRP+2
					if 	u16a/0x8000>=1 then 	fa="Var_"  u16a=u16a%0x4000
					elseif 	u16a/0x4000>=1 then 	fa="Cont_" u16a=u16a%0x4000
					else 				fa="Num_"
					end
				u8a=mb(SRP) SRP=SRP+1
				u16b=mw(SRP) SRP=SRP+2
					if 	u16b/0x8000>=1 then 	fb="Var_"  u16b=u16b%0x4000
					elseif 	u16b/0x4000>=1 then 	fb="Cont_" u16b=u16b%0x4000
					else 				fb="Num_"
					end
				print(""..sf("??????? (0x011F) A=%s%d unk=%d C=%s%d",fa,u16a,u8a,fb,u16b))






			elseif cmd==0x227 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("??? (0x0227) A=%s%d B=%s%d",fa,u16a,fb,u16b))


			elseif cmd==0x23F then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("?????? (0x023F) A=%s%d B=%s%d",fa,u16a,fb,u16b)) 



			elseif cmd==0x24F then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa=""
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb=""
					end
				u16c=mw(SRP) SRP=SRP+2
					if u16c/0x8000>=1 then fc="Var_" u16c=u16c%0x4000
					elseif u16c/0x4000>=1 then fc="Cont_" u16c=u16c%0x4000
					else fc=""
					end
				u16d=mw(SRP) SRP=SRP+2
					if u16d/0x8000>=1 then fd="Var_" u16d=u16d%0x4000
					elseif u16d/0x4000>=1 then fd="Cont_" u16d=u16d%0x4000
					else fd=""
					end
				print(""..sf("????? (0x024F) A=%s%d B=%s%d C=%s%d D=%s%d",fa,u16a,fb,u16b,fc,u16c,fd,u16d))  
	
			elseif cmd==0x253 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("????? (0x0253) A=%s%d B=%s%d",fa,u16a,fb,u16b)) 

			elseif cmd==0x276 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				u16b=mw(SRP) SRP=SRP+2
					if u16b/0x8000>=1 then fb="Var_" u16b=u16b%0x4000
					elseif u16b/0x4000>=1 then fb="Cont_" u16b=u16b%0x4000
					else fb="Num_"
					end
				print(""..sf("??? (0x0276) A=%s%d B=%s%d",fa,u16a,fb,u16b))

			elseif cmd==0x291 then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("??????? (0x0291) %s%d",fa,u16a))

			elseif cmd==0x292 then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("??????? (0x0292) %s%d",fa,u16a))

			elseif cmd==0x2AF then
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("??????? (0x02AF) %s%d",fa,u16a))

			elseif cmd==0x2C5 then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("??? (0x02C5) A=%s%d",fa,u16a))


			elseif cmd==0x2DA then 
				u16a=mw(SRP) SRP=SRP+2
					if u16a/0x8000>=1 then fa="Var_" u16a=u16a%0x4000
					elseif u16a/0x4000>=1 then fa="Cont_" u16a=u16a%0x4000
					else fa="Num_"
					end
				print(""..sf("??? (0x02C5) A=%s%d",fa,u16a))





 			
			else
			print(""..sf("0x%X",cmd))
			iterscr=iterscr+1
			end
		end







		
	end
	
	if goscrp==1 and scrnum<curscr then 
	print(""..sf("~~~~~~Finish~~~~~~")) 
	goscrp=2 end


gt(1,70,sf("Total Scripts: %d",scrnum))
gt(1,80,sf("Attempts: %d",iterhead))

gt(1,90,sf("SRP: %08X",SRP))
if goscrp==2 then gt(1,100,sf("~~~~~Finish~~~~~")) end














end
gui.register(main)