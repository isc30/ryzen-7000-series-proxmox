@echo off
pushd %~dp0

set ubuvers=1.79.17
if exist ubu17x*.* for /f %%f in ('dir ubu17x_upd*.exe /b') do start /wait %%f -y && del /f /q %%f


set sdir=Files\intel
set sdig=Files\intel\gop
set sdigv=Files\intel\gop_vbt
set sdiv=Files\intel\vbios
set sdlie=Files\Intel\lan\efi
set sdlio=Files\Intel\lan\orom
set sdim=Files\Intel\mcode

set sdar=Files\amd\raid
set sdag=Files\amd\gop
set sdav=Files\amd\vbios
set sdam=Files\amd\mcode

set sdlr=Files\Realtek
set sdlb=Files\Broadcom
set sdllx=Files\Lx
set sdly=Files\Yukon

set sdsm=Files\Marvell
set sdsa=Files\ASMedia
set sdsj=Files\JMicron

set sdmv=Files\matrox

set wf=Files\Workfiles

set uf=uefifind bios.bin
set ufbl=uefifind bios.bin body list
set ufal=uefifind bios.bin all list
set ue=uefiextract bios.bin
set renb=if exist tmpr\body.bin move tmpr\body.bin
set renb_1=if exist tmpr\body_1.bin move tmpr\body_1.bin
set renf=if exist tmpr\file.ffs move tmpr\file.ffs
set rdir=if exist tmpr rd /s /q tmpr
set ur=uefireplace bios.bin

rem set ous=oromutils set
rem set oue=oromutils extr
rem set ous=oromutils repl

set ok=File replaced

set pguid=00000000-0000-0000-0000-000000000000
set oeguid1=A0327FE0-1FDA-4E5B-905D-B510C45A61D0
set oeguid2=C02CFCE2-3021-42E6-8186-65FF0F5D9DE2
set csmguid1=A062CF1F-8473-4AA3-8793-600BC4FFE9A8
set csmguid2=365C62BA-05EF-4B2E-A7F7-92C1781AF4F9
set csmguid3=9F3A0016-AE55-4288-829D-D22FD344C347
	
for %%a in (UEFIReplace.exe UEFIReplace_025.exe UEFIFind.exe UEFIExtract.exe DrvVer.exe FindVer.exe findhex.exe mCodeFIT.exe SetDevID.exe cecho.exe oromreplace.exe) do (
 	if not exist %%a echo !!! %%a not found !!! && pause && exit
)

set mce=python mce.py
if exist mce.exe set mce=mce.exe && set mce_exe=1
set mceb=%mce% bios.bin

for /f "tokens=*" %%f in ('dir /a-d *.CAP *.ROM *.F?? *.BS? *.0?? *.1?? *.2?? *.3?? *.4?? *.5?? *.6?? *.7?? *.8?? *.9?? *.??0 *.??1 *.??2 *.??3 *.??4 bios.bin /b') do (
 	echo %%f
	set biosname=%%f
	if /I %%f==bios.bin goto rises
 	if /I exist bios.bin del /f /q bios.bin && ren "%%f" bios.bin && goto rises
	if /I not exist bios.bin ren "%%f" bios.bin && goto rises
)

setlocal
for /f "usebackq delims=" %%i in (
	`@"%systemroot%\system32\mshta.exe" "about:<FORM><INPUT type='file' name='qq'></FORM><script>document.forms[0].elements[0].click();var F=document.forms[0].elements[0].value;try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(F)};catch (e){};close();</script>" ^
	1^|more`
) do copy "%%i" "%~dp0\bios.bin">nul && set biosname=%%~nxi
if not exist bios.bin goto err
endlocal && set biosname=%biosname%

:rises
set tit=title UEFI BIOS Updater v%ubuvers% - %biosname%
%tit%

UEFIExtract bios.bin 4A3CA68B-7723-48FB-803D-578CC1FEC44D>nul && echo Remove Capsule Header
if exist bios.bin.dump\body.bin (copy /y bios.bin.dump\body.bin bios.bin>nul) else (rd /s /q bios.bin.dump)

set fit=0
%ufbl% 5F4649545F202020..0000000001>nul && set fit=1
if %fit%==1 mcodefit -fit_backup bios.bin

rem i-sda
rem for /f %%s in ('bios.bin') do set isda=%%s
findhex FFFFFFFFEAD0FF00F0000000000000000000272DFFFFFFFF bios.bin>nul && set ur=uefireplace_025 bios.bin

setlocal enableextensions enabledelayedexpansion
:mn
cls
if exist aptio rd /s /q aptio
if exist mfactur rd /s /q mfactur
if exist tmp rd /s /q tmp
md tmp\CSM
 %rdir%
if exist _OROM_in_GUIDs.txt del /f /q _OROM_in_GUIDs.txt

set irst=0
set irste=0
set vmd=0
set vmdd=0
set rxpt2=0
set o43xx=0
set o78xx=0
set mrvl=0
set mrvl61=0
set mrvl91=0
set mrvl92=0
set asmo=0
set jmbo=0
set lani=0
set lanrtk=0
set rtk1=0
set rtk2=0
set rvt1=0
set rvt2=0
set lanlx=0
set lanbcm=0
set lanyuk=0
set m1=0
set m2=0
set m3=0
set m4=0
set m5=0
set m6=0
set m7=0
set m8=0
set m9=0
set csm=0
set asus=0
set caphdr=0
set aa=0
set mc_pad=0
set gmc_count=0
set amd=0
set mmtool=0
set vbt_count=0
set vbt_sec=0
set gop=0

echo Scanning BIOS file %biosname%. 
echo Please wait...
%ue% 3FD1D3A2-99F7-420B-BC69-8BB1D492A332 -o aptio -m body>nul
%ue% AB56DC60-0057-11DA-A8DB-000102EEE626 -o mfactur -m body>nul

if exist mfactur\body.bin drvver mfactur\body.bin
set plat_bios=BIOS Platform -
if not exist aptio\body.bin (
	(%uf% body count 49006E00740065006C00AE004400650073006B0074006F007000200042006F00610072006400>nul || %uf% body count 49006E00740065006C00........4400650073006B0074006F007000200042006F00610072006400>nul) && echo %plat_bios% Intel Desktop Board. Not supported. && goto exit1
	%uf% body count 494E5359444548324F>nul && echo %plat_bios% InsydeH2O && goto next
	%uf% body count 50686F656E697820534354>nul && echo %plat_bios% PhoenixSCT && goto next
	echo Unknown platform BIOS && goto exit1
)

drvver aptio\body.bin
set aa=%errorlevel%

:next
rem Asus?
%uf% body count 4153555342....24>nul && set asus=1
rem Platform AMD?
%uf% body count 4147455341>nul && set amd=1 && goto findextr

if %fit%==0 %ue% 1BA0062E-C779-4582-8566-336AE8F78F09 -o tmpr -m file>nul && findhex 00F8FFFF tmpr\file.ffs>nul && set mc_pad=1
%uf% header count 728508177F37EF448F4EB09FFF46A070>nul && set mc_guid=17088572-377F-44EF-8F4E-B09FFF46A070 && set mc_patt=728508177F37EF448F4EB09FFF46A070&& set mc_patt_01=728508177F37EF448F4EB09FFF46A071&& set mc_patt_02=728508177F37EF448F4EB09FFF46A072
%uf% header count 36B27D1956F8244990F8CDF12FB875F3>nul && set mc_guid=197DB236-F856-4924-90F8-CDF12FB875F3 && set mc_patt=36B27D1956F8244990F8CDF12FB875F3&& set mc_patt_01=36B27D1956F8244990F8CDF12FB875F4&& set mc_patt_02=36B27D1956F8244990F8CDF12FB875F5
for /f "tokens=1" %%a in ('%uf% header count %mc_patt%') do set gmc_count=%%a

:findextr
if %amd%==1 if %aa%==4 findhex 2D414D342031 bios.bin>nul && set aa=5

rem ASRock Flash secur remove
if %aa%==5 findhex 4153526F636B mfactur\body.bin>nul && for /f %%a in ('%uf% header list AD944D418D99D247BFCD4E882241DE32') do %ue% %%a -o asr_prot -m body -t 18>nul && set asr_guid=%%a
if exist asr_prot\body.bin findhex 00000000 asr_prot\body.bin>nul || rd /s /q asr_prot

for %%a in (aptio mfactur tmpr) do if exist %%a rd /s /q %%a

echo;
echo		[EFI  Drivers - Find and Extract]
if %amd%==0 set list=%wf%\_List_Extri.txt
if %amd%==1 set list=%wf%\_List_Extra.txt
set mGUID=0
for /f "eol=# tokens=1-4" %%a in (%list%  %wf%\_List_Extro.txt) do (
	for /f "tokens=1,2" %%e in ('%ufbl% %%d') do (
	set SubGUID=%%f
	if defined SubGUID	(
		%ue% %%f -o tmpr -m body -t 18>nul && echo %%a %%b SubGUID %%f && %renb% tmp\%%c_%%f>nul && %renb_1% tmp\%%c_%%f_1>nul
	) else (
		if %%e neq !mGUID! %ue% %%e -o tmpr -m body -t 10>nul && echo %%a %%b GUID %%e && %renb% tmp\%%c_%%e>nul && %renb_1% tmp\%%c_%%e_1>nul
		if %%e==!mGUID! echo %%a %%b GUID %%e
	)
	set mGUID=%%e
	%rdir%
))

set cfl=0
if exist tmp\gop_* for /f "tokens=*" %%a in ('dir tmp\gop* /b') do (
	if %amd%==1 for /f "tokens=6 delims=. " %%b in ('drvver tmp\%%a') do (
		if %%b==1 set agv1=1
		if %%b==2 set agv2=1
		if %%b==3 set agv3=1
	)
	if %amd%==0 for /f "tokens=6,8 delims=. " %%b in ('drvver tmp\%%a') do (
		if %%b==2 set snb=1
		if %%b==3 set ivb=1
		if %%b==5 set hsw=1
		if %%b==9 set skl=1&& if %%c GEQ 1082 set cfl=1&& if %%b==9 set cfl=1
		if %%b==17 set tgl=1
	)
)

if %amd%==1 goto next_prep

for /f "tokens=1" %%a in ('%uf% all count 00F82456425420') do set vbt_count=%%a && set vbt_sec=1
for /f "tokens=1" %%a in ('%uf% all count 00F8........2456425420') do set vbt_count=%%a && set vbt_sec=19

if %vbt_count%==0 goto next_prep
set vbt_patt=00F82456425420
if %vbt_sec%==19 set vbt_patt=F8........2456425420
for /f "tokens=1" %%a in ('%ufal% %vbt_patt%') do (
	%ue% %%a -o tmpr -m body -t %vbt_sec%>nul && if exist tmpr\body* %renb% tmp\vbt_%%a>nul && echo Intel GOP VBT GUID %%a
	%rdir%)
)

:next_prep
rem LAN PRO/1000

if exist tmp\lani_xx_* for /f "tokens=*" %%a in ('dir tmp\lani_xx_* /b') do (
	for /f "tokens=3" %%b in ('drvver tmp\%%a') do (
		if %%b==Gigabit ren tmp\%%a lani1Gb_*>nul
		if %%b==PRO1000 ren tmp\%%a lani1Gp_*>nul
		if %%b==PRO2500 ren tmp\%%a lani2Gp_*>nul
		if %%b==10Gigabit ren tmp\%%a laniXGb_*>nul
)) 

set vervb=0
echo;
echo 	[OROM  - Find and Extract]
rem Intel  VBIOS
if %amd%==0 for /f "tokens=1,2" %%a in ('%ufbl% 49424D20564741') do (
	if %%a==%pguid% (
		echo VBIOS in Padding
	) else (
		%ue% %%a -o tmpr -m file>nul && if exist tmpr\file* %renf% tmp\vbios_%%a>nul && echo VBIOS in GUID %%a
	)
	%rdir%
)
rem AMD VBIOS
if %amd%==1 for /f "tokens=1,2" %%a in ('%ufbl% 41544F4D42494F53424B2D41') do (
 	set SubGUID=%%b
	if defined SubGUID (
 		%ue% %%b -o tmpr -m body -t 18>nul && if exist tmpr\body* %renb% tmp\vbios_%%b>nul && echo VBIOS in SubGUID %%b
	) else (
		%ue% %%a -o tmpr -m body -t 19>nul && if exist tmpr\body* %renb% tmp\vbios_%%a>nul && echo VBIOS in GUID %%a
	)
	if %%a==%pguid% echo VBIOS in Padding
	%rdir%
)
rem OROM extr
for /f "tokens=1" %%a in ('%ufbl% 24506E500102') do (
	if %%a==%pguid% (
		echo OROM in Padding
	) else (
		if exist tmp\vbios_%%a move tmp\vbios_%%a tmp\orom_%%a>nul
rem extr_test
		rem if not exist tmp\orom_%%a %ue% %%a -o tmpr -m file>nul && %renf% tmp\orom_%%a>nul
		if not exist tmp\orom_%%a %ue% %%a -o tmpr -m body>nul && %renb% tmp\orom_%%a>nul && %renb_1% tmp\orom_%%a_1>nul
		echo OROM in GUID %%a
	)
	%rdir%
)
If %aa%==5 if exist tmp\vbios_%oeguid1% move tmp\vbios_%oeguid1% tmp\orom_%oeguid1%>nul
for %%a in (
	%oeguid1% 	%oeguid2%
	%csmguid1% %csmguid2%
	%csmguid3%
) do if exist tmp\orom_%%a* del /f /q tmp\orom_%%a* && set csmguid=%%a && if %aa%==5 goto set_extr

