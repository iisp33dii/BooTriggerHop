namespace BHOPinBOO

import System
import System.Diagnostics
import System.Runtime.InteropServices

[DllImport("user32.dll")]
def GetAsyncKeyState(vKey as int) as int:
	pass

[DllImport("kernel32")]
def ReadProcessMemory(Handle as IntPtr, Address as int, ref Value as int, Size as int, BytesRead as int) as bool:
	pass

[DllImport("kernel32")]
def WriteProcessMemory(Handle as IntPtr, Address as int, buffer as (byte), Size as int, BytesWritten as int) as bool:
	pass	

OffsetLocalPlayer as int = 0xAABFFC
OffsetEntityList as int = 0x4A88534
OffsetForceJump as int = 0x4F1F4C8
OffsetForceAttack as int = 0x2ECA8C8

OffsetCrossHairId as int = 0xB2B4
OffsetLifeState as int = 0x25B
OffsetFFlags as int = 0x100
OffsetTeam as int = 0xF0

p as Process = Process.GetProcessesByName("csgo")[0]
Handle as IntPtr = p.Handle
ClientDLL as int

print "Modules:"
for M as ProcessModule in p.Modules:
	Console.WriteLine("{0,-7}0x{1,-15}{2, -30}", "  -->", string.Format("{0:x}", M.BaseAddress), M.ModuleName)
	if M.ModuleName == "client.dll":
		ClientDLL = M.BaseAddress
						
print " "
print "Address of ClientDLL: " +  string.Format("0x{0:x}", ClientDLL)

LocalPlayer as int
CrossHairId as int
EnemyPlayer as int
LifeState as int
fflags as int
MyTeam as int
EnemyTeam as int

while true:
	ReadProcessMemory(Handle, ClientDLL + OffsetLocalPlayer, LocalPlayer, 4, 0)
	
	if GetAsyncKeyState(32): //Keys.Space = 32				
		ReadProcessMemory(Handle, LocalPlayer + OffsetLifeState, LifeState, 4, 0)	
		ReadProcessMemory(Handle, LocalPlayer + OffsetFFlags, fflags, 4, 0)				
		if LocalPlayer != 0: 
			if LifeState == 0:
				if (fflags & (1 << 0)):
					WriteProcessMemory(Handle, ClientDLL + OffsetForceJump, BitConverter.GetBytes(5), 4, 0)
				else:
					WriteProcessMemory(Handle, ClientDLL+ OffsetForceJump, BitConverter.GetBytes(4), 4, 0)

	if GetAsyncKeyState(164): //Keys.LeftAlt = 164
		ReadProcessMemory(Handle, LocalPlayer + OffsetCrossHairId, CrossHairId, 4, 0)		
		if CrossHairId > 0:			
			if CrossHairId < 65:
				ReadProcessMemory(Handle, LocalPlayer + OffsetTeam, MyTeam, 4, 0)
				ReadProcessMemory(Handle, ClientDLL + OffsetEntityList + ((CrossHairId - 1) * 0x10), EnemyPlayer, 4, 0)
				ReadProcessMemory(Handle, EnemyPlayer + OffsetTeam, EnemyTeam, 4, 0)				
				if MyTeam != EnemyTeam:
					WriteProcessMemory(Handle, ClientDLL + OffsetForceAttack, BitConverter.GetBytes(5), 4, 0)
					Threading.Thread.Sleep(15)
					WriteProcessMemory(Handle, ClientDLL + OffsetForceAttack, BitConverter.GetBytes(4), 4, 0)
					Threading.Thread.Sleep(10)	
		
		
	Threading.Thread.Sleep(10)
