Program CMOSEDIT;
Uses Crt,DOS,THApp,THOpen,THString,THGS,CZ;
Const
  OEM='Extend CMOS Editor';
  Ver='3.1';
Type
  TCMOSBuffer=Array[0..255] of Byte;
Var
  CMOS:^TCMOSBuffer;
  W,Pozice,I:Word;
  B:Byte;
  Save:Boolean;
  CMOSBuf:Array[0..255] of Byte;
  CheckSum0,CheckSumNow:Word;


Procedure ReadCMOS;
Var
  B:Byte;
  I:Byte;
begin
  For I:=0 to 255 do
  begin
    Port[$70]:=I;
    CMOS^[I]:=Port[$71];
  end;
end;


Procedure GetCheckSum;
begin
  CheckSumNow:=0;
  For I:=$10 to $2d do
  begin
    Port[$70]:=I;
    B:=Port[$71];
    If (B and 1)=1 then CheckSumNow:=CheckSumNow+1;
    If (B and 2)=2 then CheckSumNow:=CheckSumNow+2;
    If (B and 4)=4 then CheckSumNow:=CheckSumNow+4;
    If (B and 8)=8 then CheckSumNow:=CheckSumNow+8;
    If (B and 16)=16 then CheckSumNow:=CheckSumNow+16;
    If (B and 32)=32 then CheckSumNow:=CheckSumNow+32;
    If (B and 64)=64 then CheckSumNow:=CheckSumNow+64;
    If (B and 128)=128 then CheckSumNow:=CheckSumNow+128;
  end;
end;

Procedure WriteCMOSCheckSum;
Var
  I:Word;
  B:Byte;
begin
  GetCheckSum;
  Port[$70]:=$2E;Port[$71]:=Hi(CheckSumNow);
  Port[$70]:=$2F;Port[$71]:=Lo(CheckSumNow);
end;



Procedure CMOSInfo;
Var
  Page:Byte;