:set_extr
set csmx=call :csm_extr
%csmx% || set csmx=echo;
if not exist csmcore echo Dummy CSMCORE>csmcore
if %aa% NEQ 0 call :check_mmt

rem OROM Intel Lan
set bacl=0
for /f "eol=# tokens=1" %%f in (%sdlio%\obacl.txt) do (
	if %aa%==4 findhex 008680%%f00 csmcore>nul && set bacl=1
	if %aa%==5 findhex 504349528680%%f csmcore>nul && set bacl=1
)
set bage=0
for /f "eol=# tokens=1" %%f in (%sdlio%\obage.txt) do (
	if %aa%==4 findhex 008680%%f00 csmcore>nul && set bage=1
	if %aa%==5 findhex 504349528680%%f csmcore>nul && set bage=1
)
set baxe=0
set x550=0
for /f "eol=# tokens=1" %%f in (%sdlio%\obaxe.txt) do (
	if %aa%==4 findhex 008680%%f csmcore>nul && set baxe=1
	if %aa%==5 findhex 504349528680%%f csmcore>nul && set baxe=1
)

%uf% body count 4D617276656C6C2038385345363178782041646170746572>nul && set mrvl61=1
%uf% body count 4D617276656C6C2038385345393178782041646170746572>nul && set mrvl91=1
%uf% body count 4D617276656C6C2038385345393278782041646170746572>nul && set mrvl92=1
if %amd%==0 goto end_fae

rem AMD Xpert2
if exist tmp\raidxpt2_* set rxpt2=1
if %aa%==4 if %rxpt2%==1 (%ufbl% 5043495202109243>nul && set rxpt2=6) || (%ufbl% 5043495222100578>nul && set rxpt2=7)

rem END Find/Extract
:end_fae
pause

:mn1
%rdir%
cls
set fefi=
set forom=
set brend=Wrong
echo;
echo                       Main Menu
echo             [Current version in BIOS file]
echo 1 - Disk Controller
if %amd%== 0 	call :irstd
if %amd%== 1 	call :amdd
rem if %m1%==0 echo      Not found
if exist tmp\*nvme* echo      EFI NVMe Driver present

echo 2 - Video OnBoard
call :video_ver
call :othvideo_ver

echo 3 - Network
call :inlver
call :rtkver
call :lxver
call :bcmver
call :yukver

echo 4 - Other SATA Controller
call :mrvlver
call :asmver
call :jmbver

echo 5 - CPU MicroCode
echo      View/Extract/Search/Replace

if %aa% neq 0 echo S - AMI Setup IFR Extractor
if exist tmp\OROM_* echo O - Option ROM in other GUIDs
echo 0 - Exit

echo RS - Re-Scanning
if exist ubu_abt.mht echo A - About

:mnm
set sel=
set /p sel=Choice:
if not defined sel goto mnm
if %amd%==0 if %sel%==1 goto isata
if %amd%==1 if %sel%==1 goto asata
if %sel%==2 goto video
if %sel%==3 goto lan
if %mrvl%==1 if %sel%==4 goto osata
if %asmo%==1 if %sel%==4 goto osata
if %jmbo%==1 if %sel%==4 goto osata
if %sel%==5 goto cpu
if %aa% neq 0 if /I %sel%==s goto setup_ifr
if exist tmp\OROM_* if /I %sel%==o goto rg
if /I %sel%==rs goto mn
if exist ubu_abt.mht if /I %sel%==a (start ubu_abt.mht) && goto mn1

if %sel%==0 goto exit
goto mnm

:isata
set m11=0
set m1v=0
%rdir%
cls
echo,
echo 			Disk Controller
echo 	[Current version]
call :irstd
echo,
echo 	[Available version]
if %irst%==1 (
	if exist %sdir%\rst\RaidDriver.efi drvver %sdir%\rst\RaidDriver.efi && set m11=1
	if exist %sdir%\rst\RaidOrom.bin findver "     OROM Intel RST for SATA     - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 2 %sdir%\rst\RaidOrom.bin  && set m11=1
)
if %irste%==1 (
	if exist %sdir%\rste_vroc\RaidDriver.efi drvver %sdir%\rste_vroc\RaidDriver.efi && set m11=1
	if exist %sdir%\rste_vroc\sSataDriver.efi drvver %sdir%\rste_vroc\sSataDriver.efi && set m11=1
	if exist %sdir%\rste_vroc\SCUDriver.efi drvver %sdir%\rste_vroc\SCUDriver.efi && set m11=1
	if %vmd%==1 if exist %sdir%\rste_vroc\vmdvroc_1.efi drvver %sdir%\rste_vroc\vmdvroc_1.efi && set m1v=1
	if exist %sdir%\rste_vroc\RaidOrom.bin (findver "     OROM Intel VROC for SATA    - " 496E74656C285229205669727475616C2052414944206F6E20435055202D2053415441204F7074696F6E20524F4D 49 0A 12 2 %sdir%\rste_vroc\RaidOrom.bin || findver "     OROM Intel RSTe for SATA    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D2053415441204F7074696F6E20524F4D 65 0A 12 2 %sdir%\rste_vroc\RaidOrom.bin) && set m11=1
	if exist %sdir%\rste_vroc\sSataOrom.bin (findver "     OROM Intel VROC for sSATA   - " 496E74656C285229205669727475616C2052414944206F6E20435055202D207353415441204F7074696F6E20524F4D  50 0A 12 2 %sdir%\rste_vroc\sSATAOrom.bin || findver "     OROM Intel RSTe for sSATA   - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D207353415441204F7074696F6E20524F4D 66 0A 12 2 %sdir%\rste_vroc\sSATAOrom.bin) && set m11=1
	if exist %sdir%\rste_vroc\SCUOrom.bin findver "     OROM Intel RSTe for SCU     - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D20534355204F7074696F6E20524F4D 64 0A 12 2 %sdir%\rste_vroc\SCUOrom.bin && set m11=1
)
if defined intnvme drvver %sdir%\nvme\NVMeDriver.efi && set m11=
if %m11%==0 echo     There are no files to replace in %sdir% \RST(e) folders. && pause && goto mn1

set ec=
echo;
echo 1 - Replace
if %irst%==1 if %irste%==1 echo 2 - Replace only RST
if %irst%==1 if %irste%==1 echo 3 - Replace only RSTe/VROC
if %m1v%==1 echo V - Replace VROC with VMD
if defined intnvme echo N - Replace NVMe
if exist tmp\irst* echo S - Share files
echo 0 - Exit to Main Menu
:mnis
set /p ec=Choice:
if not defined ec goto mnis
if %ec%==1 echo; && goto prcs
if %ec%==2 echo; && goto prcs
if %ec%==3 echo; && goto prcse
if %m1v%==1 if /I %ec%==v echo; && goto :prcs_vmd
if defined intnvme if /I %ec%==n echo; && goto prcsn
if exist tmp\irst* if /I %ec%==s call :share_rst && goto isata
if %ec%==0 goto mn1
goto mnis

:prcs
if %irst%==0 goto prcse
set ename=Intel RST
set str_patt=49006E00740065006C00280052002900200052005300540020003.00
set fefi=%sdir%\rst\RaidDriver.efi
if exist %fefi% call :efi_replace %str_patt% irst

set brend=OROM Intel RST
set forom=%sdir%\rst\RaidOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 5043495286802228') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend%  SubGUID %%b{#}{\n}
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		call :orom_repl %%a pcir
))

if %irste%==0 goto sataend
if %ec%==2 goto sataend

:prcse
set ename=Intel RSTe/VROC
set str_patt=5.005.00..00..0020003.002E003.002E003.002E003.003.003.003.0020005300410054004100
set fefi=%sdir%\rste_vroc\RaidDriver.efi
if exist %fefi% call :efi_replace %str_patt% irste

set ename=Intel sSATA
set str_patt=5.005.00..00..0020003.002E003.002E003.002E003.003.003.003.00200073005300410054004100
set fefi=%sdir%\rste_vroc\ssatadriver.efi
if exist %fefi% call :efi_replace %str_patt% irste

set ename=Intel SCU
set str_patt=49006E00740065006C00200052005300540065002000..002E00..002E00..002E00..00..00..00..00200053004300
set fefi=%sdir%\rste_vroc\scudriver.efi
if exist %fefi% call :efi_replace %str_patt% irste

set brend=OROM SATA
set forom=%sdir%\rste_vroc\RaidOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 5043495286802628') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend%  SubGUID %%b{#}{\n}
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		call :orom_repl %%a pcir
))

set brend=OROM sSata
set forom=%sdir%\rste_vroc\sSataOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 5043495286802728') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
	cecho {0E}%brend%  SubGUID %%b{#}{\n}
	%ur% %%b 18 %forom% -o bios.bin
	) else (
		call :orom_repl %%a pcir
))

set brend=OROM SCU
set forom=%sdir%\rste_vroc\ScuOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 504349528680601D') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend%  SubGUID %%b{#}{\n}
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		call :orom_repl %%a pcir
))
goto sataend

:prcs_vmd
set ename=Intel VROC with VMD
set str_patt=560052004F00430020007700690074006800200056004D004400200054006500630068006E006F006C006F006700790020003.002E00
set fefi=%sdir%\rste_vroc\vmdvroc_1.efi
if exist %fefi% call :efi_replace %str_patt% vmd
set ename=VMDD
set str_patt=56006F006C0075006D00650020004D0061006E006100670065006D0065006E00740020004400650076006900630065002000440072006900760065007200
set fefi=%sdir%\rste_vroc\vmdvroc_2.efi
if exist %fefi% call :efi_replace %str_patt% vmdd
goto sataend

:prcsn
set ename=Intel NVMe
set str_patt=20004E0056004D006500200055004500460049002000440072006900760065007200
set fefi=%sdir%\nvmenvmeDriver.efi
call :efi_replace %str_patt% nvme

:sataend
%csmx%
echo;
if %irst%==1 if %irste%==1 	pause && goto isata
call :irstd
pause
goto mn1

:asata
%rdir%
cls
echo,
echo 			Disk Controller
echo 	[Current version]
call :amdd

echo,
echo 	[Available versions for replacement]
if %rxpt2%==6 (
	if exist tmp\raidxpt2_* findver "1 -  EFI AMD RAIDXpert2-Fxx      - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_6\RAID_f10.efi
	findver "2 -  OROM AMD RAIDXpert2-Fxx     - " 5243424E42474E 8 00 12 1 %sdar%\Xpert_6\RAID_F10.bin
)
if %rxpt2%==7 (
	if exist tmp\raidxpt2_* findver "1 -  EFI AMD RAIDXpert2-Fxx      - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_7\RAID_F10.efi
	findver "2 -  OROM AMD RAIDXpert2-Fxx     - " 5243424E42474E 8 00 12 1 %sdar%\Xpert_7\RAID_F10.bin
)
if exist tmp\raid_* (
	echo R - \
	drvver %sdar%\efi\RaidDriver.efi
	drvver %sdar%\efi\RaidUtility.efi
)
if %o43xx%==1 (
	echo O - \
	findver "     OROM AMD RAID MISC 4392     - " 9243021092436C -22 00 12 1 %sdar%\439x\4392r.bin
	findver "     OROM AMD RAID MISC 4393     - " 9343021093436C -22 00 12 1 %sdar%\439x\4393r.bin
)
if %o78xx%==1 (
	echo O - \
	findver "     OROM AMD RAID MISC 7802     - " 0278221002786C -22 00 12 1 %sdar%\780x\7802r.bin
	findver "     OROM AMD RAID MISC 7803     - " 0378221003786C -22 00 12 1 %sdar%\780x\7803r.bin
)
if defined oahci findver "A -  OROM AMD AHCI               - " 414D442041484349 22 00 10 1 %sdar%\780x\7801a.bin
if %rxpt2%==1 (
	findver "1 -  EFI AMD RAIDXpert2-Fxx      - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_9\RAIDXpert2_Fxx.efi
	findver "2 -  OROM AMD RAIDXpert2-Fxx     - " 5243424E42474E 8 00 12 1 %sdar%\Xpert_8\RAIDXpert2_7905.bin
)
if exist tmp\raidxpt2* echo S - Share files
echo 0 - Exit to Main Menu
echo;

:as1
set ec=
set /p ec=Choice:
if not defined ec goto as1
if %rxpt2% neq 0 if %ec%==1 goto samde
if %rxpt2% neq 0 if %ec%==2 goto samdo
rem if %rxpt2%==1 if %ec%==3 goto samde
if exist tmp\raid_* if /I %ec%==r goto araid
if %o78xx%==1 if /I %ec%==o goto araido
if %o43xx%==1 if /I %ec%==o goto araido
if defined oahci if /I %ec%==a goto aahci
if exist tmp\raidxpt2* if /I %ec%==s call :share_xpt2 && goto asata
if %ec%==0 goto mn1
goto as1

