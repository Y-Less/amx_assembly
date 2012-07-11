#include <amx_header>
#include <dynamic_call>
#include <phys_memory>

#define asm1(%0)          (0x90909000 | (%0))
#define asm2(%0,%1)       (0x90900000 | ((%1) << 8) | (%0))
#define asm3(%0,%1,%2)    (0x90000000 | ((%2) << 16) | ((%1) << 8) | %0)
#define asm4(%0,%1,%2,%3) (0x00000000 | ((%3) << 24) | ((%2) << 16) | (%1 << 8) | (%0))

#define asm5(%0,%1,%2,%3,%4)          asm4(%0,%1,%2,%3), asm1(%4)
#define asm6(%0,%1,%2,%3,%4,%5)       asm4(%0,%1,%2,%3), asm2(%4,%5)
#define asm7(%0,%1,%2,%3,%4,%5,%6)    asm4(%0,%1,%2,%3), asm3(%4,%5,%6)
#define asm8(%0,%1,%2,%3,%4,%5,%6,%7) asm4(%0,%1,%2,%3), asm4(%4,%5,%6,%7)

static stock ToCharString(s[], size = sizeof(s)) {
	for (new i = 0; i < size; i++) {
		s[i] = AlignCell(s[i]);
	}
}

// http://msdn.microsoft.com/en-us/library/windows/desktop/bb762153%28v=vs.85%29.aspx

#define SW_HIDE (0)
#define SW_MAXIMIZE (3)
#define SW_MINIMIZE (6)
#define SW_RESTORE (9)
#define SW_SHOW (5)
#define SW_SHOWDEFAULT (10)
#define SW_SHOWMAXIMIZED (3)
#define SW_SHOWMINIMIZED (2)
#define SW_SHOWMINNOACTIVE (7)
#define SW_SHOWNA (8)
#define SW_SHOWNOACTIVATE (4)
#define SW_SHOWNORMAL (1)

// NOTE: string arguments must be prepared with ToCharString() or similar function.
stock ShellExecute(const Operation[], const File[], const Parameters[], ShowCmd) {
	fopen("<>");
	new index = GetNativeIndexFromName("fopen");

	/*
	.text:10001000 55                                push    ebp
	.text:10001001 8B EC                             mov     ebp, esp
	.text:10001003 8B 45 0C                          mov     eax, [ebp+arg_4]
	.text:10001006 8B 48 18                          mov     ecx, [eax+18h]
	.text:10001009 51                                push    ecx             ; nShowCmd
	.text:1000100A 8B 55 0C                          mov     edx, [ebp+arg_4]
	.text:1000100D 8B 42 14                          mov     eax, [edx+14h]
	.text:10001010 50                                push    eax             ; lpDirectory
	.text:10001011 8B 4D 0C                          mov     ecx, [ebp+arg_4]
	.text:10001014 8B 51 10                          mov     edx, [ecx+10h]
	.text:10001017 52                                push    edx             ; lpParameters
	.text:10001018 8B 45 0C                          mov     eax, [ebp+arg_4]
	.text:1000101B 8B 48 0C                          mov     ecx, [eax+0Ch]
	.text:1000101E 51                                push    ecx             ; lpFile
	.text:1000101F 8B 55 0C                          mov     edx, [ebp+arg_4]
	.text:10001022 8B 42 08                          mov     eax, [edx+8]
	.text:10001025 50                                push    eax             ; lpOperation
	.text:10001026 8B 4D 0C                          mov     ecx, [ebp+arg_4]
	.text:10001029 8B 51 04                          mov     edx, [ecx+4]
	.text:1000102C 52                                push    edx             ; hwnd
	.text:1000102D FF 15 E0 60 00 10                 call    ds:ShellExecuteA ; Opens or prints a specified file
	.text:10001033 5D                                pop     ebp
	.text:10001034 C3                                retn
	*/

	static const asm[] = {
		asm1(0x55),
		asm2(0x8B, 0xEC),
		asm3(0x8B, 0x45, 0x0C),
		asm3(0x8B, 0x48, 0x18),
		asm1(0x51),
		asm3(0x8B, 0x55, 0x0C),
		asm3(0x8B, 0x42, 0x14),
		asm1(0x50),
		asm3(0x8B, 0x4D, 0x0C),
		asm3(0x8B, 0x51, 0x10),
		asm1(0x52),
		asm3(0x8B, 0x45, 0x0C),
		asm3(0x8B, 0x48, 0x0C),
		asm1(0x51),
		asm3(0x8B, 0x55, 0x0C),
		asm3(0x8B, 0x42, 0x08),
		asm1(0x50),
		asm3(0x8B, 0x4D, 0x0C),
		asm3(0x8B, 0x51, 0x04),
		asm1(0x52),
		asm6(0xFF, 0x15, 0x14, 0x52, 0x4A, 0x00),
		asm1(0x5D),
		asm1(0xC3)
	};

	new old = HookNative(index, refabs(asm));

	new retval = CallNative(index,
		0,                  // HWND hwnd
		refabs(Operation),  // LPCTSTR lpOperation
		refabs(File),       // LPCTSTR lpFile
		refabs(Parameters), // LPCTSTR lpParameters
		0,                  // LPCTSTR lpDirectory
		ShowCmd             // INT nShowCmd
	);

	HookNative(index, old);

	return retval;
}

main() {
	new File[] = !"notepad.exe";
	new Operation[] = !"open";
	new Parameters[] = !"server.cfg";

	ToCharString(File);
	ToCharString(Operation);
	ToCharString(Parameters);

	new result = ShellExecute(Operation, File, Parameters, SW_SHOW);
	printf("ShellExecute() returned %d", result);
}
