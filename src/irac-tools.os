#Использовать irac
#Использовать cli
#Использовать moskito
#Использовать "."

Перем Лог;
Перем ВыводДополнительнойИнформации;
Перем ВременныйКаталогРаботы;

///////////////////////////////////////////////////////////////////////////////

Процедура ВыполнитьПриложение()

	Приложение = Новый КонсольноеПриложение(ПараметрыПриложения.ИмяПриложения(),
											"инструменты администрирования кластера серверов");
	Приложение.Версия("version", ПараметрыПриложения.Версия());

	Приложение.ДобавитьКоманду("description d", "Выводит описание кластера 1С",
	                           Новый ОписаниеКластера());
	Приложение.ДобавитьКоманду("session s", "Выводит список сеансов кластера 1С",
							   Новый ОписаниеСеансов());
	Приложение.ДобавитьКоманду("connection с", "Выводит список соединений кластера 1С",
							   Новый ОписаниеСоединений());
	Приложение.Опция("R ras",
					 "localhost:1545",
					 "адрес сервиса RAS")
	          .ТСтрока()
	          .Обязательный(Ложь)
		      .ВОкружении("IRAC_RAS_LOCATION");
		   
	Приложение.Опция("C cluster", "localhost:1541", "адрес кластера в виде <сервер>:<порт>")
	          .ТСтрока()
	          .Обязательный(Ложь)
		      .ВОкружении("IRAC_CLUSTER");
	Приложение.Опция("U cluster-user", "", "имя пользователя кластера")
	          .ТСтрока()
	          .Обязательный(Ложь)
		      .ВОкружении("IRAC_CLUSTER_USER");
	Приложение.Опция("P cluster-pwd", "", "пароль пользователя кластера")
	          .ТСтрока()
	          .Обязательный(Ложь)
		      .ВОкружении("IRAC_CLUSTER_PWD");
		   
	Приложение.Опция("v verbose", Ложь, "вывод отладочной информации в процессе выполнения")
			  .Флаговый();
    Приложение.Опция("t test", Ложь, "использовать тестовые данные для работы")
			  .Флаговый();
	
	Приложение.Запустить(АргументыКоманднойСтроки);
						
КонецПроцедуры // ВыполнитьПриложение()

///////////////////////////////////////////////////////

Лог = ПараметрыПриложения.Лог();

Попытка

	ВыполнитьПриложение();

Исключение

	Лог.КритичнаяОшибка(ОписаниеОшибки());
	ВременныеФайлы.Удалить();

	ЗавершитьРаботу(1);

КонецПопытки;
