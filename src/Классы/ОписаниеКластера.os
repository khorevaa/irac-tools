// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac-tools/
// ----------------------------------------------------------

Перем Лог;

#Область СлужебныйПрограммныйИнтерфейс

// Функция - возвращает объект управления логированием
//
// Возвращаемое значение:
//  Объект      - объект управления логированием
//
Функция Лог() Экспорт
	
	Возврат Лог;

КонецФункции // Лог()

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("PATH",
					 "",
					 "путь к файлу вывода информации о кластере (если не указан выводится в консоль)")
	       .ТСтрока()
	       .Обязательный(Ложь);

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	Лог = ПараметрыПриложения.Лог();

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");
	СервисАдминистрирования   = Команда.ЗначениеОпции("ras");
	Кластер                   = Команда.ЗначениеОпции("cluster");
	ИмяПользователяКластер    = Команда.ЗначениеОпции("cluster-user");
	ПарольПользователяКластер = Команда.ЗначениеОпции("cluster-pwd");

	ПараметрыОбработки        = Команда.ЗначениеАргумента("PATH");

	ПараметрыПриложения.УстановитьРежимОтладкиПриНеобходимости(ВыводОтладочнойИнформации);
						
	ОписаниеАгента = СтрРазделить(СервисАдминистрирования, ":");

	АдресСервиса = "localhost";
	ПортСервиса = "1545";
	Если ОписаниеАгента.Количество() > 0 Тогда
		АдресСервиса = ОписаниеАгента[0];
	КонецЕсли;
	Если ОписаниеАгента.Количество() > 1 Тогда
		ПортСервиса = ОписаниеАгента[1];
	КонецЕсли;

	АдминистрированиеКластера = Новый АдминистрированиеКластера(АдресСервиса, ПортСервиса, "8.3");
	Если ВыводОтладочнойИнформации Тогда
		АдминистрированиеКластера.Лог().УстановитьУровень(УровниЛога.Отладка);
	КонецЕсли;

	ОписаниеКластера = ПолучитьОписаниеКластера(АдминистрированиеКластера);

	ВывестиДанные(ОписаниеКластера);

КонецПроцедуры // ВыполнитьКоманду()

#Область ОбработкаКоманды