begin
  GetScreen2(1);
  TextColor(0);TextBackground(7);
  Frame(19,2,60,21,64);
  Center(2,' CMOS Info ');
  GotoXY(49,22);Write(' Page:');
  Page:=0;Pozice:=0;
  Repeat
    If Page=0 then
    begin
      TextColor(0);TextBackground(7);
      GotoXY(55,22);Write(' ',Page+1:2,' ');
      Frame(20,3,59,20,128+8);
      GotoXY(22,5);Write('Time:');
      GotoXY(22,6);Write('Date:');
      GotoXY(22,7);Write('Alarm:');
      GotoXY(22,8);Write('Update in progress:');
      GotoXY(22,9);Write('Cyclic update:');
      GotoXY(22,10);Write('Periodic interrupt:');
      GotoXY(22,11);Write('Alarm interrupt:');
      GotoXY(22,12);Write('Update ended interrupt:');
      GotoXY(22,13);Write('Square wave output:');
      GotoXY(22,14);Write('Data mode:');
      GotoXY(22,15);Write('24/12 hour selection:');
      GotoXY(22,16);Write('US Daylight Savings:');
      GotoXY(22,17);Write('Interrupt request flag:');
      GotoXY(22,18);Write('Periodic interrupt flag:');
      GotoXY(22,19);Write('Alarm interrupt flag:');
      GotoXY(22,20);Write('Update-Ended interrupt flag:');
      Repeat
        Delay(5);
        ReadCMOS;

        If (Scan=72)and(Pozice>0)then Dec(Pozice);
        If (Scan=80)and(Pozice<15)then Inc(Pozice);

        If Pozice=0 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,5);{ Time }
        Write(' ',HexByte(CMOS^[4]),':');
        Write(HexByte(CMOS^[2]),':');
        Write(HexByte(CMOS^[0]),' ');

        If Pozice=1 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,6);{ Date }
        Write(' ',HexByte(CMOS^[8]),'-');
        Write(HexByte(CMOS^[7]),'-');
        Write(HexByte(CMOS^[9]),' ');

        If Pozice=2 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,7);{ Alarm }
        Write(' ',HexByte(CMOS^[5]),':');
        Write(HexByte(CMOS^[3]),':');
        Write(HexByte(CMOS^[1]),' ');

        If Pozice=3 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,8);{ Reg A -update in progress }
        If CMOS^[$0A]and 128=128then Write('Yes ':10)else Write('No ':10);

        If Pozice=4 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 128;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,9);{ B -cyclic update }
        If CMOS^[$0B] and 128=128 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=5 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 64;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,10);{ B -periodic interrupt }
        If CMOS^[$0B] and 64=64 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=6 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 32;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,11);{ B -alarm interrupt }
        If CMOS^[$0B] and 32=32 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=7 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 16;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,12);{ B -update ended interrupt }
        If CMOS^[$0B] and 16=16 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=8 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 8;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,13);{ B -square wave output }
        If CMOS^[$0B] and 8=8 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=9 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 4;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,14);{ B -data mode }
        If CMOS^[$0B] and 4=4 then Write('Binary ':10) else Write('BCD ':10);


        If Pozice=10 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 2;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,15);{ B -24/12 hour selection }
        If CMOS^[$0B] and 2=2 then Write('24 ':10) else Write('12 ':10);

        If Pozice=11 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$0B;Port[$71]:=Port[$71] xor 1;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,16);{ B -US Daylight Savings }
        If CMOS^[$0B] and 1=1 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=12 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,17);{ C -Interrupt request flag }
        If CMOS^[$0C] and 128=128 then Write('On':9,' ')else Write('Off':9,' ');

        If Pozice=13 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,18);{ C -Periodic interrupt flag }
        If CMOS^[$0C] and 64=64 then Write('On':9,' ')else Write('Off':9,' ');

        If Pozice=14 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,19);{ C -Alarm interrupt flag}
        If CMOS^[$0C] and 32=32 then Write('On':9,' ')else Write('Off':9,' ');

        If Pozice=15 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,20);{ C -Update-Ended interrupt flag: }
        If CMOS^[$0C] and 16=16 then Write('On':9,' ')else Write('Off':9,' ');

        Scan:=0;
        If Keypressed then GetKey;
        If (Scan=73)or(Scan=81) then Save:=True;
        If (Scan=75)and(Page=0)then Scan:=0;
      until (Scan=1)or(Scan=75)or(Scan=77);
      If (Scan=75)and(Page>0) then Dec(Page);
      If (Scan=77)and(Page<3) then Inc(Page);
    end;
    {****************************************************************}
    If Page=1 then
    begin
      TextColor(0);TextBackground(7);
      GotoXY(55,22);Write(' ',Page+1:2,' ');
      Frame(20,3,59,20,128+8);
      GotoXY(22,5);Write('Battery power');
      GotoXY(22,6);Write('Diagnostic Status');
      GotoXY(22,7);Write('Shutdown Status');
      GotoXY(22,8);Write('Drive A: type');
      GotoXY(22,9);Write('Drive B: type');
      GotoXY(22,10);Write('Mouse Support Option');
      GotoXY(22,11);Write('Above 1MB Memory Test');
      GotoXY(22,12);Write('Memory Test Tick Sound');
      GotoXY(22,13);Write('Memory Parity Error Check');
      GotoXY(22,14);Write('Hit <Del> Message Display');
      GotoXY(22,15);Write('Hard Disk 47 RAM Area');
      GotoXY(22,16);Write('Wait For <F1> If Error');
      GotoXY(22,17);Write('Boot up Num Lock');
      GotoXY(22,18);Write('Fixed disk 1 type');
      GotoXY(22,19);Write('Fixed disk 2 type');
      GotoXY(22,20);Write('Typematic Programming');
      Repeat
        Delay(5);
        ReadCMOS;

        If (Scan=72)and(Pozice>0)then Dec(Pozice);
        If (Scan=80)and(Pozice<15)then Inc(Pozice);

        If Pozice=0 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,5);{ Battery power }
        If CMOS^[$0D] and 128=128 then Write('Good ':10)else Write('BAD ! ':10);

        If Pozice=1 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,6);{ Diagnostic Status }
        Write(HexByte(CMOS^[$0E])+' ':10);

        If Pozice=2 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,7);{ Shutdown Status }
        Write(HexByte(CMOS^[$0F])+' ':10);

        If Pozice=3 then
        begin
          TextColor(10);TextBackground(0);
          If Scan=73 then
          begin
            Port[$70]:=$10;
            B:=(Port[$71]and (255-15)) div 16;
            If B>0 then Dec(B);
            Port[$71]:=B*16 or (Port[$71] and 15);
          end;
          If Scan=81 then
          begin
            Port[$70]:=$10;
            B:=(Port[$71]and (255-15)) div 16;
            If B<15 then Inc(B);
            Port[$71]:=B*16 or (Port[$71] and 15);
          end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,8);{ Drive A: type }
        If CMOS^[$10] and (255-15)=00*16 then Write('None ':10);
        If CMOS^[$10] and (255-15)=01*16 then Write('5¬",360k ':10);
        If CMOS^[$10] and (255-15)=02*16 then Write('5¬",1200k ':10);
        If CMOS^[$10] and (255-15)=03*16 then Write('3«",720k ':10);
        If CMOS^[$10] and (255-15)=04*16 then Write('3«",1440k ':10);
        If CMOS^[$10] and (255-15)=05*16 then Write('3«"2.88Mb ');
        If CMOS^[$10] and (255-15)=06*16 then Write('3«"5.76Mb ':10);
        If CMOS^[$10] and (255-15)=07*16 then Write('7 ':10);
        If CMOS^[$10] and (255-15)=08*16 then Write('8 ':10);
        If CMOS^[$10] and (255-15)=09*16 then Write('9 ':10);
        If CMOS^[$10] and (255-15)=10*16 then Write('A ':10);
        If CMOS^[$10] and (255-15)=11*16 then Write('B ':10);
        If CMOS^[$10] and (255-15)=12*16 then Write('C ':10);
        If CMOS^[$10] and (255-15)=13*16 then Write('D ':10);
        If CMOS^[$10] and (255-15)=14*16 then Write('E ':10);
        If CMOS^[$10] and (255-15)=15*16 then Write('F ':10);
        {Write(HexByte(CMOS^[$10]):9,' ');}

        If Pozice=4 then
        begin
          TextColor(10);TextBackground(0);
          If Scan=73 then
          begin
            Port[$70]:=$10;
            B:=(Port[$71]and 15);
            If B>0 then Dec(B);
            Port[$71]:=B or (Port[$71] and (255-15));
          end;
          If Scan=81 then
          begin
            Port[$70]:=$10;
            B:=(Port[$71]and 15);
            If B<15 then Inc(B);
            Port[$71]:=B or (Port[$71] and (255-15));;
          end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,9);{ Drive B: type }
        If CMOS^[$10] and 15=00 then Write('None ':10);
        If CMOS^[$10] and 15=01 then Write('5¬",360k ':10);
        If CMOS^[$10] and 15=02 then Write('5¬",1200k ':10);
        If CMOS^[$10] and 15=03 then Write('3«",720k ':10);
        If CMOS^[$10] and 15=04 then Write('3«",1440k ':10);
        If CMOS^[$10] and 15=05 then Write('3«"2.88Mb ':10);
        If CMOS^[$10] and 15=06 then Write('3«"5.76Mb ':10);
        If CMOS^[$10] and 15=07 then Write('7 ':10);
        If CMOS^[$10] and 15=08 then Write('8 ':10);
        If CMOS^[$10] and 15=09 then Write('9 ':10);
        If CMOS^[$10] and 15=10 then Write('A ':10);
        If CMOS^[$10] and 15=11 then Write('B ':10);
        If CMOS^[$10] and 15=12 then Write('C ':10);
        If CMOS^[$10] and 15=13 then Write('D ':10);
        If CMOS^[$10] and 15=14 then Write('E ':10);
        If CMOS^[$10] and 15=15 then Write('F ':10);
        {Write(HexByte(CMOS^[$10])+' ':10);}

        If Pozice=5 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 128;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,10);{ Mouse Support Option }
        If CMOS^[$11] and 128=128 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=6 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 64;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,11);{ Above 1MB Memory Test }
        If CMOS^[$11] and 64=64 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=7 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 32;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,12);{ Memory Test Tick Sound }
        If CMOS^[$11] and 32=32 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=8 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 16;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,13);{ Memory Parity Error Check }
        If CMOS^[$11] and 16=16 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=9 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 8;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,14);{ Hit <Del> Message Display }
        If CMOS^[$11] and 8=8 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=10 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 4;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,15);{ Hard Disk 47 RAM Area }
        If CMOS^[$11] and 4=4 then Write('DOS 1Kb ':10) else Write('0:300  ':10);

        If Pozice=11 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 2;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,16);{ Wait For <F1> If Error }
        If CMOS^[$11] and 2=2 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=12 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$11;Port[$71]:=Port[$71] xor 1;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,17);{ Boot up Num Lock }
        If CMOS^[$11] and 1=1 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=13 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,18);{ Fixed disk 1 type }
        If CMOS^[$19]=0 then Write('None ':10) else Write(CMOS^[$19]:9,' ');

        If Pozice=14 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,19);{ Fixed disk 2 type }
        If CMOS^[$1A]=0 then Write('None ':10) else Write(CMOS^[$1A]:9,' ');

        If Pozice=15 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$13;Port[$71]:=Port[$71] xor 128;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,20);{ Typematic Programming }
        If CMOS^[$13] and 128=128 then Write('Enable ':10) else Write('Disable ':10);

        Scan:=0;
        If Keypressed then GetKey;
        If (Scan=73)or(Scan=81) then Save:=True;
      until (Scan=1)or(Scan=75)or(Scan=77);
      If (Scan=75)and(Page>0) then Dec(Page);
      If (Scan=77)and(Page<3) then Inc(Page);
    end;
    {****************************************************************}
    If Page=2 then
    begin
      TextColor(0);TextBackground(7);
      GotoXY(55,22);Write(' ',Page+1:2,' ');
      Frame(20,3,59,20,128+8);
      GotoXY(22,05);Write('Typematic Delay  (ms)');
      GotoXY(22,06);Write('Typematic Rate (ch/s)');
      GotoXY(22,07);Write('Number of Floppy Drives');
      GotoXY(22,08);Write('Monitor type');
      GotoXY(22,09);Write('Display test');
      GotoXY(22,10);Write('Keyboard test');
      GotoXY(22,11);Write('Math Coprocessor Test');
      GotoXY(22,12);Write('Floppy Drive Test');
      GotoXY(22,13);Write('Base Memory');
      GotoXY(22,14);Write('Extended Memory');
      GotoXY(22,15);Write('HD -Cylinders');
      GotoXY(22,16);Write('   -Heads');
      GotoXY(22,17);Write('   -Write Precomp Cylinder');
      GotoXY(22,18);Write('   -Control Byte');
      GotoXY(22,19);Write('   -Landing Zone');
      GotoXY(22,20);Write('   -Sectors per Track');
      Repeat
        Delay(5);
        ReadCMOS;
        If (Scan=72)and(Pozice>0)then Dec(Pozice);
        If (Scan=80)and(Pozice<15)then Inc(Pozice);

        If Pozice=0 then
        begin
          TextColor(10);TextBackground(0);
          Port[$70]:=$13;
          If Scan=81 then Port[$71]:=Port[$71]-1;
          If Scan=73 then Port[$71]:=Port[$71]+1;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,5);{ Typematic Delay  (ms) }
        If CMOS^[$13] and 32+64=0 then Write('1 ':10);
        If CMOS^[$13] and 32+64=32 then Write('2 ':10);
        If CMOS^[$13] and 32+64=64 then Write('3 ':10);
        If CMOS^[$13] and 32+64=32+64 then Write('500 ':10);

        If Pozice=1 then
        begin
          TextColor(10);TextBackground(0);
          If Scan=73 then
          begin
            Inc(CMOS^[$13]);
            Port[$70]:=$13;Port[$71]:=CMOS^[$13];
          end;
          If Scan=81 then
          begin
            Dec(CMOS^[$13]);
            Port[$70]:=$13;Port[$71]:=CMOS^[$13];
          end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,6);{ Typematic Rate (ch/s) }
        {If CMOS^[$13] and 4+8+16=0 then Write('1 ':10);
        If CMOS^[$13] and 4+8+16=32 then Write('2 ':10);
        If CMOS^[$13] and 4+8+16=64 then Write('3 ':10);
        If CMOS^[$13] and 4+8+16=15 then Write('15 ':10);}
        Write(CMOS^[$13]:9,' ');

        If Pozice=2 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,7);{ Number of Floppy Drives }
        B:=0;
        If CMOS^[$14] and 128=128 then B:=B or 1;
        If CMOS^[$14] and 64=64 then B:=B or 2;
        If B=0 then Write('None ':10) else Write(B:9,' ');

        If Pozice=3 then
        begin
          TextColor(10);TextBackground(0);
          Port[$70]:=$14;
          B:=0;
          If CMOS^[$14] and 32=32 then B:=B or 2;
          If CMOS^[$14] and 16=16 then B:=B or 1;
          If Scan=81 then
          begin
            If B<3 then Inc(B);
            Port[$71]:=Port[$71] and (255-(16+32));
            asm ROL B,4 end;
            Port[$71]:=Port[$71] or B;
            asm ROR B,4 end;
          end;
          If Scan=73 then
          begin
            If B>0 then Dec(B);
            Port[$71]:=Port[$71] and (255-(16+32));
            asm ROL B,4 end;
            Port[$71]:=Port[$71] or B;
            asm ROR B,4 end;
          end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,8);{ Monitor type }
        If CMOS^[$14] and (32+16)=0 then Write('EGA/VGA':10);
        If CMOS^[$14] and (32+16)=16 then Write('CGA40':10);
        If CMOS^[$14] and (32+16)=32 then Write('CGA80':10);
        If CMOS^[$14] and (32+16)=32+16 then Write('MDA':10);

        If Pozice=4 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$14;Port[$71]:=Port[$71] xor 8;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,9);{ Display(?)/reserved? }
        If CMOS^[$14] and 8=8 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=5 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$14;Port[$71]:=Port[$71] xor 4;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,10);{ Keyboard(?)/reserved? }
        If CMOS^[$14] and 4=4 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=6 then
        begin
          TextColor(12);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$14;Port[$71]:=Port[$71] xor 2;end;
        end
        else begin TextColor(4);TextBackground(7);end;
        GotoXY(51,11);{ Math Coprocessor Test? }
        If CMOS^[$14] and 2=2 then Write('Yes ':10)else Write('No ':10);

        If Pozice=7 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$14;Port[$71]:=Port[$71] xor 1;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,12);{ Floppy Drive Test? }
        If CMOS^[$14] and 1=1 then Write('Yes ':10)else Write('No ':10);

        If Pozice=8 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,13);{ Base Memory (kBytes) }
        B:=CMOS^[$16];W:=B;W:=Swap(W);B:=CMOS^[$15];W:=W+B;
        Write(W:8,'k ');

        If Pozice=9 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,14);{ Extended Memory (kBytes) }
        B:=CMOS^[$18];W:=B;W:=Swap(W);B:=CMOS^[$17];W:=W+B;
        Write(W:8,'k ');

        If Pozice=10 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(50,15);{ HD -Cylinders }
        B:=CMOS^[$1C];W:=B;W:=Swap(W);B:=CMOS^[$1B];W:=W+B;
        Write(W:5,'(');
        B:=CMOS^[$26];W:=B;W:=Swap(W);B:=CMOS^[$25];W:=W+B;
        Write(W:4,')');


        If Pozice=11 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(50,16);{ HD -Heads }
        Write(CMOS^[$1D]:5,'(',CMOS^[$27]:4,')');

        If Pozice=12 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(49,17);{ HD -Write Precomp Cylinder }
        B:=CMOS^[$1F];W:=B;W:=Swap(W);B:=CMOS^[$1E];W:=W+B;
        Write(W:5,'(');
        B:=CMOS^[$29];W:=B;W:=Swap(W);B:=CMOS^[$28];W:=W+B;
        Write(W:5,')');

        If Pozice=13 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,18);{ HD -Control Byte }
        Write(LeadingZero(CMOS^[$20]):4,'(',LeadingZero(CMOS^[$2A]):4,')');

        If Pozice=14 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,19);{ HD -Landing Zone }
        B:=CMOS^[$22];W:=B;W:=Swap(W);B:=CMOS^[$21];W:=W+B;
        Write(W:4,'(');
        B:=CMOS^[$2B];W:=B;W:=Swap(W);B:=CMOS^[$2A];W:=W+B;
        Write(W:4,')');

        If Pozice=15 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,20);{ HD -Sectors per Track }
        Write(CMOS^[$23]:4,'(');
        Write(CMOS^[$2C]:4,')');

        Scan:=0;
        If Keypressed then GetKey;
        If (Scan=73)or(Scan=81) then Save:=True;
      until (Scan=1)or(Scan=75)or(Scan=77);
      If (Scan=75)and(Page>0) then Dec(Page);
      If (Scan=77)and(Page<3) then Inc(Page);
    end;
    {****************************************************************}
    If Page=3 then
    begin
      TextColor(0);TextBackground(7);
      GotoXY(55,22);Write(' ',Page+1:2,' ');
      Frame(20,3,59,20,128+8);
      GotoXY(22,05);Write('Weitek Prosessor');
      GotoXY(22,06);Write('Floppy Drive Seek');
      GotoXY(22,07);Write('Boot Order');
      GotoXY(22,08);Write('Boot Up CPU Speed');
      GotoXY(22,09);Write('External Cache');
      GotoXY(22,10);Write('Internal Cache');
      GotoXY(22,11);Write('Fast Gate A20 at Boot');
      GotoXY(22,12);Write('Turbo Switch Function');
      GotoXY(22,13);Write('Standard CMOS Checksum');
      GotoXY(22,14);Write('Extended memory');
      GotoXY(22,15);Write('Century byte (BCD)');
      GotoXY(22,16);Write('Information Flags');
      GotoXY(22,17);Write('Numeric Processor');
      GotoXY(22,18);Write('reserved');
      GotoXY(22,19);Write('Password');
      GotoXY(22,20);Write('Encrypted password');
      Repeat
        Delay(5);
        ReadCMOS;
        If (Scan=72)and(Pozice>0)then Dec(Pozice);
        If (Scan=80)and(Pozice<15)then Inc(Pozice);

        If Pozice=0 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 128;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,5);{ Weitek installed }
        If CMOS^[$2D] and 128=128 then Write('Present ':10)else Write('Absent ':10);

        If Pozice=1 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 64;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,6);{ Floppy Drive Seek }
        If CMOS^[$2D] and 64=64 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=2 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 32;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,7);{ Boot sequence }
        If CMOS^[$2D] and 32=32 then Write('A:,C: ':10) else Write('C:,A: ':10);

        If Pozice=3 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 16;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,8);{ Boot Up CPU Speed }
        If CMOS^[$2D] and 16=16 then Write('High ':10) else Write('Low ':10);

        If Pozice=4 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 8;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,9);{ External Cache }
        If CMOS^[$2D] and 8=8 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=5 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 4;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,10);{ Internal Cache }
        If CMOS^[$2D] and 4=4 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=6 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 2;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,11);{ Fast Gate A20 at Boot }
        If CMOS^[$2D] and 2=2 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=7 then
        begin
          TextColor(10);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$2D;Port[$71]:=Port[$71] xor 1;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,12);{ Turbo Switch Function }
        If CMOS^[$2D] and 1=1 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=8 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,13);{ Standard CMOS Checksum }
        Write(HexByte(CMOS^[$2E])+HexByte(CMOS^[$2F]):9,' ');

        If Pozice=9 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,14);{ Extended Memory }
        B:=CMOS^[$31];W:=B;W:=Swap(W);B:=CMOS^[$30];W:=W+B;
        Write(W:8,'k ');

        If Pozice=10 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,15);{ Century byte (BCD) }
        Write(HexByte(CMOS^[$32]):9,' ');

        If Pozice=11 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,16);{ Information Flags }
        Write(HexByte(CMOS^[$33]):9,' ');

        If Pozice=12 then
        begin
          TextColor(12);TextBackground(0);
          If (Scan=81)or(Scan=73) then
          begin Port[$70]:=$35;Port[$71]:=Port[$71] xor 1;end;
        end
        else begin TextColor(4);TextBackground(7);end;
        GotoXY(51,17);{ Numeric Processor Test }
        If CMOS^[$35] and 1=1 then Write('Enable ':10) else Write('Disable ':10);

        If Pozice=13 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,18);{ reserved }
        Write(HexByte(CMOS^[$36]):9,' ');

        If Pozice=14 then
        begin
          TextColor(10);TextBackground(0);
          If Scan=73 then
          begin Port[$70]:=$34;Port[$71]:=Port[$71] xor 64;end;
          If Scan=81 then
          begin Port[$70]:=$34;Port[$71]:=Port[$71] xor 128;end;
        end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(51,19);{ Password }
        If CMOS^[$34] and 128+64=0 then Write('Disable ':10);
        If CMOS^[$34] and 128+64=64 then Write('Setup ':10);
        If CMOS^[$34] and 128+64=128 then Write('??? ':10);
        If CMOS^[$34] and 128+64=128+64 then Write('Always ':10);

        If Pozice=15 then begin TextColor(10);TextBackground(0);end
        else begin TextColor(0);TextBackground(7);end;
        GotoXY(42,20);{ Encrypted password }
        Write(HexByte(CMOS^[$38])+' '+HexByte(CMOS^[$39])+' '+
              HexByte(CMOS^[$3A])+' '+HexByte(CMOS^[$3B])+' '+
              HexByte(CMOS^[$3C])+' '+HexByte(CMOS^[$3D]):18,' ');
        Scan:=0;
        If Keypressed then GetKey;
        If (Scan=73)or(Scan=81) then Save:=True;
        If (Scan=77)and(Page=3)then Scan:=0;
      until (Scan=1)or(Scan=75)or(Scan=77);
      If (Scan=75)and(Page>0) then Dec(Page);
      If (Scan=77)and(Page<3) then Inc(Page);
    end;
  until (Scan=1);
  SetScreen2(1);
