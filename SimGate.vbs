'PROGRAM : DAM GATE SIMULATION
'MAPPING REGISTER 4XXXX
'+0		'CURPOS MM
'+1		'Command  (0: noCommand, 1:Reset, 2:Stop, 3:Open, 4:Close)
'+2		'MINPOS MM 
'+3		'MAXPOS MM
'+4		'SPAN/STEP MM
'+5		'CURRENT (A), DEFAULT: 10
'+6		'VOLTAGE (v), DEFAULT: 380
'+7		'VOLTAGE (v), DEFAULT: 380
'+8		'VOLTAGE (v), DEFAULT: 380
'+9		'L/R STATUS
'+10	'O/C STATUS 
'+11	'FULLY O/C
'+12	'OVER TORQUE  ` (0: NO ALARM, 1:OVER TORQUE OPENED, 2:OVER TORQUE CLOSED) 
'+13	'OVERLOAD     ` (0: NO OVERLOAD, 1:OVERLOAD) 
'+14	'EARTH LEAKED  `(0: NO EARTH LEAKED, 1:EARTH LEAKED)
'+15	'3E PROTECTION
'+16	'ESD STATUS
'+17	'
'+18	'
'+19	'DEFAULT MINPOS
'+20	'DEFAULT MAXPOS
'+21	'DEFAULT SPAN
'+22	'
'+23	'
'+..	'
'+29	'
'DIM IA

dim maxPLC : maxPLC = 32	'Max Gate PLC
dim DefPlc : DefPlc = 8			'Defaul Jumlah PLC
dim nReg: nReg = 30 		'nReg : jumlah Register yg di gunakan masing2 GATE
dim DefMin: DefMin = 0 	'+2
dim DefMax: DefMax = 6000 	'+3'Default Gate max Position eg. 6000 mm
dim DefSpan: DefSpan = 500 '100
dim DefCurrent : DefCurrent = 10
dim DefVR : DefVR = 380 
dim DefVS : DefVS = 380 
dim DefVT : DefVT = 380 
dim DefLR : DefLR = 2 
dim DefFOC : DefFOC = 2 
dim simMinCur : simMinCur = 9    'min Current SIMULATION
dim simMaxCur : simMaxCur = 29	 'max Current SIMULATION


Call Main()

'MaxGateSim : disimpan di 3x:0, aktif index gate di 3x:1
Sub Main()
	InitNumPLC()
	Sim()
End Sub

sub InitNumPLC()
	'jumlah plc di baca di register 3x1 
	dim iPlc : iPlc = GetRegisterValue(2,1)
	if ((iPlc <= 0) OR (iPlc > maxPLC)) then 
		iPlc = DefPlc
		SetRegisterValue 2,1,iPlc
	end if
 
	'Set Active PLC
	dim a:	a = GetRegisterValue(2,0) + 1
	if (a > iPlc-1) then a = 0
	SetRegisterValue 2,0,a 
	
end Sub

sub InitDefVal(idx)
	'RESET reg:0-30 = 0 
	dim IMin: IMin=(nReg * idx)
	dim IMax: IMax=(nReg * idx) + nReg  
		for i=IMin to IMax : SetRegisterValue 3, i,0 :		next
	
	
	dim regDefMin: regDefMin = (nReg * idx) + 2 	
	dim regDefMax: regDefMax = (nReg * idx) + 3 	
	dim regDefSpan : regDefSpan = (nReg * idx) + 4 
	dim regDefCurrent : regDefCurrent =  (nReg * idx) + 5
	dim regDefVR : regDefVR =  (nReg * idx) + 6
	dim regDefVS : regDefVS =  (nReg * idx) + 7
	dim regDefVT : regDefVT =  (nReg * idx) + 8
	dim regDefLR : regDefLR =  (nReg * idx) + 9
	dim regDefFOC : regDefFOC =  (nReg * idx) + 11
		
	'Default Gate max Position eg. 6000 mm  
		SetRegisterValue 3, regDefMin,DefMin
		SetRegisterValue 3, regDefMax,DefMax

	'Default Span	'100
		SetRegisterValue 3, regDefSpan,DefSpan
		SetRegisterValue 3, regDefCurrent,DefCurrent
		SetRegisterValue 3, regDefVR,DefVR
		SetRegisterValue 3, regDefVS,DefVS
		SetRegisterValue 3, regDefVT,DefVT
		SetRegisterValue 3, regDefLR,DefLR
		SetRegisterValue 3, regDefFOC,DefFOC

		SetRegisterValue 3,(nReg * idx) + 29,4 'cmd InitDevVal in last Command


end Sub

sub Sim()
'	dim nReg: nReg = 30 		'nReg : jumlah Register yg di gunakan masing2 GATE
	dim idx: idx = GetRegisterValue(2,0)
	'Baca Perintah di Register : 4x1
	dim regCMD : regCMD = (nReg * idx) + 1 
	dim cmd: cmd = GetRegisterValue(3,regCMD )
	
	Select Case cmd
		Case 0: 'no Command
		Case 1,2,3: call Operate (Idx, cmd)	'Gate Open 

		Case 4: InitDefVal(idx)	'Reset to default Val
		Case 5: call SetLR(idx, cmd, 1) 'call SetLocalRemote(idx,1) 'Set L/R to Local (40010 = 1)
		Case 6: call SetLR(idx, cmd, 2) 'Set L/R to Local (40010 = 1)
		Case 7: call SetOTOC(idx, cmd, 0) 'Set OVER TORQUE to Normal (40013 = 0)
		Case 8: call SetOTOC(idx, cmd, 1) 'Set OVER TORQUE OPEN (40013 = 1)
		Case 9: call SetOTOC(idx, cmd, 2) 'Set OVER TORQUE CLOSE (40013 = 2)
		Case 10: call SetOL(idx, cmd, 0) 'Set OVERLOAD Normal (40014 = 0)
		Case 11: call SetOL(idx, cmd, 1) 'Set OVERLOAD  (40014 = 1) 
		Case 12: call SetEL(idx, cmd, 0) 'Set EARTH LEAKED Normal (40015 = 0)
		Case 13: call SetEL(idx, cmd, 1) 'Set EARTH LEAKED (40015 = 1)
		Case 14: call SetE3(idx, cmd, 0) 'Set 3E PROTECTION Normal (40016 = 0)
		Case 15: call SetE3(idx, cmd, 1) 'Set 3E PROTECTION (40016 = 1)
		Case 16: call SetESD(idx, cmd, 0) 'Set ESD Normal (40017 = 0)
		Case 17: call SetESD(idx, cmd, 1) 'Set ESD (40017 = 1)
		Case 18: call SetSpare1(idx, cmd, 0) 'Set SPARE1 Normal (40018 = 0)
		Case 19: call SetSpare1(idx, cmd, 1) 'Set SPARE1 (40018 = 1)
		Case 20: call SetSpare2(idx, cmd, 0) 'Set SPARE2 Normal (40019 = 0)
		Case 21: call SetSpare2(idx, cmd, 1) 'Set SPARE2 (40019 = 1)
	    Case 22: call SetSpare3(idx, cmd, 0) 'Set SPARE3 Normal (40020 = 0)
	    Case 23: call SetSpare3(idx, cmd, 1) 'Set SPARE3 (40020 = 1)
	end Select
	
end Sub

sub Operate(Idx, cmd)
'	dim nReg: nReg = 30 		'nReg : jumlah Register yg di gunakan masing2 GATE
	dim regDefCurrent : regDefCurrent =  (nReg * idx) + 5

	SetRegisterValue 3,(nReg * Idx) + 29,cmd 	'cmd InitDevVal in last Command

	'baca posisi
	dim regCurPos : regCurPos = (nReg * Idx)
	dim regCmd : regCmd =  (nReg * Idx) + 1
	dim curPos : curPos = GetRegisterValue(3,regCurPos)
	dim minPos : minPos = GetRegisterValue(3,(nReg * Idx)+2 )
	dim maxPos : maxPos = GetRegisterValue(3,(nReg * Idx)+3 )
	dim span   : span = GetRegisterValue(3,(nReg * Idx)+4 )
	dim regFOC : regFOC = (nReg * idx) + 11 '+11 'FO/C 
	dim regOC  : regOC = (nReg * Idx) + 10 '+10	'O/C STATUS 
	dim regI   : regI = (nReg * Idx) + 5 
	dim nPO : nPO = curPos + Span 
	dim nPC : nPC = curPos - Span
	dim nPos ' New Pos
	Select Case cmd
		Case 1:  
		    nPos = nPO 
			if(nPos >=maxPos) then 
			   curPos = maxPos
			   'set FO
			   SetRegisterValue 3, regFOC, 1      'FullyOpen
			   SetRegisterValue 3, regOC, 0          'O/C 
		   
			   SetRegisterValue 3, regI, 0	 'Sim Current 
			   
			   SetRegisterValue 3, regCurPos, curPos
			   ResetCMD(idx)
			Else
			   SetRegisterValue 3, regFOC, 0
			   SetRegisterValue 3, regOC, 1

			   SetRegisterValue 3, regI, XA()

			   SetRegisterValue 3, regCurPos, nPos
			end if 
		Case 2:  'SetSimCur(idx) 'Gate Close
		    nPos = nPC 
			if(nPos <=minPos) then 
			   curPos = minPos
			   'set FO
			   SetRegisterValue 3, regFOC, 2      'FullyOpen
			   SetRegisterValue 3, regOC, 0          'O/C 
		   
			   SetRegisterValue 3, regI, 0	 'Sim Current 
			   
			   SetRegisterValue 3, regCurPos, curPos
			   'tutup Perintah
			   SetRegisterValue 3, regCmd ,0 'Reset Command 
			Else
			   SetRegisterValue 3, regFOC, 0
			   SetRegisterValue 3, regOC, 2				'O/C 

			   SetRegisterValue 3, regI, XA()

			   SetRegisterValue 3, regCurPos, nPos
			end if 
		
		Case 3:  'SetRegisterValue 3, regDefCurrent, 0  'Gate Stop
			ResetCMD(idx)
			SetRegisterValue 3, regOC, 0          'O/C 
	end Select
	
	
end Sub

'Random Arus
function XA()
	dim r
	dim min: min = simMinCur
	dim max: max = simMaxCur

	randomize
	r = Int((max-min+1)*Rnd+min) 'int(rnd*100) + 1
	XA = r
end function

sub ResetCMD(idx)
	dim regCmd : regCmd = (nReg * idx) + 1
	SetRegisterValue 3, regCmd ,0
end sub 

sub SetLR(idx, cmd, LR)
	dim regLR : regLR = (nReg * idx) + 9
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regLR ,LR
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetOTOC(idx, cmd, OTOC)
	dim regOTOC : regOTOC = (nReg * idx) + 12
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regOTOC ,OTOC
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetOL(idx, cmd, OL)
	dim regOL : regOL = (nReg * idx) + 13
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regOL ,OL
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetEL(idx, cmd, EL)
	dim regEL : regEL = (nReg * idx) + 14
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regEL ,EL
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetE3(idx, cmd, E3)
	dim regE3 : regE3 = (nReg * idx) + 14
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regE3 ,E3
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetESD(idx, cmd, ESD)
	dim regESD : regESD = (nReg * idx) + 15
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regESD ,ESD
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetSpare1(idx, cmd, Spare1)
	dim regSpare1 : regSpare1 = (nReg * idx) + 16
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regSpare1 ,Spare1
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetSpare2(idx, cmd, Spare2)
	dim regSpare2 : regSpare2 = (nReg * idx) + 17
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regSpare2 ,Spare2
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 

sub SetSpare3(idx, cmd, Spare3)
	dim regSpare3 : regSpare3 = (nReg * idx) + 18
	dim regCmd : regCmd = (nReg * idx) + 1
	dim regLastCmd : regLastCmd = (nReg * idx) + 29
	
	SetRegisterValue 3, regSpare3 ,Spare3
	SetRegisterValue 3, regLastCmd, cmd 	'cmd InitDevVal in last Command
	ResetCMD(idx)
end sub 