Функция ПолучитьОписаниеКластера(АдминистрированиеКластера)

	ОписаниеКластера = Новый Соответствие();

	ОписаниеКластера.Вставить("СервисАдминистрирования",
	                          ПолучитьПоляОбъекта(АдминистрированиеКластера));

	ОписаниеКластера.Вставить("Администраторы", ПолучитьСписокАдминистраторов(АдминистрированиеКластера));

	ОписаниеКластера.Вставить("Кластеры", Новый Массив());
	
	Кластеры = АдминистрированиеКластера.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		ОписаниеКластера["Кластеры"].Добавить(ПолучитьПоляОбъекта(ТекКластер));

		ТекОписаниеКластера = ОписаниеКластера["Кластеры"][ОписаниеКластера["Кластеры"].ВГраница()];
	
		ТекОписаниеКластера.Вставить("Администраторы", ПолучитьСписокАдминистраторов(АдминистрированиеКластера));

		ТекОписаниеКластера.Вставить("Серверы", Новый Массив());

		Серверы = ТекКластер.Серверы().Список();
		Для Каждого ТекСервер Из Серверы Цикл
			ПоляОбъекта = ПолучитьПоляОбъекта(ТекСервер);
			ПоляОбъекта.Вставить("НазначенияФункциональности",
			                     ПолучитьСписокОбъектов(ТекСервер.НазначенияФункциональности().Список()));
			ТекОписаниеКластера["Серверы"].Добавить(ПоляОбъекта);
		КонецЦикла;

		ТекОписаниеКластера.Вставить("Менеджеры",
		                             ПолучитьСписокОбъектов(ТекКластер.Менеджеры().Список()));

		ТекОписаниеКластера.Вставить("Сервисы",
									 ПолучитьСписокОбъектов(ТекКластер.Сервисы().Список(),
									                        ТекКластер.Сервисы().ПараметрыОбъекта()));

		ТекОписаниеКластера.Вставить("РабочиеПроцессы",
		                             ПолучитьСписокОбъектов(ТекКластер.РабочиеПроцессы().Список()));
		ТекОписаниеКластера.Вставить("ИнформационныеБазы",
		                             ПолучитьСписокОбъектов(ТекКластер.ИнформационныеБазы().Список()));
		ТекОписаниеКластера.Вставить("Соединения",
		                             ПолучитьСписокОбъектов(ТекКластер.Соединения().Список()));
		ТекОписаниеКластера.Вставить("Сеансы",
		                             ПолучитьСписокОбъектов(ТекКластер.Сеансы().Список()));

		ТекОписаниеКластера.Вставить("Блокировки",
									 ПолучитьСписокОбъектов(ТекКластер.Блокировки().Список(),
									                        ТекКластер.Блокировки().ПараметрыОбъекта()));

		ТекОписаниеКластера.Вставить("ПрофилиБезопасности", Новый Массив());

		ПрофилиБезопасности = ТекКластер.ПрофилиБезопасности().Список();
		
		Для Каждого ТекПрофиль Из ПрофилиБезопасности Цикл

			ПоляОбъекта = ПолучитьПоляОбъекта(ТекПрофиль);

			ПоляОбъекта.Вставить("Каталоги",
			                     ПолучитьСписокОбъектов(ТекПрофиль.Каталоги().Список(),
			                                            ТекПрофиль.Каталоги().ПараметрыОбъекта()));
			ПоляОбъекта.Вставить("COMКлассы",
			                     ПолучитьСписокОбъектов(ТекПрофиль.COMКлассы().Список(),
			                                            ТекПрофиль.COMКлассы().ПараметрыОбъекта()));
	
			ПоляОбъекта.Вставить("ВнешниеКомпоненты",
			                     ПолучитьСписокОбъектов(ТекПрофиль.ВнешниеКомпоненты().Список(),
			                                            ТекПрофиль.ВнешниеКомпоненты().ПараметрыОбъекта()));
	
			ПоляОбъекта.Вставить("ВнешниеМодули",
			                     ПолучитьСписокОбъектов(ТекПрофиль.ВнешниеМодули().Список(),
			                                            ТекПрофиль.ВнешниеМодули().ПараметрыОбъекта()));
	
			ПоляОбъекта.Вставить("Приложения",
			                     ПолучитьСписокОбъектов(ТекПрофиль.Приложения().Список(),
			                                            ТекПрофиль.Приложения().ПараметрыОбъекта()));
	
			ПоляОбъекта.Вставить("ИнтернетРесурсы",
			                     ПолучитьСписокОбъектов(ТекПрофиль.ИнтернетРесурсы().Список(),
			                                            ТекПрофиль.ИнтернетРесурсы().ПараметрыОбъекта()));
	
			ТекОписаниеКластера["ПрофилиБезопасности"].Добавить(ПоляОбъекта);

		КонецЦикла;

	КонецЦикла;

	Возврат ОписаниеКластера;

КонецФункции // ПолучитьОписаниеКластера()

// Процедура - выполняет запись переданных данных в файл
//
Процедура ВывестиДанные(Знач Данные, Знач ПутьКФайлу = Неопределено)
	
	Запись = Новый ЗаписьJSON();
	
	Если ПутьКФайлу = Неопределено Тогда
		Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));
	Иначе
		ОбеспечитьКаталог(ПутьКФайлу, Истина);
	
		Запись.ОткрытьФайл(ПутьКФайлу, "UTF-8", , Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));

		Лог.Информация("[%1]: Запись данных в файл ""%2""", ТипЗнч(ЭтотОбъект), ПутьКФайлу);
	КонецЕсли;

	Попытка
		ЗаписатьJSON(Запись, Данные);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Если ПутьКФайлу = Неопределено Тогда
		Сообщить(Запись.Закрыть());
	Иначе
		Запись.Закрыть();
	КонецЕсли;
	