:samde
if %rxpt2%==1 goto samden
for /f "tokens=1,2" %%a in ('%ufbl% 0041004D0044002D0052004100490044002000440072006900760065007200') do (
	set subguid=%%b
	if not defined subguid (
		cecho {0E}EFI RAIDXpert2 GUID %%a{#}{\n}
		if exist tmp\raidxpt2_%%a findhex 632E00004000 tmp\raidxpt2_%%a>nul && %ur% %%a 10 %sdar%\Xpert_%rxpt2%\RAID_F10.efi -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\raidxpt2_%%a>nul && %rdir%
		if exist tmp\raidxpt2_%%a findhex 632E00006300 tmp\raidxpt2_%%a>nul && %ur% %%a 10 %sdar%\Xpert_%rxpt2%\RAID_F50.efi -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\raidxpt2_%%a>nul && %rdir%
	) else (
		cecho {0E}Oops! Please, send report and BIOS file{#{\n}
	)
	%rdir%
)
goto samdend

:samdo
if %rxpt2%==1 goto samdon
set brend=OROM RAIDXpert2

findhex 0022100388 csmcore>nul && set forom=%sdar%\Xpert_%rxpt2%\RAID_F10.bin && call :orom_repl %csmguid% label 1022 8803
findhex 0022100488 csmcore>nul && set forom=%sdar%\Xpert_%rxpt2%\RAID_F50.bin && call :orom_repl %csmguid% label 1022 8804

goto samdend

:araid
for /f "eol=# tokens=1-4" %%a in (%sdar%\efi\_List_driver.txt) do (
	for /f "tokens=1" %%e in ('%ufbl% %%d') do (
	cecho {0E}EFI %%b GUID %%e{#}{\n}
	%ur% %%e 10 %sdar%\efi\%%a -o bios.bin && %ue% %%e -o tmpr -m body -t 10>nul && %renb% tmp\%%c_%%e>nul && %rdir%
))
goto samdend

:araido
set brend=OROM RAID
if %o43xx%==1 if %asus%==0 (
	findhex 5043495202109243 csmcore>nul && set forom=%sdar%\439x\4392r.bin && call :orom_repl %csmguid% pcir && echo MISC 4392 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFC 19 %sdar%\439x\4392m.bin -o bios.bin -all
	findhex 5043495202109343 csmcore>nul && set forom=%sdar%\439x\4393r.bin && call :orom_repl %csmguid% pcir && echo MISC 4393 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFD 19 %sdar%\439x\4393m.bin -o bios.bin -all
)
if %o43xx%==1 if %asus%==1 (
	findhex 5043495202109243 csmcore>nul && set forom=%sdar%\439x\4392r.bin && call :orom_repl %csmguid% pcir && echo MISC 4392 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFD 19 %sdar%\439x\4392m.bin -o bios.bin -all
	findhex 5043495202109343 csmcore>nul && set forom=%sdar%\439x\4393r.bin && call :orom_repl %csmguid% pcir && echo MISC 4393 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFC 19 %sdar%\439x\4393m.bin -o bios.bin -all
)
if %o78xx%==1 (
	findhex 5043495222100278 csmcore>nul && set forom=%sdar%\780x\7802r.bin && call :orom_repl %csmguid% pcir && echo MISC 7802 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFC 19 %sdar%\780x\7802m.bin -o bios.bin -all
	findhex 5043495222100378 csmcore>nul && set forom=%sdar%\780x\7803r.bin && call :orom_repl %csmguid% pcir && echo MISC 7803 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFD 19 %sdar%\780x\7803m.bin -o bios.bin -all
)
goto araido_end

:aahci
set brend=OROM AHCI
findhex 5043495202109143 csmcore>nul && set forom=%sdar%\439x\4391a.bin && call :orom_repl %csmguid% pcir
findhex 5043495222100178 csmcore>nul && set forom=%sdar%\780x\7801a.bin && call :orom_repl %csmguid% pcir

:araido_end
%csmx%
echo;
call :amdd1
pause
goto asata

:samden
set ename=AMD RAIDXpert2
set str_patt=0041004D0044002D0052004100490044002000440072006900760065007200
if %ec%==1 set fefi=%sdar%\Xpert_9\RAIDXpert2_Fxx.efi
call :efi_replace %str_patt% raidxpt2
goto samdend

:samdon
set brend=OROM RAIDXpert2
for %%a in (0579 1679) do for /f "tokens=1,2" %%b in ('%ufbl% 504349522210%%a') do (
	set subguid=%%c
	if defined subguid (
		cecho {0E}%brend% SubGUID %%c{#}{\n}
		if %%a==0579 %ur% %%c 18 %sdar%\Xpert_8\RAIDXpert2_7905.bin -o bios.bin
		if %%a==1679 %ur% %%c 18 %sdar%\Xpert_8\RAIDXpert2_7916.bin -o bios.bin
	) else (
		echo Oops! Please, send report and BIOS file
))
	
:samdend
%csmx%
echo;
call :amdd
pause
goto asata

:video
%rdir%
cls
set fefi=
set m21=0
set m22=0
set m2f=0
set m2v=0
set m2u=0

set agop1=%sdag%\v1\AMDGopDriver.efi
set agop3=%sdag%\v3\AMDGopDriver.efi
set agop2=%sdag%\v2\AMDGopDriver.efi

set snbg=%sdig%\v2\IntelGopDriver.efi
set ivbg=%sdig%\v3\IntelGopDriver.efi
set hswg=%sdig%\v5\IntelGopDriver.efi
set sklg=%sdig%\v9\IntelGopDriver.efi
set cflg=%sdig%\v9_1\IntelGopDriver.efi
set tglg=%sdig%\v17\IntelGopDriver.efi

if %amd%==1 set goppat=000041004D004400200047004F0050002000..00..00..002000
if %amd%==0 set goppat=49006E00740065006C00280052002900200047004F0050002000440072006900760065007200000000
if exist %sdig%\Usr_GOP\IntelGopDriver.efi set ugop=%sdig%\Usr_GOP\IntelGopDriver.efi

echo,
echo 		Video OnBoard
echo 	[Current version]
call :video_ver

echo,
echo 	[Available version]
if %amd%==1 (
	if defined agv3 drvver %agop3% && set m21=1
	if defined agv2 drvver %agop2% && set m21=1
	if defined agv1 drvver %agop1% && set m21=1
	for /f "eol=# tokens=1,2,3,*" %%A in (%sdav%\_List_vbios.txt) do (
		if defined %%C findver %%D 41544F4D42494F53424B 18 00 22 1 %sdav%\%%B && set m22=1
))

if %amd%==0 (
	if defined ivb drvver %ivbg% && set m21=1
	if defined snb drvver %xnbg% && set m21=1
	if defined hsw (
		drvver %hswg% && set m21=1
		if %vbt_count%==1 if exist %sdigv%\vbthsw.bin drvver %sdigv%\vbthsw.bin && set m2v=1
	)
	if exist %sdiv%\vbiossib.dat if %vervb%==3 findver "     OROM VBIOS SNB|IVB          - " 2456425420534E 79 FF 4 1 %sdiv%\vbiossib.dat && set forom=%sdiv%\vbiossib.dat && set m22=1
		if exist %sdiv%\vbioshsw.dat if %vervb%==5 for /f "tokens=*" %%b in ('findver "" 24564254204841 79 FF 4 1 %sdiv%\vbioshsw.dat') do (
		if %%b LSS 2000 (echo      OROM VBIOS HSW-BDW          - %%b) else (echo      OROM VBIOS Haswell          - %%b)) && set forom=%sdiv%\vbioshsw.dat && set m22=1
	)
	
	if defined tgl drvver %tglg% && set m21=1
	if defined skl (
		if %cfl%==1	drvver %cflg% && set m21=1
		if %cfl%==0	drvver %sklg% && set m21=1
		if exist %sdigv%\vbtskl.bin drvver %sdigv%\vbtskl.bin && set m2v=1
	)
	if exist %sdiv%\vbiosskl.dat if %vervb%==9 (
		for /f "tokens=*" %%b in ('findver "" 2456425420534B 79 FF 4 1 %sdiv%\vbiosskl.dat') do (
			if %%b LSS 1034 echo      OROM VBIOS SkyLake          - %%b
			if %%b GEQ 1034 if %%b LEQ 1051 echo      OROM VBIOS SKL-KBL          - %%b
			if %%b GEQ 1052 if %%b LEQ 1053 echo      OROM VBIOS SKL-???          - %%b
			if %%b GEQ 1054 if %%b LEQ 1057 echo      OROM VBIOS SKL-CFL          - %%b
			if %%b GEQ 1058 echo      OROM VBIOS SKL-AML          - %%b
		) && set forom=%sdiv%\vbiosskl.dat && set m22=1
		for /f "tokens=*" %%b in ('findver "" 2456425420434F 79 FF 4 1 %sdiv%\vbiosskl.dat') do (
			if %%vb LSS 1020 (echo      OROM VBIOS CoffeeLake       - %%b) else (echo      OROM VBIOS CFL-CML          - %%b)
		) && set forom=%sdiv%\vbiosskl.dat && set m22=1
	)
	if defined skl  if %cfl%==0 cecho -\  Requires GOP VBT{0E} 228 or above{#} - Force{\n}&& drvver %cflg% && set m2f=1
  	if %gop%==1 if defined ugop echo -\  User GOP Driver file && drvver %ugop% && set m2u=1
)

if defined mga findver "     OROM VBIOS Matrox G200      - " 4D4154524F582F4D47412D 31 29 9 1 %sdmv%\mga_g200.bin

:is
set ec=
echo;
if %m21%==1 echo 1 - Replace GOP Driver
if %m2f%==1 echo F - Force Replace GOP Driver
if %m2u%==1 echo U - Replace GOP Driver - User file
if %m2v%==1 echo V - Replace GOP VBT
if %m22%==1 echo 2 - Replace OROM VBIOS
if exist tmp\gop* echo S - Share files
echo 0 - Exit to Main Menu
:mnv
set /p ec=Choice:
if not defined ec goto mnv
if %m21%==1 if %ec%==1 goto rpl_gop
if %m2f%==1 if /I %ec%==f goto rpl_gop_force
if %m2u%==1 if /I %ec%==u goto rpl_gop_force
if %m2v%==1 if /I %ec%==v goto rpl_gop_vbt
if %m22%==1 if %ec%==2 goto vbup
if exist tmp\gop* if /I %ec%==s call :share_video && goto video
if %ec%==0 goto mn1
goto mnv

:rpl_gop
set ename=GOP Driver
set t_guid=0
for /f "tokens=1,2" %%a in ('%ufbl% %goppat%') do (
	set m_guid=%%b
	set sct=18
	if not defined m_guid set m_guid=%%a&&set sct=10
	if exist tmp\gop_!m_guid! call :gop_prep !m_guid! !sct!
)
goto end_video

:gop_prep
if %t_guid%==%1 exit /b
set guid=GUID
if %2==18 set guid=SubGUID

if %amd%==1 (
	if defined agv3 findhex 5200650076002E0033002E00 tmp\gop_%1>nul && set fefi=%agop3% && goto gop_repl
	if defined agv2 findhex 5200650076002E0032002E00 tmp\gop_%1>nul && set fefi=%agop2% && goto gop_repl
	if defined agv1 findhex 5200650076002E0031002E00 tmp\gop_%1>nul && set fefi=%agop1% && goto gop_repl
)
if %amd%==0 (
	if defined tgl findhex 409A499A tmp\gop_%1>nul && set fefi=%tglg% && goto gop_repl

	if defined skl if %cfl%==1 findhex 21190219 tmp\gop_%1>nul && set fefi=%cflg% && goto gop_repl
	if defined skl if %cfl%==0 findhex 21190219 tmp\gop_%1>nul && set fefi=%sklg% && goto gop_repl
	
	if defined hsw findhex 02040604 tmp\gop_%1>nul && set fefi=%hswg% && goto gop_repl
	if defined ivb findhex 52016201 tmp\gop_%1>nul && set fefi=%ivbg% && goto gop_repl
	if defined snb findhex 02011201 tmp\gop_%1>nul && set fefi=%snbg% && goto gop_repl
)
echo Oops!
exit /b 1

:gop_repl
cecho {0E} %ename% %guid% %1{#}{\n}
%ur% %1 %2 %fefi% -o bios.bin -all && %ue% %1 -o tmpr -m body -t %2>nul && %renb% tmp\gop_%1>nul && %renb_1% tmp\gop_%1_1>nul
set t_guid=%1
%rdir%
exit /b 0

:rpl_gop_force
set ename=GOP Driver
if /I %ec%==f if %cfl%==0 set fefi=%cflg%
if /I %ec%==u set fefi=%ugop%
call :efi_replace %goppat% gop
goto end_video

:rpl_gop_vbt
set fefi=
if %vbt_count% neq 1 echo Found more files GOP VBT && goto end_video
if not exist %sdigv%\vbt*.bin goto end_video
if defined hsw if exist %sdigv%\vbthsw.bin set fefi=%sdigv%\vbthsw.bin
if defined cfl if exist %sdigv%\vbtskl.bin set fefi=%sdigv%\vbtskl.bin
if defined fefi for /f "tokens=1" %%a in ('%ufal% %vbt_patt%') do (
	cecho {0E}RAW GOP VBT GUID %%a{#}{\n}
	%ur% %%a %vbt_sec% %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t %vbt_sec%>nul && %renb% tmp\vbt_%%a>nul && %rdir%
)
goto end_video

:vbup
if %amd%==1 goto vbup1
set brend=OROM VBIOS
set count_vb=0
If %vervb%==3 for /f "tokens=1" %%a in ('findhex 5043495286800201 csmcore') do set count_vb=%%a
If %vervb%==5 for /f "tokens=1" %%a in ('findhex 5043495286800604 csmcore') do set count_vb=%%a
if !count_vb!==1 call :orom_repl %csmguid% pcir && if %asus%==1 if not defined tgl vbios2pad bios.bin %forom%

If %vervb%==9 for /f "tokens=1,2" %%a in ('%ufbl% 5043495286800604') do (
	set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		cecho {0E}Intel VBIOS SKL++{#}{\n}
	)
	if %asus%==1 if not defined tgl vbios2pad bios.bin %forom%
)
goto end_video

:vbup1
set brend=OROM VBIOS
for /f "eol=# tokens=1,2,3" %%A in (%sdav%\_List_vbios.txt) do (
	if defined %%C if %%B neq null for /f "tokens=1,2" %%d in ('%ufbl% %%A') do (
	set subguid=%%e
	if not defined subguid (
		cecho {0E}%brend% GUID %%d{#}{\n}
		if %%d neq %pguid% %ur% %%d 19 %sdav%\%%B -o bios.bin && %ue% %%d -o tmpr -m body -t 19>nul && %renb% tmp\vbios_%%d>nul
	) else (
		cecho {0E}%brend% SubGUID %%e{#}{\n}
		%ur% %%e 18 %sdav%\%%B -o bios.bin && %ue% %%e -o tmpr -m body -t 18>nul && if exist tmpr\body* %renb% tmp\vbios_%%e>nul
	)
	%rdir%
))

:end_video
echo;
%csmx%
call :video_ver
pause
goto video

:lan
%rdir%
cls
set ge2cl=0
echo,
echo 			Network
echo 	[Current version]
call :inlver
call :rtkver
call :lxver
call :bcmver
call :yukver

echo,
echo 	[Available version]
if %lani%==1 (
	echo  -\ for i82579/i217/i218/i219 chips
	if exist tmp\lani1G* drvver %sdlie%\Gigabit.efi
	findver "     OROM Intel Boot Agent CL    - " 496E74656C28522920426F6F74204167656E7420434C 24 00 7 1 %sdlio%\obacl.lom 
	echo  -\ for i210/i211/i350 chips
	if exist tmp\lani1G* drvver %sdlie%\PRO1000.efi
	findver "     OROM Intel Boot Agent GE    - " 496E74656C28522920426F6F74204167656E74204745 24 00 7 1 %sdlio%\obage.lom
	if %baxe%==1 echo  -\ for 10 Gigabit chips
	if exist tmp\laniXGb* drvver %sdlie%\10Gigabit.efi
	if %baxe%==1 findver "     OROM Intel Boot Agent XE    - " 496E74656C28522920426F6F74204167656E74205845 24 00 7 1 %sdlio%\obaxe.lom
)
echo;
if %lanrtk%==1 (
	if exist tmp\lanr* drvver %sdlr%\RtkUndiDxe.efi
	if %rtk2%==1 findver "     OROM Realtek 2.5 Gb PXE     - " 5265616C74656B20322E3520476967616269742045746865726E657420436F6E74726F6C6C6572205365726965732076 48 20 4 1 %sdlr%\25G\rtegpxe.lom
	if %rtk1%==1 findver "     OROM Realtek Boot Agent GE  - " 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C6572205365726965732076 43 20 4 1 %sdlr%\1G\rtegpxe.lom
	if %rvt2%==1 findver "     OROM Rivet Killer E3000     - " 4B696C6C657220453330303020322E3520476967616269742045746865726E657420436F6E74726F6C6C657220 46 20 4 1 %sdlr%\R25G\rtegpxe.lom
 	if %rvt1%==1 findver "     OROM Rivet Killer E2600     - " 4B696C6C657220453235303056322F453236303020476967616269742045746865726E657420436F6E74726F6C6C657220 50 20 4 1 %sdlr%\R1G\rtegpxe.lom

)
if %lanlx%==1 (
	drvver %sdllx%\LxUndi.efi
	findver "     OROM Lx Killer E2xxx        - " 504349452045746865726E657420436F6E74726F6C6C6572 26 28 8 1 %sdllx%\Lxpxe.lom
)
if %lanbcm%==1 (
	drvver %sdlb%\b57undix64.efi
	findver "     OROM Broadcom Boot Agent    - " 42726F6164636F6D20554E444920505845 23 00 7 1 %sdlb%\b57pxee.lom
)

if %lanyuk%==1 findver "     OROM Mrvl-Yukon Boot Agent  - " 59756B6F6E205058450020 12 20 9 2 %sdly%\yukonpxe.lom

echo,
if %lani%==1 echo 1 - Replace Intel
if %lanrtk%==1 echo 2 - Replace Realtek
if %lanlx%==1 echo 3 - Replace Lx Network Killer
if %lanbcm%==1 echo 4 - Replace Broadcom
if %lanyuk%==1 echo 5 - Replace Marvell-Yukon
if exist tmp\lan* echo S - Share files
echo 0 - Exit to Main Menu

:lm1
set ec=
set /p ec=Choice:
if not defined ec goto lm1
if %lani%==1 if %ec%==1 goto intl
if %lanrtk%==1 if %ec%==2 goto rtk
if %lanlx%==1 if %ec%==3 goto lxkil
if %lanbcm%==1 if %ec%==4 goto bcm
if %lanyuk%==1 if %ec%==5 goto ykn
if exist tmp\lan* if /I %ec%==s call :share_lan && goto lan
if %ec%==0 goto mn1
goto lm1

:intl
rem echo bacl %bacl% bage %bage%
if %bacl%==1 if %bage%==0 if not exist tmp\lani1Gb_* if exist tmp\lani1Gp_* goto lm2
goto intl_up
:lm2
echo;
echo LAN Chip Configuration for %biosname%
echo 1 - only 1 or 2 chips 82579/i217/i218 (Recommended)
echo 2 - only 1 or 2 chips i210/i211/i350
echo   \ or other possible combinations
echo 0 - Cancel
:lm3
set ec=
set /p ec=Choice:
if not defined ec goto lm3
if %ec%==1 ren tmp\lani1Gp_* lani1Gb_*>nul && set ge2cl=1 && set chp2=2 && goto intl_up
if %ec%==2 goto intl_up
if %ec%==0 goto lan
goto lm3

:intl_up
echo;
echo For compatibility of the DevID, 
echo it is possible to install up to versions 6.6.04 and/or 1.5.62
echo;

set fefi7=%sdlie%\Gigabit.efi
set mGUID=0
if %bage%==0 set fefi=%sdlie%\E6604x3.efi
if %bage%==1 set fefi=%sdlie%\PRO1000.efi
if exist tmp\lani1Gb* if exist tmp\lani1Gp* set fefi=%sdlie%\PRO1000.efi
if %bacl%==1 if %bage%==1 if not exist tmp\lani1gb* if exist tmp\lani1gp* set fefi=%sdlie%\E6604x3.efi && set chp2=1
if exist tmp\lani1g* for /f "tokens=1,2" %%a in ('%ufbl% 49006E00740065006C002800520029002000500052004F002F003100300030003000') do (
	set subguid=%%b
	if defined subguid (
		if exist tmp\lani1gb_%%b cecho {0E}EFI Intel Gigabit SubGUID %%b{#}{\n} && %ur% %%b 18  %fefi7% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lani1gb_%%b>nul && %rdir%
		%rdir%
		if exist tmp\lani1gp_%%b cecho {0E}EFI Intel PRO/1000 SubGUID %%b{#}{\n} && call :chk_82579 %%b  18
	) else (
		if %%a neq !mGUID! (
			if exist tmp\lani1gb_%%a cecho {0E}EFI Intel Gigabit GUID %%a{#}{\n} && %ur% %%a 10  %fefi7% -o bios.bin -all && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lani1gb_%%a>nul && %renb_1% tmp\lani1gb_%%a_1>nul
			%rdir%
			if exist tmp\lani1gp_%%a cecho {0E}EFI Intel PRO/1000 GUID %%a{#}{\n} && call :chk_82579 %%a 10
		)
	)
	set mGUID=%%a
	%rdir%
)
if %ge2cl%==1 goto i1

set brend=OROM Boot Agent CL
set forom=%sdlio%\OBACL.LOM
set sGUID=0
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E7420434C') do (
	if %aa% neq 4 set subguid=%%b
	set chp2=0
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		if %%b neq !sGUID! %ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdlio%\obacl.txt) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\bacl_%%b && %ur% %%b 18 tmp\bacl_%%b -o bios.bin -all
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdlio%\obacl.txt) do findhex 008680%%c !fcnt!>nul && setdevid %%d %forom% tmp\bacl_%%d && set forom=tmp\bacl_%%d && call :orom_repl %%a label
	)
	set sGUID=%%b
	%rdir%
)
set chp2=1
:i1
set brend=OROM Boot Agent GE
set sGUID=0
if %bage%==0 set forom=%sdlio%\o1562GE.lom && set list_ge=o1562GE.txt
if %bage%==1 set forom=%sdlio%\OBAGE.LOM && set list_ge=OBAGE.txt
if %chp2%==2 set forom=%sdlio%\OBACL.LOM && set list_ge=OBACL.txt
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E74204745') do (
	if %aa% neq 4 set subguid=%%b
	set /A chp2+=1
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		if %%b neq !sGUID! %ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdlio%\%list_ge%) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\bage_%%b && %ur% %%b 18 tmp\bage_%%b -o bios.bin -all
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdlio%\%list_ge%) do findhex 008680%%c !fcnt!>nul && setdevid %%d %forom% tmp\bage_%%d && set forom=tmp\bage_%%d && call call :orom_repl %%a label
	)
	set sGUID=%%b
	%rdir%
)
if %chp2%==2 if %bacl%==1 if %bage%==1 if not exist tmp\lani1gb* if exist tmp\lani1gp* goto i1

if not exist tmp\laniXGb* goto skip_efi_xe
set ename=Intel 10Gb
set str_patt=49006E00740065006C00280052002900200031003000470062004500200044007200690076006500720020002500
set fefi=%sdlie%\10Gigabit.efi
call :efi_replace %str_patt% laniXGb
:skip_efi_xe

if %baxe%==0 goto xe_end
set brend=OROM Boot Agent XE
set forom=%sdlio%\OBAXE.LOM
set sGUID=0
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E742058452076') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		if %%b neq !sGUID! %ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdlio%\obaxe.txt) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\baxe_%%b && %ur% %%b 18 tmp\baxe_%%b -o bios.bin -all
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdlio%\obaxe.txt) do findhex 008680%%c !fcnt!>nul && setdevid %%d %forom% tmp\baxe_%%d && set forom=tmp\baxe_%%d && call :orom_repl %%a label
	)
	set sGUID=%%b
	%rdir%
)

if %x550%==0 goto xe_end
set brend=OROM Boot Agent XE x550
set forom=%sdlio%\OBAXE_x550.LOM
set sGUID=0
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E742058452028') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		if %%b neq !sGUID! %ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdlio%\obaxe_x550.txt) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\baxe_%%b && %ur% %%b 18 tmp\baxe_%%b -o bios.bin
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdlio%\obaxe_x550.txt) do findhex 008680%%c !fcnt!re>nul && setdevid %%d %forom% tmp\baxe_%%d && set forom=tmp\baxe_%%d && call :orom_repl %%a label
	)
	set sGUID=%%b
	%rdir%
)
:xe_end
echo;
%csmx%
call :inlver
pause
goto lan