end;


Procedure SaveCMOS;
Var
  F:File;
  Soubor:String[80];
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  ReadCMOS;
  Soubor:=ChooseFile('*.CMS');
  FSplit(FExpand(Soubor),D,N,E);
  If E<>'.CMS' then E:='.CMS';
  Soubor:=D+N+E;
  Assign(F,Soubor);
  If Scan=1 then Exit;
  {$I-}Reset(F,1);{$I+}
  If IOResult=0 then
  begin
    GetScreen2(1);
    OkMessage('Soubor ji‘ existuje, p©epsat ?');
    SetScreen2(1);
    If Scan=28 then
    begin
      {$I-}Rewrite(F,1);{$I+}ErrorMessage;
      If IORes<>0 then Exit;
    end;
  end
  else
  {$I-}Rewrite(F,1);{$I+}ErrorMessage;
  If IORes<>0 then Exit;
  {$I-}BlockWrite(F,CMOS^,255);{$I+}ErrorMessage;
  {$I-}Close(F);{$I+}ErrorMessage;
end;


Procedure LoadCMOS;
Var
  F:File;
  Soubor:String[80];
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  ReadCMOS;
  Soubor:=ChooseFile('*.CMS');
  FSplit(FExpand(Soubor),D,N,E);
  If E<>'.CMS' then E:='.CMS';
  Soubor:=D+N+E;
  Assign(F,Soubor);
  If Scan=1 then Exit;
  {$I-}Reset(F,1);{$I+}ErrorMessage;
  If IORes<>0 then Exit;
  {$I-}BlockRead(F,CMOS^,255);{$I+}ErrorMessage;
  {$I-}Close(F);{$I+}ErrorMessage;

  For I:=0 to 255 do
  begin
    Port[$70]:=I;
    Port[$71]:=CMOS^[I];
  end;
  Save:=True;
