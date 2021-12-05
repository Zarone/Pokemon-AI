        local wb,md,gt,sf=memory.writebyte,memory.readdwordunsigned,gui.text,string.format
        local start=md(md(0x02000024)+0x459A4)+md(0x02000024)+0x0459A8
        local i,j,x,t=1,1,1,{}

        function main()

        --List all portions of or script
        s1="2E 00"
        s2="74 00 36 01 06 00 00 00 B1 01 00 00 9B 01 6C 00 C4 00 24 00 25 00 25 00 00 00 00 00 AB 00 7C 00 AC 00 74 01 7C 00 32 00 00 00 06 00 9B 01 6D 00 C4 00 27 00 21 00 04 00 02 00 01 00 AD 01 9B 01 21 00 C4 00 26 00 01 00 01 00 00 00 05 00 36 01 07 00 00 00 9B 01 6B 00 03 00 FF 00 00 00 56 01 00 00"
        s3=""
        s4="02 00"

        --Concatenate all strings in order
        s=s1..s2..s3..s4

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
        	wb(start+x-1,t[x])
        	--Graphical display of text
        	gt((x-1)%10*15,math.floor((x-1)/0xA)*10,sf("%02X",t[x]))
        	x=x+1
        end

        x=1
        end
        gui.register(main)