:rtk
set ename=Realtek
set str_patt=0000EC106881EC106881......0000000000EC10
set fefi=%sdlr%\RtkUndiDxe.efi
call :efi_replace %str_patt% lanr

set brend=OROM Realtek
set forom=%sdlr%\1G\rtegpxe.lom
if %rtk1%==1 for /f "tokens=1,2" %%a in ('%ufbl% 50434952EC106881') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend%  SubGUID %%b{#}{\n}
		%ur% %%b 18 %forom% -o bios.bin -all && call :extr_oth_orom %%a
	) else (
		call :orom_repl %%a pcir
))
rem rtk2.5
set forom=%sdlr%\25G\rtegpxe.lom
set sGUID=0
if %aa% neq 4 if %rtk2%==1 for /f "tokens=1,2" %%a in ('%ufbl% 50434952EC102581') do (
	set subguid=%%b
	if defined subguid (
		if %%b neq !sGUID! cecho {0E}%brend%  SubGUID %%b{#}{\n} && %ur% %%b 18 %forom% -o bios.bin -all && call :extr_oth_orom %%a
	) else (
		call :orom_repl %%a pcir
	)
	set sGUID=%%b
)
echo;
%csmx%
call :rtkver
pause
goto lan

:lxkil
set ename=Lx Killer
set str_patt=5C4C78556E64694478655C
set fefi=%sdllx%\LxUndi.efi
call :efi_replace %str_patt% lanlx

set brend=OROM Boot Agent Lx Killer
set forom=%sdllx%\Lxpxe.lom
for /f "tokens=1,2" %%a in ('%ufbl% 504349526919...01C') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdllx%\Lxpxe.txt) do findhex 504349526919%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\lx_%%b && %ur% %%b 18 tmp\lx_%%b -o bios.bin && call :extr_oth_orom %%a
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdllx%\Lxpxe.txt) do findhex 006919%%c !fcnt!>nul && setdevid %%d %forom% tmp\lx_%%d && set forom=tmp\lx_%%d && call :orom_repl %%a label

	)
	%rdir%
)
echo;
%csmx%
call :lxver
pause
goto lan

