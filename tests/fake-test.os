﻿// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac-tools/
// ----------------------------------------------------------

#Использовать "../src"
#Использовать strings
#Использовать asserts
#Использовать fs
#Использовать tempfiles

Перем ЮнитТест;
Перем ВременныйКаталог;

// Процедура выполняется после запуска теста
//
Процедура ПередЗапускомТеста() Экспорт
	
КонецПроцедуры // ПередЗапускомТеста()

// Функция возвращает список тестов для выполнения
//
// Параметры:
//    Тестирование    - Тестер        - Объект Тестер (1testrunner)
//    
// Возвращаемое значение:
//    Массив        - Массив имен процедур-тестов
//    
Функция ПолучитьСписокТестов(Тестирование) Экспорт
	
	ЮнитТест = Тестирование;
	
	СписокТестов = Новый Массив;
	СписокТестов.Добавить("ТестДолжен_ЗапуститьКомандуПолученияОписанияКластераИЗавершитьсяСОшибкой");

	Возврат СписокТестов;
	
КонецФункции // ПолучитьСписокТестов()

// Процедура выполняется после запуска теста
//
Процедура ПослеЗапускаТеста() Экспорт

КонецПроцедуры // ПослеЗапускаТеста()

// Процедура - тест
//
Процедура ТестДолжен_ЗапуститьКомандуПолученияОписанияКластераИЗавершитьсяСОшибкой() Экспорт
	
	Контекст = Новый Структура();

	Аргументы = Новый Массив();
	Аргументы.Добавить("-v");
	Аргументы.Добавить("--ras");
	Аргументы.Добавить("localhost:1546");
	Аргументы.Добавить("d");

	Контекст.Вставить("АргументыКоманднойСтроки", Новый ФиксированныйМассив(Аргументы));
	Контекст.Вставить("ЭтоТест"                 , Истина);

	Попытка
		Сценарий = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "..", "src", "irac-tools.os"), Контекст);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
	КонецПопытки;

	Утверждения.ПроверитьВхождение(ТекстОшибки,
	    "Ошибка получения списка администраторов агента, КодВозврата = -1: Ошибка соединения с сервером");

КонецПроцедуры // ТестДолжен_ЗапуститьКомандуПолученияОписанияКластераИЗавершитьсяСОшибкой()
