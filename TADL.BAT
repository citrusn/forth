@echo off
tasm /z /zi /n %1, %1, %1
if errorlevel 1 goto err
tlink /x /v %1, %1
del %1.obj
goto end
:err
echo Ошибка трансляции 
goto fin
:end
echo Конец сеанса 
:fin