КонецПроцедуры // ВывестиДанные()

Функция ПолучитьСписокАдминистраторов(Знач ОбъектАдминистрирования)

	СписокАдминистраторов = Новый Массив();

	Администраторы = ОбъектАдминистрирования.Администраторы().Список();
	Для Каждого ТекАдминистратор Из Администраторы Цикл
		Параметры = ОбъектАдминистрирования.Администраторы().ПараметрыОбъекта();
		ПоляОбъекта = Новый Соответствие();
		Для Каждого ТекПараметр Из Параметры Цикл
			ПоляОбъекта.Вставить(ТекПараметр.Значение.ИмяРАК, ТекАдминистратор.Получить(ТекПараметр.Значение.ИмяРАК));
		КонецЦикла;
		СписокАдминистраторов.Добавить(ПоляОбъекта);
	КонецЦикла;

	Возврат СписокАдминистраторов;

КонецФункции // ПолучитьСписокАдминистраторов()

Функция ПолучитьСписокОбъектов(Знач Список, Знач Параметры = Неопределено)

	СписокОбъектов = Новый Массив();

	Для Каждого ТекОбъект Из Список Цикл
		СписокОбъектов.Добавить(ПолучитьПоляОбъекта(ТекОбъект, Параметры));
	КонецЦикла;

	Возврат СписокОбъектов;

КонецФункции // ПолучитьСписокОбъектов()

Функция ПолучитьПоляОбъекта(Знач ОбъектКластера, Знач Параметры = Неопределено)

	ПоляОбъекта = Новый Соответствие();

	ИспользоватьПараметрыОбъекта = (Параметры = Неопределено);
	Если ИспользоватьПараметрыОбъекта Тогда
		Параметры = ОбъектКластера.ПараметрыОбъекта();
	КонецЕсли;

	Для Каждого ТекПараметр Из Параметры Цикл
		Если ИспользоватьПараметрыОбъекта Тогда
			Ключ = ТекПараметр.Ключ;
		Иначе
			Ключ = ТекПараметр.Значение.ИмяРАК;
		КонецЕсли;
		ПоляОбъекта.Вставить(ТекПараметр.Значение.ИмяРАК, ОбъектКластера.Получить(Ключ));
	КонецЦикла;

	Возврат ПоляОбъекта;

КонецФункции // ПолучитьПоляОбъекта()

#КонецОбласти // ОбработкаКоманды

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Функция - создает необходимые каталоги для указанного пути
//
// Параметры:
//	Путь       - Строка     - проверяемый путь
//	ЭтоФайл    - Булево     - Истина - в параметре "Путь" передан путь к файлу
//                            Ложь - передан каталог
//
// Возвращаемое значение:
//	Булево     - указанный путь доступен
//
Функция ОбеспечитьКаталог(Знач Путь, Знач ЭтоФайл = Ложь) Экспорт
	
	ВремФайл = Новый Файл(Путь);
	
	Если ЭтоФайл Тогда
		Путь = Сред(ВремФайл.Путь, 1, СтрДлина(ВремФайл.Путь) - 1);
		ВремФайл = Новый Файл(Путь);
	КонецЕсли;
	
	Если НЕ ВремФайл.Существует() Тогда
		Если ОбеспечитьКаталог(Сред(ВремФайл.Путь, 1, СтрДлина(ВремФайл.Путь) - 1)) Тогда
			СоздатьКаталог(Путь);
		Иначе
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ВремФайл.ЭтоКаталог() Тогда
		ВызватьИсключение СтрШаблон("По указанному пути ""%1"" не удалось создать каталог", Путь);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ОбеспечитьКаталог()

#КонецОбласти // СлужебныеПроцедурыИФункции
