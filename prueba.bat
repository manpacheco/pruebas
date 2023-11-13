@echo off

cd "C:\Users\Manuel\Desktop\pruebas ASM\pruebas"
del prueba.tap /Q
cd src
del public.txt /Q
"C:\Prog_SSD\Pasmo_054b2\pasmo.exe" --name prueba --tapbas prueba.asm ..\prueba.tap --public
echo Renombrando
REN --public public.txt
cd ..
"f:\Manuel\Spectrum\spin\zxspin.exe" "c:\Users\Manuel\Desktop\prueba~1\pruebas\prueba.tap"