:bcm
set ename=Broadcom
set str_patt=0000420072006F006100640063006F006D0020004E006500740058007400720065006D006500200047006900670061006200690074002000450074006800650072006E00650074002000
set fefi=%sdlb%\b57undix64.efi
call :efi_replace %str_patt% lanb

set brend=OROM Boot Agent BCM
set forom=%sdlb%\b57pxee.lom
for /f "tokens=1,2" %%a in ('%ufbl% 42726F6164636F6D204E6574587472656D652045746865726E657420426F6F74204167656E74 ') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdlb%\b57pxee.txt) do findhex 50434952e414%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\bcm_%%b && %ur% %%b 18 tmp\bcm_%%b -o bios.bin && call :extr_oth_orom %%a
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdlb%\b57pxee.txt) do findhex 00e414%%c !fcnt!>nul && setdevid %%d %forom% tmp\bcm_%%d && set forom=tmp\bcm_%%d && call :orom_repl %%a label
	)
	%rdir%
)
echo;
%csmx%
call :bcmver
pause
goto lan

:ykn
set brend=OROM Boot Agent Marvell-Yukon
set forom=%sdly%\yukonpxe.lom
for /f "eol=# tokens=1,2" %%a in (%sdly%\yukonpxe.txt) do findhex 00AB11%%a csmcore>nul && setdevid %%b %forom% tmp\yuk_%%b && set forom=tmp\yuk_%%b && call :orom_repl %csmguid% label
echo;
%csmx%
call :yukver
pause
goto lan

:osata
%rdir%
cls
echo,
echo 		Other Disk Controller
echo 	[Current version]
call :mrvlver
call :asmver
call :jmbver

echo,
echo 	[Available version]
if exist tmp\mrvs* drvver %sdsm%\mrvlahci.efi
if exist tmp\mrvr* drvver %sdsm%\mrvlraid.efi
if %mrvl91%==1 (
	if defined mrvlar (
		findver "     OROM Marvell 88SE91xx       - " 504349524B1B -21 00 10 1 %sdsm%\mrvl91xxa.bin
		findver "     OROM Marvell 88SE91xx       - " 504349524B1B -21 00 10 1 %sdsm%\mrvl91xxr.bin
	)
	if defined mrvlrd findver "     OROM Marvell 88SE91xx       - " 004D565244004D56554900 -10 00 10 1 %sdsm%\mrvl91xxrd.bin
)
if %mrvl92%==1 findver "     OROM Marvell 88SE92xx       - " 504349524B1B -21 00 10 1 %sdsm%\mrvl92xx.bin
if %mrvl61%==1 findver "     OROM Marvell 88SE92xx       - " 50434952AB11 -21 00 10 1 %sdsm%\mrvl61xx.bin

if %asmo%==1 for /f %%a in ('dir %sdsa%\*.* /b') do findver "     OROM Asmedia 106X           - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 %sdsa%\%%a
if %jmbo%==1 (
	findver "     OROM JMicron JMB36x         - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_7.bin
	findver "     OROM JMicron JMB36x         - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_8.bin
)

set ec=
set mvv=
echo;
if %mrvl%==1 echo 1 - Replace Marvell
if %asmo%==1 echo 2 - Replace ASMedia
if %jmbo%==1 echo 3 - Replace JMicron
if exist tmp\mrv* echo S - Share files
echo 0 - Exit to Main Menu
:mno
set /p ec=Choice:
if not defined ec goto mno
if %mrvl%==1 if %ec%==1 goto marvs
if %asmo%==1 if %ec%==2 goto asm
if %jmbo%==1 if %ec%==3 goto jmb
if exist tmp\mrv* if /I %ec%==s call :share_mrvl && goto osata
if %ec%==0 goto mn1
goto mno

:marvs
set ename=Marvell AHCI
set str_patt=00004D0061007200760065006C006C00200053004300530049002000440072006900760065007200
set fefi=%sdsm%\mrvlahci.efi
call :efi_replace %str_patt% mrvs

set ename=Marvell RAID
set str_patt=00004D0061007200760065006C006C00200052004100490044002000440072006900760065007200
set fefi=%sdsm%\mrvlraid.efi
call :efi_replace %str_patt% mrvr

set brend=OROM Marvell
set forom=%sdsm%\Mrvl92xx.bin
if %mrvl92%==1 for /f "tokens=1,2" %%a in ('%ufbl% 504349524B1B..92') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl92xx.txt) do findhex 504349524B1B%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\%%d_%%b && %ur% %%b 18 tmp\%%d_%%b -o bios.bin
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl92xx.txt) do findhex 004B1B%%c !fcnt!>nul && setdevid %%d %forom% tmp\%%d && set forom=tmp\%%d && call :orom_repl %%a label
	)
	%rdir%
)

set forom=%sdsm%\Mrvl91xxrd.bin
if %mrvl91%==1 if defined mrvlrd for /f "tokens=1,2" %%a in ('%ufbl% 504349524B1B..91') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend% SubGUID %%b{#}{\n}
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl91xxrd.txt) do findhex 504349524B1B%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\%%d_%%b && %ur% %%b 18 tmp\%%d_%%b -o bios.bin
	) else (
		if exist tmp\orom_%%a (set fcnt=tmp\orom_%%a) else (set fcnt=csmcore)
		for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl91xxrd.txt) do findhex 004B1B%%c !fcnt!>nul && setdevid %%d %forom% tmp\%%d && set forom=tmp\%%d && call :orom_repl %%a label
	)
	%rdir%
)

rem ReqMMT
set forom=%sdsm%\Mrvl91xxa.bin
set forom1=%sdsm%\Mrvl91xxr.bin
if %mrvl91%==1 if defined mrvlar for /f "tokens=1,2" %%a in ('%ufbl% 504349524B1B..91') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo Oops! Please, send report and BIOS file
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl91xx.txt) do (
			findhex 004B1B%%c csmcore>nul && %mmt% /e /l tmp\%%d 1B4B %%d && if exist tmp\%%d findhex 23902890 tmp\%%d>nul && (setdevid %%d %forom% tmp\%%d && set did=%%d AHCI && set romf=tmp\%%d 1B4B %%d && call :romu) || (setdevid %%d %forom1% tmp\%%d && set did=%%d RAID && set romf=tmp\%%d 1B4B %%d && call :romu)
)))

rem Old Marvell 61xx
set forom=%sdsm%\Mrvl61xx.bin
findhex 50434952AB112161 csmcore>nul && call :orom_repl %csmguid% pcir
set forom=%sdsm%\Mrvl61xxr.bin
findhex 50434952AB114561 csmcore>nul && call :orom_repl %csmguid% pcir

%csmx%
echo;
call :mrvlver
pause
goto osata

:asm
set ec=
echo;
set /A asmch=0
for /f %%a in ('dir %sdsa%\*.* /b') do set /A asmch+=1 && findver "!asmch! -  OROM Asmedia 106X           - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 %sdsa%\%%a
echo 0 - Cancel
:asm1
set /p ec=Choice:
if not defined ec goto asm1
if %ec%==1 set forom=%sdsa%\ASM106x.0951 && goto asms
if %ec%==2 set forom=%sdsa%\ASM106x.097 && goto asms
if %ec%==3 set forom=%sdsa%\ASM106x.427 && goto asms
if %ec%==0 goto osata
goto asm1
:asms
set brend=OROM ASM106x
for /f "tokens=1,2" %%a in ('%ufbl% 50434952211b1206') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		cecho {0E}%brend%  SubGUID %%b{#}{\n}
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		call :orom_repl %%a pcir
))
echo;
%csmx%
call :asmver
pause
goto osata

:jmb
set ec=
echo;
findver "1 -  OROM JMicron JMB36x         - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_7.bin
findver "2 -  OROM JMicron JMB36x         - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_8.bin
echo 0 - Cancel
:jmb1
set /p ec=Choice:
if not defined ec goto jmb1
if %ec%==1 set jmb362=%sdsj%\jmb362_7.bin && set jmb363=%sdsj%\jmb363_7.bin && goto jmbs
if %ec%==2 set jmb362=%sdsj%\jmb362_8.bin && set jmb363=%sdsj%\jmb363_8.bin && goto jmbs
if %ec%==0 goto osata
goto jmb1
:jmbs
set brend=OROM JMicron 362/363
findhex 504349527b196223 csmcore>nul && set forom=%jmb362% && call :orom_repl %csmguid% pcir
findhex 504349527b196323 csmcore>nul && set forom=%jmb363% && call :orom_repl %csmguid% pcir
echo;
%csmx%
call :jmbver
pause
goto osata

