local rshift, lshift=bit.rshift, bit.lshift
local wd,ww,wb=memory.writedword,memory.writeword,memory.writebyte
local rd,rw,rb=memory.readdwordunsigned,memory.readwordunsigned,memory.readbyteunsigned
mb=function(x) return rb(x) 							end
mw=function(x) return rb(x)+rb(x+1)*0x100 					end
md=function(x) return rb(x)+rb(x+1)*0x100+rb(x+2)*0x10000+rb(x+3)*0x1000000 	end
local gt,sf=gui.text,string.format
local start=md(0x02000024)+0x36BE8

local useupper=true
local L8=0x01
local U8=0x00
local edit="NPC"

local mapexit=1
local offset=0x0A

function main()

local wb,md,gt,sf=memory.writebyte,memory.readdwordunsigned,gui.text,string.format
local startscr=md(md(0x02000024)+0x459A4)+md(0x02000024)+0x0459A8
local i,j,x,t=1,1,1,{}

--List all portions of or script
s1="2E 00"
s2="45 00 04 00 04 00"
s3=""
s4=""
s5=""
s6=""
s7="2F 00 02 00"

--Concatenate all strings in order
s=s1..s2..s3..s4..s5..s6..s7

--Remove spaces from eventscript so that we can add the script in
s = string.gsub (s, " ", "")

--Break up eventscript string into a table
while i<=string.len(s) do
	t[j] ="0x"..string.sub(s,i,i+1)
	j=j+1
	i=i+2
end

--Write script per byte via values in the table.
while x<j do
	wb(startscr+x-1,t[x])
	--Graphical display of text
	gt((x-1)%10*15,math.floor((x-1)/0xA)*10,sf("%02X",t[x]))

	x=x+1
end

x=1

--L8=math.random(500)
--mapexit=math.random(6)

if edit=="Furniture" then mode=1 
	mult=0x14 
	editat=0x08+start
elseif edit=="NPC" then 
	mode=2
	mult=0x24 
	editat=0x08+mb(0x04+start)*0x14+start
elseif edit=="Warp" then 
	mode=3
	mult=0x14 
	editat=0x08+mb(0x04+start)*0x14+mb(0x05+start)*0x24+start
elseif edit=="Trigger" then 
	mode=4 
	mult=0x16 
	editat=0x08+mb(0x04+start)*0x14+mb(0x05+start)*0x24+mb(0x06+start)*0x14+start end
count=mb(start+3+mode)

--word editing mode
	if useupper==true then
	if mw(editat+offset)~=(L8+U8*0x100) then i=0
	   gt(1,00,sf("Map is Switching!"))
		while i<count do
			insert=(L8+U8*0x100)
			if mode==3 then ww(i*mult+offset+editat+4,mapexit) end
			ww(i*mult+offset+editat,insert)
			i=i+1
		end
	end end

--byte editing mode
	if useupper==false then 
	if mb(editat+offset)~=(L8) then i=0
	   gt(1,00,sf("Map is Switching!"))
		while i<count do
			insert=(L8)
			if mode==3 then ww(i*mult+offset+editat+4,mapexit) end
			wb(i*mult+offset+editat,insert)
			i=i+1
		end
	end end

--Debug
gt(1,10,sf("Data Start: %08X",start))
gt(1,20,sf("Desired Count: %d",count))
gt(1,30,sf("Start of Desired Data: %08X",editat))
gt(1,40,sf("Mode: %s",edit))

end
gui.register(main)