end;


Procedure Warning;
begin
  GetScreen2(2);
  Frame(10,3,70,20,129+64);
  Center(3,' Upozornˆn¡ ');
  GotoXY(14,6);Write('- Program byl navr‘en pouze pro pou‘it¡ v syst‚mech');
  GotoXY(14,7);Write('  s AMIBIOSem. P©i pou‘iti tohoto programu v syst‚mu');
  GotoXY(14,8);Write('  s jin˜m typem BIOSu m–‘e doj¡t k nastaven¡ chybn˜ch');
  GotoXY(14,9);Write('  £daj–.');
  GotoXY(14,11);Write('- P©i zmˆnˆ ‡erven‚ polo‘ky m–‘e doj¡t k chybn‚mu CRC !');

  GetKey;
  SetScreen2(2);
end;


Procedure NullCMOS;
Var
  PASSWORD:String[20];
  F:File;
  Attr:Word;
  TEST:String[4];
begin
  Assign(F,ParamStr(0));
  GetFAttr(F,Attr);
  SetFAttr(F,0);
  Reset(F,1);
  Seek(F,FileSize(F)-26);
  BlockRead(F,TEST,5);
  Randomize;
  RandSeed:=211;
  For I:=0 to 4 do TEST[I]:=Chr(ord(TEST[I]) xor Random(255));

  If TEST='CMOS' then
  begin
    GetScreen2(2);
    TextColor(0);TextBackground(7);
    Frame(29,9,51,11,129+64);
    GotoXY(35,10);Write(' USER PASSWORD ');
    TextColor(15);TextBackground(1);
    InputLine(30,10,20,'');
    SetScreen2(2);
    If Scan=1 then Exit;
  end
  else
  begin
    GetScreen2(2);
    TextColor(0);TextBackground(7);
    Frame(25,9,55,11,129+64);
    GotoXY(29,10);Write(' ENTER NEW USER PASSWORD ');
    TextColor(15);TextBackground(1);
    InputLine(30,10,20,'');
    If Scan=1 then
    begin
      SetScreen2(2);
      Exit;
    end;
    PASSWORD:=Vstup;
    TextColor(0);TextBackground(7);
    GotoXY(27,10);Write(' RE-ENTER NEW USER PASSWORD ');
    TextColor(15);TextBackground(1);
    InputLine(30,10,20,'');
    If Scan=1 then
    begin
      SetScreen2(2);
      Exit;
    end;
    If PASSWORD<>Vstup then
    begin
      TextColor(15);TextBackground(4);
      Frame(25,9,55,11,129+64);
      GotoXY(28,11);Write('New password is not correct');
      GetKey;
    end
    else
    begin
      TEST:='CMOS';
      RandSeed:=211;
      For I:=0 to 4 do TEST[I]:=Chr(ord(TEST[I]) xor Random(255));
      Seek(F,FileSize(F));
      BlockWrite(F,TEST,5);

      RandSeed:=102;
      For I:=0 to 20 do PASSWORD[I]:=Chr(ord(PASSWORD[I]) xor Random(255));
      BlockWrite(F,PASSWORD,21);
      Close(F);

      TextColor(15);TextBackground(2);
      Frame(25,9,55,11,129+64);
      GotoXY(30,11);Write('Password is now enabled');
      GetKey;
      SetScreen2(2);
      Exit;
    end;
    SetScreen2(2);
  end;


  BlockRead(F,PASSWORD,21);
  Close(F);
  SetFAttr(F,Attr);

  RandSeed:=102;
  For I:=0 to 20 do PASSWORD[I]:=Chr(ord(PASSWORD[I]) xor Random(255));

  If (TEST='CMOS')and(Vstup<>PASSWORD) then
  begin
    TextBackground(7);TextColor(8);GotoXY(53,25);Write('Null');
    GetScreen2(2);
    TextColor(15);TextBackground(4);
    Frame(25,7,57,13,129+64);
    GotoXY(35,10);Write(#7' Access denied ');
    TextColor(15+16);TextBackground(4);
    GotoXY(33,12);Write('Incorrect password !');
    GetKey;
    SetScreen2(2);
  end;

  If (TEST='CMOS')and(Vstup=PASSWORD) then
  begin
    TextBackground(7);TextColor(8);GotoXY(53,25);Write('Null');
    GetScreen2(2);
    TextColor(15);TextBackground(4);
    Frame(10,10,70,12,129+64);
    Center(11,#7'Opravdu chcete vymazat celou pamet CMOS ? (A/N)');
    Repeat
      GetKey;
    until (UpCase(chr(ASCII))='A')or(UpCase(chr(ASCII))='N');
    If (UpCase(chr(ASCII))='A') then
    begin
      TextColor(15);TextBackground(4);
      Frame(10,10,70,12,129+64);
      Center(11,#7'             Jste si opravdu jist ?            ');
      Repeat
        GetKey;
      until (UpCase(chr(ASCII))='A')or(UpCase(chr(ASCII))='N');
      If (UpCase(chr(ASCII))='A') then
      begin
        For I:=0 to 255 do
        begin
          Port[$70]:=I;
          Port[$71]:=0;
        end;
        Save:=True;
        TextColor(0);TextBackground(7);
        Frame(7,10,73,12,129+64);
        Center(11,'Pamˆt CMOS byla vynulov na.  Nyn¡ m–‘ete po‡¡ta‡ restartovat.');
        GetKey;
      end;
    end;
    SetScreen2(2);
  end;
end;

Begin
  GetCheckSum;
  CheckSum0:=CheckSumNow;
  For I:=0 to 255 do
  begin
    Port[$70]:=I;
    CMOSBuf[I]:=Port[$71];
  end;

  New(CMOS);
  InitStandardScreen('±',1,8,2);
  InitDownMenu('~Alt-X~ Exit  ~F1~ Help  ~F2~ Save  ~F3~ Load  ~F4~ Edit  ~F8~ Null  ~F10~ About',25);
  TextColor(8);GotoXY(53,25);Write('Null');
  TextColor(0);TextBackground(7);
  Center(0,OEM);
  Save:=False;
  Warning;
  Repeat
    If Scan=60 then SaveCMOS;
    If Scan=61 then LoadCMOS;
    If Scan=62 then CMOSInfo;
    If Scan=66 then NullCMOS;
    If Scan=68 then About(OEM,Ver);
    Scan:=0;If Keypressed then GetKey;
  until (Scan=45)and(Ascii=0);
  GetCheckSum;

  If (CheckSum0<>CheckSumNow)or(Save) then
  begin
    Save:=True;
    TextColor(15);TextBackground(4);
    Frame(18,10,61,15,128);
    Center(10,' Obsah CMOS se zmˆnil ');
    B:=0;
    Repeat
      If B=0 then TextBackground(11);
      If B=1 then TextBackground(4);
      Center(12,'            Akceptovat zmˆny              ');
      If B=0 then TextBackground(4);
      If B=1 then TextBackground(11);
      Center(13,'        Obnovit p–vodn¡ nastaven¡         ');
       GetKey;
       If SCAN=72 then B:=0;
       If SCAN=80 then B:=1;
    until (SCAN=1)or(SCAN=28);
    If (B=0)or(SCAN=28) then Save:=True;
    If (B=1)or(SCAN=1) then Save:=False;
  end;
  WriteCMOSCheckSum;
  If not Save then
  For I:=0 to 255 do
  begin
    Port[$70]:=I;
    Port[$71]:=CMOSBuf[I];
  end;
  Dispose(CMOS);
  Done;
end.