:cpu
%rdir%
cls
%mceb% -ubu -skip -exit 
set mce_count=%errorlevel%
if %mce_count%==9009 cecho {0E}{\n}{\t}Need Python 3.7 or higher{\n} && pause && goto mn1
if %mce_count% LEQ 0 cecho {0E}{\n}{\t}Microcodes not found or MCE old version{#}{\n} && pause && goto mn1

copy /y %wf%\Z_MCU.txt tmp\Z_MCU.txt>nul

set ec=
set mc1=
set mc2=
set mpdt=
set str=
set /A count_try=0

if defined mc_guid (
	echo 	These microcodes are in your BIOS file 
	cecho	 	{0E}GUID %mc_guid%{#}{\n}
	echo;
	echo 	[Intel CPU MicroCode]
	echo F - Find and Replace from MCUpdate.txt
	echo V - View/Edit MCUpdate.txt
	if not exist %sdim%\Usr_mCode.txt if exist %sdim%\USR_mCode\*.bin echo G - Generate user list
	if exist %sdim%\Usr_mCode.txt if exist %sdim%\USR_mCode\*.bin (
		echo U - Find and Replace from USR_mCode.txt
		echo E - View/Edit USR_mCode.txt
))
if %amd%==1 (
	If %mmtool%==0 if %aa%==4 cecho {\n}{\t}{0E}Need MMTool v5.0.0.7 as mmtool_a4.exe.{#}{\n} && goto mce_mrnu
	echo;
	echo 	[AMD CPU MicroCode]
	echo F - Find and Replace MicroCode
)
:mce_mrnu
echo;
echo 	[MC Extractor]
echo X - Extract all CPU microcodes
echo S - Search for available microcode in DB.
echo 0 - Exit to Main Menu

:mnmc
set /p ec=Choice:
if not defined ec goto mnmc
if %amd%==0 if defined mc_guid (
	if /I %ec%==f goto createffs
	if /I %ec%==v %sdim%\MCUpdate.txt
rem  if not exist %sdim%\Usr_mCode.txt if exist %sdim%\USR_mCode\*.bin if %ec%==g call :
	if exist %sdim%\Usr_mCode.txt if exist %sdim%\USR_mCode\*.bin (
		if /I %ec%==u goto createffs
		if /I %ec%==e %sdim%\Usr_mCode.txt
))
if %amd%==1 (
	if %aa%==4 if %mmtool%==1 if /I %ec%==f goto cpua
	if %aa%==5 if /I %ec%==f goto cpua
)
if /I %ec%==x echo Extracting... && %mceb% -skip>nul && goto cpu
if /I %ec%==s goto sdb
if %ec%==0 %tit% && goto mn1
goto mnmc

:sdb
set /p str=Enter CPUID, example 000306C3 :^>
if not defined str goto cpu
%mce% -search  %str%
goto cpu

:createffs
 set mc_list=%sdim%\MCUpdate.txt
if /I %ec%==u set mc_list=%sdim%\Usr_mCode.txt
for /f "eol=# tokens=1,2" %%a in (%mc_list%) do mcodefit -cpuid bios.bin %%a && set mc1=%sdim%\%%b && echo %%a %%b>>tmp\Z_MCU.txt && call :varmc
if not defined mc2 echo Nothing found && pause && goto cpu
goto umc

:varmc
set mc1=%mc1%
echo %mc1%
mcodefit -mc_check %mc1% || pause && goto cpu
set mc2=%mc2% -i %mc1%
if %mc_pad%==1 mcodefit -0x800 %mc1%>nul || set mc2=%mc2% -i %wf%\Z_PAD.bin
exit /b

:umc
echo Generate FFS with Microcode
findhex 4D5044540001000010000000000010 bios.bin>nul && set mpdt=-i %wf%\MPDT_BOOT_YES.bin
findhex 4D5044540000000010000000000010  bios.bin>nul && set mpdt=-i %wf%\MPDT_BOOT_NO.bin

set mc_cs=1
%uf% all count %mc_patt%..AA01........F801000000>nul && set mc_cs=0
if %mc_cs%==0 (
	%wf%\GenFFS -t EFI_FV_FILETYPE_RAW -g %mc_guid% %mc2% %mpdt% -o tmp\mCode.ffs
) else (
	%wf%\GenFFS -s -t EFI_FV_FILETYPE_RAW -g %mc_guid% %mc2% %mpdt% -o tmp\mCode.ffs
)
set modcpu=tmp\mCode.ffs
echo;
%mce% tmp\mCode.ffs -skip -ubu -exit
echo 	These microcodes will be entered into your BIOS file

If %aa% neq 0 if %mmtool%==0 if %gmc_count% geq 2 (
	cecho {\n}{\t}{0E}Need MMTool.{#}{\n}
	if %aa%==4 cecho {0E}mmtool_a4.exe v5.0.0.7{#}{\n}
	if %aa%==5 cecho {0E}mmtool_a4.exe v5.0.0.7 and mmtool_a5.exe v5.2.0.2x{#}{\n}
) && pause && goto cpu
set ec=
echo;
echo R - Start replacement
if %aa%==5 if %mmtool%==1 if %gmc_count%==1 echo A - Start replacement Alternative with MMTool
if %aa%==5 if %mmtool%==1 if %gmc_count%==2 (
	echo.
	echo 	[For any x299 Series]
	echo P - Replacement in PEI volume - Recommended
	echo D - Inserting into a DXE volume - Test
)
echo 0 - Cancel
:mnmcu
set /p ec=Choice:
if not defined ec goto mnmcu
if /I %ec%==r goto cpus
if %aa%==5 if %mmtool%==1 if %gmc_count% LEQ 2 (
	if /I %ec%==a goto msi_x299
	if /I %ec%==d goto msi_x299
	if /I %ec%==p goto msi_x299
)
if %ec%==0 goto cpu
goto mnmcu

:cpus
set /A count_try+=1
echo 	[Preparing for replacement]
copy /y bios.bin tmp\bios.bak>nul && cecho {0B}BIOS file backup{#}{\n}
if %gmc_count%==1 goto one_repl
for /f "tokens=1" %%m in ('%uf% header list %mc_patt%') do (
	%ue% %%m -o tmpr -m file>nul && 	findhex 00F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF tmpr\file.ffs>nul
	if not errorlevel 1 (
		copy /y tmpr\file.ffs tmp\mCode_pad.ffs>nul
		<nul set /p TmpStr=Dummy GUID: 
 		mcodefit -mc_guid_repl01 bios.bin || mcodefit -mc_guid_repl01 tmpr\file.ffs>nul && %ur% %%m 1 tmpr\file.ffs -o bios.bin -asis || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
	) else (
		<nul set /p TmpStr=mCode GUID: 
		mcodefit -mc_guid_repl02 bios.bin || mcodefit -mc_guid_repl02 tmpr\file.ffs>nul && set rplguid=%%m && set rplfile=tmpr\file.ffs && call :upd_mcffs || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
	)
	%rdir%
)

echo 	[Replacement]
for /f "tokens=1" %%m in ('%uf% header list %mc_patt_02%') do (
	<nul set /p TmpStr=mCode FFS: 
	set rplguid=%%m && set rplfile=%modcpu% && call :upd_mcffs || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && goto rs_mmt
)

for /f "tokens=1" %%m in ('%uf% header list %mc_patt_01%') do 	(
	<nul set /p TmpStr=Dummy FFS: 
	mcodefit -mc_guid_rest01 bios.bin || %ur% %%m 1 tmp\mCode_pad.ffs -o bios.bin -asis || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
)
goto Func_FIT_

:one_repl
echo 	[Replacement]
<nul set /p TmpStr=mCode FFS: 
%ur% %mc_guid% 1 %modcpu% -o bios.bin -asis || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
goto Func_FIT_

:msi_x299
call :mcu_msi_x299 || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu

rem %mceb% -skip -ubu -exit
:Func_FIT_
if %fit%==1 (
	mcodefit -fit_check bios.bin || mcodefit -fit_restore bios.bin>nul
	mcodefit -fit_fixed bios.bin && mcodefit -fit_backup bios.bin>nul
)
pause
goto cpu

:cpua
set acpu_loc1=
set acpu_loc2=
echo 	[Preparing for replacement]
copy /y bios.bin tmp\bios.bak>nul && cecho {0B}BIOS file backup{#}{\n}

set acpu_patho=%sdam%\old
set acpu_path4=%sdam%\am4

rem 1 set acpu_pattp=FFFFFFFF..20............0.80.00............000.....0.......0....0.
rem 2 set acpu_pattf=000000..20............0.80.00............000.....0.......0....0.AA
set acpu_pattp=FFFFFFFF1.20............0.80.00............000.....000..........0.000000
set acpu_pattf=1.20............0.80.00............000.....000..........0.000000

for /f "tokens=1" %%a in ('%ufbl% %acpu_pattp%') do set acpu_loc1=%%a
for /f "tokens=1" %%a in ('%ufbl% %acpu_pattf%') do set acpu_loc2=%%a
rem  && echo %%a>_mc_guid.txt

set /A mc_rpl_count=0
if defined acpu_loc1 cecho {0E}Found in Padding{#}{\n} && goto acpu_repl_start
if defined acpu_loc2 cecho {0E}Found in GUID %acpu_loc2%{#}{\n}

:acpu_repl_start
echo 	[Replacement]
if defined acpu_loc1 (
	for /f %%d in ('dir %acpu_path4% /b') do mcodefit -amd bios.bin  %acpu_path4%\%%d && set /A mc_rpl_count+=1
) && goto cpua_end

if %aa%==5 goto cpua_end

if defined acpu_loc2 (
	set rplguid=%acpu_loc2%
	set rplfile=tmpr\file.ffs
	%ue% %acpu_loc2% -o tmpr -m file>nul
	for /f %%d in ('dir %acpu_patho% /b') do mcodefit -amd tmpr\file.ffs %acpu_patho%\%%d && set /A mc_rpl_count+=1
	mcodefit -ffs_fixed_cs tmpr\file.ffs
	call :upd_mcffs || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
	%rdir%
)
echo;
if %mce_count% NEQ %mc_rpl_count% cecho {0C} !!! Mismatch !!!{#}{\n} && move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
:cpua_end
cecho MCE found {0E}%mce_count%{#} mCodes - Processed {0E}%mc_rpl_count%{#} mCodes{\n}
pause
goto cpu

:upd_mcffs
%mmt% /r %rplguid% %rplfile%
if %errorlevel% neq 0 (cecho {0C}MMTool Error!{#}{\n} && exit /b 1) else (echo %ok%)
exit /b 0

:mcu_msi_x299
if %gmc_count% gtr 2 echo Cancel! Is there something wrong! && pause && goto cpu
echo 	[Preparing for replacement]
copy /y bios.bin tmp\bios.bak>nul && cecho {0B}BIOS file backup{#}{\n}
if %gmc_count%==1 goto one_mmt_repl
%ue% %mc_guid% -o tmpr -m file>nul
copy /y tmpr\file.ffs tmp\mcode_pad.ffs>nul
<nul set /p TmpStr=Dummy GUID: 
mcodefit -mc_guid_repl01 bios.bin || mcodefit -mc_guid_repl01 tmpr\file.ffs>nul && %ur% %mc_guid% 1 tmpr\file.ffs -o bios.bin -asis

:one_mmt_repl
echo 	[Replacement]
<nul set /p TmpStr=Delete old mCode - 
for /f "eol=# tokens=1,2" %%a in (tmp\Z_MCU.txt) do (
	set _mc=%mmt% /d /p 1
	call :mc_up_one || exit /b 1
	<nul set /p TmpStr=%%a 
)
if /I %ec%==p goto m2up
if /I %ec%==a goto m2up
echo;
<nul set /p TmpStr=mCode FFS: 
%ur% 17088572-377F-44EF-8F4E-B09FFF46A071 1 tmp\mcode.ffs -o bios.bin -asis
%rdir%
exit /b 0
:m2up
echo;
if %gmc_count%==2 start /wait tmp\Z_MCU.txt
<nul set /p TmpStr=Insert new mCode - 
for /f "eol=# tokens=1,2" %%a in (tmp\Z_MCU.txt) do (
	set _mc=%mmt% /i /p %sdim%\%%b
	call :mc_up_one || exit /b 1
	<nul set /p TmpStr=%%a 
)
%rdir%
if %gmc_count%==1 exit /b 0
echo;
<nul set /p TmpStr=Dummy FFS: 
mcodefit -mc_guid_rest01 bios.bin || %ur% 17088572-377F-44EF-8F4E-B09FFF46A071 1 tmp\mcode_pad.ffs -o bios.bin -asis
exit /b 0

:mc_up_one
%_mc%
if %errorlevel% neq 0 exit /b 1
exit /b 0

:csm_extr
%rdir%
rem echo %csmguid%
if defined csmguid %ue% %csmguid% -o tmpr -m body>nul && move tmpr\*.* tmp\csm>nul && echo CSM>csmcore
if exist tmp\orom_* (for /f %%r in ('dir tmp\orom_* /b') do copy /b csmcore+tmp\%%r csmcore>nul)
if %amd%==0 if exist tmp\vbios_* (for /f %%v in ('dir tmp\vbios_* /b') do copy /b csmcore+tmp\%%v csmcore>nul)
if %aa%==0 exit /b 1
if exist tmp\csm\*.bin (for /f %%r in ('dir tmp\csm\*.bin /b') do copy /b csmcore+tmp\csm\%%r csmcore>nul) && %rdir% && exit /b 0
%rdir%
exit /b 1

:setup_ifr
if not exist ifrextract.exe cecho {0B}IFR Extractor not found{#}{\n} && pause && goto mn1
cls
if exist "_Setup_%biosname%" rd /s /q "_Setup_%biosname%"
echo;
echo 	[AMI Setup IFR Extractor]
echo;
echo Find AMI Setup
for /f "tokens=1,2" %%a in ('%ufbl% 530079007300740065006D0020004C0061006E0067007500610067006500') do (
	set subguid=%%b
	if defined subguid (
		cecho {0B}AMI Setup in GUID %%a{#}{\n}
		cecho {0B}          SubGUID %%b{#}{\n}
		%ue% %%a -o _Setup_%biosname% -m body -t 18>nul
	) else (
		cecho {0B}AMI Setup in GUID %%a{#}{\n}
		%ue% %%a -o _Setup_%biosname% -m body -t 10>nul
))
if exist _Setup_%biosname%\body.bin ifrextract _Setup_%biosname%\body.bin _Setup_%biosname%\setup_extr.txt && echo Done!
if exist _Setup_%biosname%\setup_extr.txt findver "BIOS Lock VarOffset  - " 42494F53204C6F636B 45 2C 6 2 _Setup_%biosname%\setup_extr.txt && findver "BIOS Lock VarOffset  - " 42494F53204C6F636B 45 2C 6 2 _Setup_%biosname%\setup_extr.txt>_Setup_%biosname%\BIOSLock_str.txt
pause
goto mn1

:rg
echo;
echo 	Option ROM in other GUIDs
echo;
if exist _OROM_in_GUIDs.txt del /f /q _OROM_in_FFS.txt
for /f %%f in ('dir tmp\orom_* /b') do (
	echo - %%f && echo - %%f>>_OROM_in_GUIDs.txt
)
echo;
pause
goto mn1

:romu
echo %brend% DevID %did%
if not exist mmtool_a4.exe cecho {0E}File not replaced.{#{\n} && cecho {0E}Need MMTool v5.0.0.7 as mmtool_a4.exe.{#}{\n} && exit /b 1
%mmt% /r /l %romf%
if %errorlevel% neq 0 (cecho {0C}MMTool Error!{#}{\n} && exit /b 1) else (echo %ok%)
exit /b 0

:chk_82579
set refi=%fefi%
findhex 380032003500370039004C004D00 tmp\lani1Gp_%1>nul || set refi=%sdlie%\PRO1000.efi
rem :efi_repl
if defined %3 set refi=%3
%ur% %1 %2  %refi% -o bios.bin -all && %ue% %1 -o tmpr -m body -t %2>nul && %renb% tmp\lani1gp_%1>nul && %renb_1% tmp\lani1gp_%1_1>nul				
%rdir%
exit /b 0

:efi_replace
set t_guid=0
for /f "tokens=1,2" %%a in ('%ufbl% %1') do (
	set guid=SubGUID
	set t_sct=18
	set m_guid=%%b
	if not defined m_guid set m_guid=%%a&& set t_sct=10 && set guid=GUID
	if !m_guid! neq !t_guid! cecho {0E} %ename% !guid! !m_guid!{#}{\n}
	if !m_guid! neq !t_guid! %ur% !m_guid! !t_sct! %fefi% -o bios.bin -all && %ue% !m_guid! -o tmpr -m body -t !t_sct!>nul && %renb% tmp\%2_!m_guid!>nul && %renb_1% tmp\%2_!m_guid!_1>nul
	set t_guid=!m_guid!
	%rdir%
)
exit /b

:orom_repl
set repl_ok=0
cecho {0E}OROM in GUID %1{#}{\n}
if %1 neq %csmguid1% if %1 neq %csmguid2% if %1 neq %csmguid3% cecho {0E}GUID not supported.{#}{\n}  && goto orom_repl_exit

rem Split 32 to 16+16?
rem split -f bios.bin -s 16M

%ue% %1 -o tmpr -m body -t 19>nul || cecho {0E}Unknown section.{#}{\n} && goto orom_repl_exit

if exist tmpr\body.bin oromreplace tmpr\body.bin %forom% %2 %3 %4 || goto orom_repl_exit
%ur% %1 19  tmpr\body.bin -o bios.bin && %rdir% && set repl_ok=1&& if %aa% neq 4 %ue% %1 -o tmpr -m body -t 19>nul && %renb% tmp\orom_%1>nul && %renb_1% tmp\orom_%1_1>nul

:orom_repl_exit
%rdir%
if %repl_ok%==1 exit /b 0
exit /b 1

:extr_oth_orom
%rdir%
if exist tmp\orom_%1 %ue% %1 -o tmpr -m body>nul && %renb% tmp\orom_%1>nul && %renb_1% tmp\orom_%1_1>nul
%rdir%
exit /b

:err
cecho {0D}!!! File BIOS not found !!!{#}{\n}
pause
exit

:exit
rem if defined isda bios.bin %isda%
if %fit%==1 mcodefit -fit_check bios.bin || mcodefit -fit_restore bios.bin
set ec=
echo;
if %asus%==1 echo 1 - Rename to ASUS USB BIOS Flashback
if %asus%==0 echo 1 - Rename to mod_%biosname%
if exist asr_prot\body.bin echo 2 - Remove Instant Flash Protection (Not work for AMD 400+/ Intel 300+ chipsers)
echo 0 - As Is BIOS.BIN
echo;
:ubf
set /p ec=Rename? :
if not defined ec goto ubf
if %ec%==1 if %asus%==1 goto ren_ubf
if %ec%==1 if %asus%==0 (
	ren bios.bin mod_%biosname%
	echo bios.bin ===^> mod_%biosname%
	goto exit1
)
if exist asr_prot\body.bin if %ec%==2 goto asr_prot_del

if %ec%==0 goto exit1
goto ubf

:asr_prot_del
if exist asr_prot\body.bin for %%s in (asr_prot\body.bin) do (
	if %%~zs==2048 %ur% %asr_guid% 18 %wf%\asrx99.pad -o bios.bin -all
	if %%~zs==4096 %ur% %asr_guid% 18 %wf%\asrx100.pad -o bios.bin -all
)
ren bios.bin apr_%biosname% && echo bios.bin ===^> apr_%biosname%
rd /s /q asr_prot>nul
goto exit1

:ren_ubf
if exist bios.bin.dump for /f %%u in ('findver "" 24424F4F5445464924 145 00 12 1 bios.bin') do (
if exist bios.bin.dump (
	echo Restore Capsule Header
	copy /b /y bios.bin.dump\header.bin+bios.bin %%u>nul
	echo bios.bin ===^> %%u
	del bios.bin
) else (
	ren bios.bin %%u && echo bios.bin ===^> %%u
))
if exist bios.bin ren bios.bin mod_%biosname% && echo bios.bin ===^> mod_%biosname%

:exit1
echo;
echo *******************************************
echo * Many thanks for the use of the project. *              *
echo *******************************************

%rdir%
if exist bios.bin.dump rd /s /q bios.bin.dump
if exist tmp rd /s /q tmp
if exist fit.dump del /f /q fit.dump
if exist csmcore del /f /q csmcor*
if exist asr_prot rd /s /q asr_prot
pause
EXIT

REM display version
:video_ver
if exist tmp\gop_* for /f "tokens=*" %%b in ('dir tmp\gop_* /b') do drvver tmp\%%b && set gop=1
if exist tmp\vbt_* for /f "tokens=*" %%b in ('dir tmp\vbt_* /b') do drvver tmp\%%b
if %amd%==1 goto amd_video
findver "     OROM VBIOS SandyBridge      - " 24564254205341 79 FF 4 2 csmcore && set vervb=3
findver "     OROM VBIOS SNB-IVB          - " 2456425420534E 79 FF 4 2 csmcore && set vervb=3 && exit /b
for /f "tokens=*" %%b in ('findver "" 24564254204841 79 FF 4 2 csmcore') do (
	if %%b LSS 2000 (echo      OROM VBIOS HSW-BDW          - %%b) else (echo      OROM VBIOS Haswell          - %%b)) && set vervb=5 && exit /b
for /f "tokens=*" %%b in ('findver "" 2456425420534B 79 FF 4 2 csmcore') do (
	if %%b LSS 1034 echo      OROM VBIOS SkyLake          - %%b && set vervb=9
	if %%b GEQ 1034 if %%b LEQ 1051 echo      OROM VBIOS SKL-KBL          - %%b && set vervb=9
	if %%b GEQ 1052 if %%b LEQ 1053 echo      OROM VBIOS SKL-???          - %%b && set vervb=9
	if %%b GEQ 1054 if %%b LEQ 1057 echo      OROM VBIOS SKL-CFL          - %%b && set vervb=9
	if %%b GEQ 1058 echo      OROM VBIOS SKL-AML          - %%b && set vervb=9
)
for /f "tokens=*" %%b in ('findver "" 2456425420434F 79 FF 4 2 csmcore') do (
	if %%vb LSS 1020 (echo      OROM VBIOS CoffeeLake       - %%b) else (echo      OROM VBIOS CFL-CML          - %%b)) && set vervb=9 && exit /b
findver "     OROM VBIOS IceLake          - " 24564254204943 79 FF 4 2 csmcore && set vervb=14 && exit /b
findver "     OROM VBIOS CherryView       - " 24564254204348 79 FF 4 2 csmcore && exit /b
findver "     OROM VBIOS ValleyView       - " 24564254205641 79 FF 4 2 csmcore && exit /b
findver "     OROM VBIOS ApolloLake       - " 24564254204252 79 FF 4 2 csmcore
findver "     OROM VBIOS GeminiLake       - " 24564254204745 79 FF 4 2 csmcore
findver "     OROM VBIOS Ironlake         - " 24564254204952 79 FF 4 2 csmcore
findver "     OROM VBIOS Eaglelake        - " 24564254204541 79 FF 4 2 csmcore
exit /b

:amd_video
if exist tmp\vbios_* for /f "tokens=1" %%b in ('dir tmp\vbios_* /b') do (
	set fva=0
	for /f "eol=# tokens=1,2,3,*" %%A in (%sdav%\_List_vbios.txt) do (
	findhex %%A tmp\%%b>nul && findver %%D 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set %%C=1 && set fva=1
	)
	if !fva!==0 findver "     OROM VBIOS Unknown          - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b
)
if not exist tmp\vbios_* findver "     OROM AMD VBIOS              - " 41544F4D42494F53424B 18 00 22 2 csmcore
exit /b

:othvideo_ver
if exist tmp\othgop_* for /f "tokens=*" %%b in ('dir tmp\othgop_* /b') do drvver tmp\%%b
if exist tmp\othmgagop_* echo "     EFI Matrox GOP Driver"
findver "     OROM VBIOS ASPEED           - " 004153542047505500 9 00 7 2 csmcore
findver "     OROM VBIOS Matrox           - " 4D4154524F582F4D47412D 31 29 9 2 csmcore && set mga=1
exit /b

:irstd
if exist tmp\irst_* for /f "tokens=*" %%b in ('dir tmp\irst_* /b') do drvver tmp\%%b && set m1=1 && set irst=1
findver "     OROM IMSM RAID for SATA     - " 496E74656C285229204D61747269782053746F72616765204D616E61676572206F7074696F6E20524F4D 44 20 12 2 csmcore && set m1=1 && set irst=1
findver "     OROM Intel RST for SATA     - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 2 csmcore && set m1=1 && set irst=1
if exist tmp\irste_* for /f "tokens=*" %%b in ('dir tmp\irste_* /b') do drvver tmp\%%b && set m1=1 && set irste=1
if exist tmp\vmd_* for /f "tokens=*" %%b in ('dir tmp\vmd_* /b') do drvver tmp\%%b && set m1=1 && set vmd=1
if exist tmp\vmdd_* set vmdd=1
findver "     OROM Intel RSTe for SATA    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D2053415441204F7074696F6E20524F4D 65 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM Intel VROC for SATA    - " 496E74656C285229205669727475616C2052414944206F6E20435055202D2053415441204F7074696F6E20524F4D 49 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM Intel RSTe for sSATA   - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D207353415441204F7074696F6E20524F4D 66 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM Intel VROC for sSATA   - " 496E74656C285229205669727475616C2052414944206F6E20435055202D207353415441204F7074696F6E20524F4D  50 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM Intel RSTe for SCU     - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D20534355204F7074696F6E20524F4D 64 0A 12 2 csmcore && set m1=1 && set irste=1
if exist tmp\invme_* for /f "tokens=*" %%b in ('dir tmp\invme_* /b') do drvver tmp\%%b && set intnvme=1
exit /b

:amdd
if exist tmp\raidxpt2_* for /f "tokens=*" %%a in ('dir tmp\raidxpt2_* /b') do drvver tmp\%%a
findver "     OROM AMD RAIDXpert2-Fxx     - " 5243424E42474E 8 00 12 2 csmcore
if exist tmp\raid_* for /f "tokens=*" %%a in ('dir tmp\raid_* /b') do drvver tmp\%%a
:amdd1
findver "     OROM AMD RAID MISC 4392     - " 9243021092436C -22 00 12 1 csmcore && set o43xx=1
findver "     OROM AMD RAID MISC 4393     - " 9343021093436C -22 00 12 1 csmcore && set o43xx=1
findver "     OROM AMD RAID MISC 7802     - " 0278221002786C -22 00 12 1 csmcore && set o78xx=1
findver "     OROM AMD RAID MISC 7803     - " 0378221003786C -22 00 12 1 csmcore && set o78xx=1
findver "     OROM AMD AHCI               - " 414D442041484349 22 00 10 1 csmcore && set oahci=1
exit /b

:mrvlver
if exist tmp\mrv* for /f "tokens=*" %%b in ('dir tmp\mrv* /b') do drvver tmp\%%b && set mrvl=1
if %mrvl91%==1 for /f "eol=# tokens=1,2" %%a in (%sdsm%\Mrvl91xx.txt) do (
	findhex 004B1B%%a csmcore>nul && findver "     OROM Marvell 88SE%%b       - " 004B1B%%a 16 00 10 1 csmcore && set mrvl=1 && set mrvlar=1
)
if %mrvl91%==1 for /f "eol=# tokens=1,2" %%a in (%sdsm%\Mrvl91xxrd.txt) do (
	findhex 004B1B%%a csmcore>nul && findver "     OROM Marvell 88SE%%b       - " 004D565244004D56554900 -10 00 10 1 csmcore && set mrvl=1 && set mrvlrd=1
)
if %mrvl92%==1 for /f "eol=# tokens=1,2" %%a in (%sdsm%\Mrvl92xx.txt) do (
	findhex 004B1B%%a csmcore>nul && findver "     OROM Marvell 88SE%%b       - " 004B1B%%a 16 00 10 1 csmcore && set mrvl=1
)

findver "     OROM Marvell 88SE61xx       - " 50434952AB112161 -22 00 10 1 csmcore && set mrvl=1
exit /b

:asmver
findver "     OROM Asmedia 106X           - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 csmcore  && set asmo=1
exit /b

:jmbver
findver "     OROM JMicron JMB36x         - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 csmcore && set jmbo=1
exit /b

:inlver
if exist tmp\lani* for /f "tokens=*" %%b in ('dir tmp\lani* /b') do drvver tmp\%%b && set lani=1
rem findver "     OROM Intel Boot Agent FE    - " 496E74656C28522920426F6F74204167656E74204645 24 00 7 2 csmcore && set lanir=0
findver "     OROM Intel Boot Agent CL    - " 496E74656C28522920426F6F74204167656E7420434C 24 00 7 2 csmcore && set lani=1
findver "     OROM Intel Boot Agent GE    - " 496E74656C28522920426F6F74204167656E74204745 24 00 7 2 csmcore && set lani=1
findver "     OROM Intel Boot Agent XE    - " 496E74656C28522920426F6F74204167656E742058452076 24 00 7 2 csmcore && set lani=1
findver "     OROM Intel Boot Agent x550  - " 496E74656C28522920426F6F74204167656E742058452028 31 00 7 2 csmcore && set lani=1 && set x550=1
findver "     OROM Intel Boot Agent XG    - " 496E74656C28522920426F6F74204167656E74205847 24 00 7 2 csmcore
findver "     OROM Intel Boot Agent 40G   - " 496E74656C28522920426F6F74204167656E74203430 24 00 7 2 csmcore
findver "     OROM Intel Boot Agent ICE   - " 496E74656C28522920426F6F74204167656E7420494345 24 00 7 2 csmcore
rem findver "     OROM Intel iSCSI Boot       - " 496E74656C2852292069534353492052656D6F746520426F6F74 35 00 7 1 csmcore
exit /b

:rtkver
if exist tmp\lanr* for /f "tokens=*" %%b in ('dir tmp\lanr* /b') do drvver tmp\%%b && set lanrtk=1&& set rvt=1
if exist tmp\lanr* if not defined rvt echo      EFI Realtek UNDI Driver   - Unknown
(findver "     OROM Realtek 2.5 Gb PXE     - " 5265616C74656B20322E3520476967616269742045746865726E657420436F6E74726F6C6C6572205365726965732076 48 20 4 2 csmcore || findver "     OROM Realtek 2.5 Gb PXE     - " 5265616C74656B205043496520322E354742452046616D696C7920436F6E74726F6C6C6572205365726965732076 46 20 5 2 csmcore) && set lanrtk=1 && set rtk2=1
findver "     OROM Realtek Boot Agent GE  - " 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C6572205365726965732076 43 20 4 2 csmcore && set lanrtk=1 && set rtk1=1
findver "     OROM Rivet Killer E3000     - " 4B696C6C657220453330303020322E3520476967616269742045746865726E657420436F6E74726F6C6C657220 46 20 4 2 csmcore && set lanrtk=1 && set rvt2=1
findver "     OROM Rivet Killer E2600     - " 4B696C6C657220453235303056322F453236303020476967616269742045746865726E657420436F6E74726F6C6C657220 50 20 4 2 csmcore && set lanrtk=1 && set rvt1=1
rem findver "     OROM Realtek Boot Agent FE  - " 5265616C74656B20504349652046452046616D696C7920436F6E74726F6C6C657220536572696573 42 20 4 1 csmcore
exit /b

:lxver
if exist tmp\lanlx* for /f "tokens=*" %%b in ('dir tmp\lanlx* /b') do drvver tmp\%%b && set lanlx=1
findver "     OROM Lx Killer E2xxx        - " 504349452045746865726E657420436F6E74726F6C6C6572 26 28 8 2 csmcore && set lanlx=1
exit /b

:bcmver
if exist tmp\lanb* for /f "tokens=*" %%b in ('dir tmp\lanb* /b') do drvver tmp\%%b && set lanbcm=1
findver "     OROM Broadcom Boot Agent    - " 42726F6164636F6D20554E444920505845 23 00 7 2 csmcore && set lanbcm=1
exit /b

:yukver
findver "     OROM Mrvl-Yukon Boot Agent  - " 59756B6F6E205058450020 12 20 9 2 csmcore && set lanyuk=1
exit /b

:rs_mmt
if %aa%==4 pause && goto cpu
if exist mmtool_a4.exe (
	cecho {0B}Re-Select MMTool... {#}
rem 	findhex  35002E00300030002E003000300030003700 mmtool_a4.exe>nul || cecho {0E}MMRool v5.0.0.7 not present{#}{\n} && pause && goto cpu
	set mmt=start /b /min /wait mmtool_a4 bios.bin
	if %count_try%==1 cecho {0B}Try again.{#}{\n}{\n} && goto cpus
)
cecho {0E}Unsuccessful. Try other methods.{#}{\n} && pause && goto cpu

:check_mmt
if %aa%==4 if exist mmtool_a4.exe set mmt=start /b /min /wait mmtool_a4 bios.bin && set mmtool=1 && exit /b 0
if %aa%==5 if exist mmtool_a5.exe set mmt=start /b /min /wait mmtool_a5 bios.bin && set mmtool=1 && exit /b 0

if exist mmtool.exe (
	if %aa%==4 if not exist mmtool_a4.exe findhex 35002E00300030002E003000300030003700 mmtool.exe>nul && move /y mmtool.exe mmtool_a4.exe>nul && goto check_mmt
	if %aa%==5 if not exist mmtool_a5.exe findhex 35002E00300032002E0030003000 mmtool.exe>nul && move /y mmtool.exe mmtool_a5.exe>nul && goto check_mmt
)
set mmt=rem 
if %aa%==5 (
	if %amd%==0 if %gmc_count%==1 exit /b 0
	if %amd%==1 exit /b 0
)
exit /b 1

:share_video
set gop_name=AMDGopDriver.efi
if %amd%==0 set gop_name=IntelGopDriver.efi
for /f "tokens=*" %%a in ('dir tmp\gop* /b') do (
	for /f "tokens=6" %%b in ('drvver tmp\%%a') do (
		if not exist Extracted\GOP\%%b md Extracted\GOP\%%b
		copy /y tmp\%%a Extracted\GOP\%%b\%gop_name%
))

if %amd%==1 if exist tmp\vbios_* for /f "tokens=1" %%b in ('dir tmp\vbios_* /b') do (
	for /f "eol=# tokens=1,2" %%A in (%sdav%\_List_vbios.txt) do (
	for /f %%v in ('findver "" 41544F4D42494F53424B 18 00 22 1 tmp\%%b') do (
		if not exist Extracted\VBIOS\%%v md Extracted\VBIOS\%%v
		findhex %%A tmp\%%b>nul && copy /y tmp\%%b Extracted\VBIOS\%%v\%%B
)))

if %amd%==0 for /f "tokens=*" %%a in ('dir tmp\vbt* /b') do (
	for /f "tokens=4, 6" %%b in ('drvver tmp\%%a') do (
	if not exist "Extracted\GOP\VBT\%%b\%%c" md "Extracted\GOP\VBT\%%b\%%c"
	copy /y tmp\%%a "Extracted\GOP\VBT\%%b\%%c\vbt.bin"
))
pause && exit /b 0

:share_rst
for /f "tokens=*" %%a in ('dir tmp\irst* /b') do (
	for /f "tokens=3,5,7" %%b in ('drvver tmp\%%a') do (
		if not exist Extracted\%%b\%%d md Extracted\%%b\%%d
		if /I %%c==SATA set nm_drv=RaidDriver.efi
		if /I %%c==sSATA set nm_drv=sSataDriver.efi
		if /I %%c==SCU set  nm_drv=SCUDriver.efi		
		copy /y /b tmp\%%a Extracted\%%b\%%d\!nm_drv!
))
for /f "tokens=*" %%a in ('dir tmp\vmd_* /b') do (
	for /f "tokens=3,7" %%b in ('drvver tmp\%%a') do (
		if not exist Extracted\%%b\%%c md Extracted\%%b\%%c
		copy /y /b tmp\%%a Extracted\%%b\%%c\vmdvroc_1.efi
		if exist tmp\vmdd* copy /y /b tmp\vmdd* Extracted\%%b\%%c\vmdvroc_2.efi>nul
))
if %aa%==4 pause && exit /b 0

rem orom rst
if not exist tmp\csm\*.bin pause && exit /b 0
for /f %%a in ('dir tmp\csm\*.bin /b') do (
	for /f %%b in ('findver "" 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 1 tmp\csm\%%a') do (
		if not exist Extracted\RST\%%b md Extracted\RST\%%b
		copy /y /b tmp\csm\%%a Extracted\RST\%%b\RaidOrom.bin
	)
	for /f %%b in ('findver "" 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D2053415441204F7074696F6E20524F4D 65 0A 12 1 tmp/csm\%%a') do (
		if not exist Extracted\RSTe_vroc\%%b md Extracted\RSTe_vroc\%%b
		copy /y /b tmp\csm\%%a Extracted\RSTe_vroc\%%b\RaidOrom.bin
	)
	for /f %%b in ('findver "" 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D207353415441204F7074696F6E20524F4D 66 0A 12 1 tmp\csm\%%a') do (
		if not exist Extracted\RSTe_vroc\%%b md Extracted\RSTe_vroc\%%b
		copy /y /b tmp\csm\%%a Extracted\RSTe_vroc\%%b\sSataOrom.bin
	)
	for /f %%b in ('findver "" 496E74656C285229205669727475616C2052414944206F6E20435055202D2053415441204F7074696F6E20524F4D 49 0A 12 1 tmp\csm\%%a') do (
	if not exist Extracted\VROC\%%b md Extracted\VROC\%%b
		copy /y /b tmp\csm\%%a Extracted\VROC\%%b\RaidOrom.bin
	)
	for /f %%b in ('findver "" 496E74656C285229205669727475616C2052414944206F6E20435055202D207353415441204F7074696F6E20524F4D  50 0A 12 1 tmp\csm\%%a') do (
		if not exist Extracted\VROC\%%b md Extracted\VROC\%%b
		copy /y /b tmp\csm\%%a Extracted\VROC\%%b\sSataOrom.bin
	)
	for /f %%b in ('findver "" 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D20534355204F7074696F6E20524F4D 64 0A 12 1 tmp\csm\%%a') do (
		if not exist Extracted\RSTe_vroc\%%b md Extracted\RSTe_vroc\%%b
		copy /y /b tmp\csm\%%a Extracted\RSTe_vroc\%%b\SCUOrom.bin
))
pause && exit /b 0

:share_xpt2
for /f "tokens=*" %%a in ('dir tmp\raidxpt2* /b') do (
	for /f "tokens=5" %%b in ('drvver tmp\%%a') do (
		if not exist Extracted\RAID\%%b md Extracted\RAID\%%b
		copy /y /b tmp\%%a Extracted\RAID\%%b\RAIDXpert2_Fxx.efi
))
if %aa%==4 pause && exit /b 0

rem orom xpt2
if not exist tmp\csm\*.bin pause && exit /b 0
set aid=
for /f %%a in ('dir tmp\csm\*.bin /b') do (
	for /f "tokens=1" %%b in ('findver "" 5243424E42474E 8 00 12 1 tmp\csm\%%a') do (
		if not exist Extracted\RAID\%%b md Extracted\RAID\%%b
		findhex 5043495222100579 tmp\csm\%%a>nul && set aid=7905
		findhex 5043495222101679 tmp\csm\%%a>nul && set aid=7916
		if not defined aid set aid=Unknown
		copy /y /b tmp\csm\%%a Extracted\RAID\%%b\RAIDXpert2_!aid!.bin
))
pause && exit /b 0

:share_mrvl
for /f "tokens=*" %%a in ('dir tmp\mrv* /b') do (
	for /f "tokens=2,4,6" %%b in ('drvver tmp\%%a') do (
		if not exist Extracted\%%b\%%d md Extracted\%%b\%%d
		if %%c==AHCI set nm_drv=mrvlahci.efi
		if %%c==RAID set nm_drv=mrvlraid.efi
		copy /y /b tmp\%%a Extracted\%%b\%%d\!nm_drv!
))
rem (rom 92xx ???)
pause && exit /b 0

:share_lan
for /f "tokens=*" %%a in ('dir tmp\lan* /b') do (
	for /f "tokens=2,3,6" %%b in ('drvver tmp\%%a') do (
		if not exist Extracted\LAN\%%b\%%d md Extracted\LAN\%%b\%%d
		if %%b==Realtek set nm_drv=RtkUndi.efi
		if %%b==Lx set nm_drv=LxUndi.efi
		if %%b==Broadcom set nm_drv=b57Undi.efi
		if %%b==Intel set nm_drv=%%c.efi
		copy /y /b tmp\%%a Extracted\LAN\%%b\%%d\!nm_drv!
))
if %aa%==4 pause && exit /b 0

rem orom lan
if not exist tmp\csm\*.bin pause && exit /b 0
for /f %%a in ('dir tmp\csm\*.bin /b') do (
	for /f "tokens=1" %%b in ('findver "" 496E74656C28522920426F6F74204167656E7420434C 24 00 7 1 tmp\csm\%%a') do (
		if not exist Extracted\LAN\Intel\%%b md Extracted\LAN\Intel\%%b
		setdevid 0000 tmp\csm\%%a Extracted\LAN\Intel\%%b\BACL.lom Extracted\LAN\Intel\%%b\BACL.txt
	)
	for /f "tokens=1" %%b in ('findver "" 496E74656C28522920426F6F74204167656E74204745 24 00 7 1 tmp\csm\%%a') do (
		if not exist Extracted\LAN\Intel\%%b md Extracted\LAN\Intel\%%b
		setdevid 0000 tmp\csm\%%a Extracted\LAN\Intel\%%b\BAGE.lom Extracted\LAN\Intel\%%b\BAGE.txt
	)
	for /f "tokens=1" %%b in ('findver "" 496E74656C28522920426F6F74204167656E74205045 24 00 7 1 tmp\csm\%%a') do (
		if not exist Extracted\LAN\Intel\%%b md Extracted\LAN\Intel\%%b
		setdevid 0000 tmp\csm\%%a Extracted\LAN\Intel\%%b\BAXE.lom Extracted\LAN\Intel\%%b\BAXE.txt
	)
	for /f "tokens=1" %%b in ('findver "" 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C6572205365726965732076 43 20 4 1 tmp\csm\%%a') do (
		if not exist Extracted\LAN\Realtek\1G\%%b md Extracted\LAN\\Realtek\1G\%%b
		copy /y /b tmp\csm\%%a Extracted\LAN\\Realtek\1G\%%b\rtegpxe.lom
	)
	for /f "tokens=1" %%b in ('findver "" 5265616C74656B20322E3520476967616269742045746865726E657420436F6E74726F6C6C6572205365726965732076 48 20 4 1 tmp\csm\%%a') do (
		if not exist Extracted\LAN\Realtek\25G\%%b md Extracted\LAN\\Realtek\25G\%%b
		copy /y /b tmp\csm\%%a Extracted\LAN\\Realtek\25G\%%bb\rtegpxe.lom
	)
	rem (Broacm ???)
)
pause
exit /b 0

:EOF
