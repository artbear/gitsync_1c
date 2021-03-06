#Использовать asserts
#Использовать tempfiles
#Использовать logos
#Использовать strings
#Использовать 1commands

#Использовать ".."

Перем юТест;
Перем Распаковщик;
Перем Лог;

Процедура Инициализация()
	
	Распаковщик = Новый МенеджерСинхронизации();
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync");
	Лог.УстановитьУровень(УровниЛога.Информация);
	
КонецПроцедуры

Функция ПолучитьСписокТестов(Знач Контекст) Экспорт
	
	юТест = Контекст;
	
	ВсеТесты = Новый Массив;
	
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьНачинаяСВерсии3");
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьМаксимумВерсию5");
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьВерсииС3По7");
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьНеБолее2");
	ВсеТесты.Добавить("Тест_ДолженЭкспортироватьПо2НоНеВыше5");
	
	Возврат ВсеТесты;
	
КонецФункции

Процедура ПослеЗапускаТеста() Экспорт
	ВременныеФайлы.Удалить();
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////
// Реализация тестов

Процедура Тест_ДолженЭкспортироватьНачинаяСВерсии3() Экспорт
	КоличествоКоммитов = ВыполнитьСинхронизацию(3);
	Утверждения.ПроверитьРавенство(КоличествоКоммитов, 6, "Количество коммитов в git-хранилище");
КонецПроцедуры

Процедура Тест_ДолженЭкспортироватьМаксимумВерсию5() Экспорт
	КоличествоКоммитов = ВыполнитьСинхронизацию(0, 5);
	Утверждения.ПроверитьРавенство(КоличествоКоммитов, 5, "Количество коммитов в git-хранилище");
КонецПроцедуры

Процедура Тест_ДолженЭкспортироватьВерсииС3По7() Экспорт
	КоличествоКоммитов = ВыполнитьСинхронизацию(3, 7);
	Утверждения.ПроверитьРавенство(КоличествоКоммитов, 5, "Количество коммитов в git-хранилище");
КонецПроцедуры

Процедура Тест_ДолженЭкспортироватьНеБолее2() Экспорт
	КоличествоКоммитов = ВыполнитьСинхронизацию(0, 0, 2);
	Утверждения.ПроверитьРавенство(КоличествоКоммитов, 2, "Количество коммитов в git-хранилище");
КонецПроцедуры

Процедура Тест_ДолженЭкспортироватьПо2НоНеВыше5() Экспорт
	КоличествоКоммитов = ВыполнитьСинхронизацию(0, 5, 2);
	Утверждения.ПроверитьРавенство(КоличествоКоммитов, 5, "Количество коммитов в git-хранилище");
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////

Функция ВыполнитьСинхронизацию(МинВерсия=0, МаксВерсия=0, Лимит=0)

	ПутьКФайлуХранилища1С = ПутьКВременномуФайлуХранилища1С();
	
	КаталогРепо = ВременныеФайлы.СоздатьКаталог();
	КаталогИсходников = ОбъединитьПути(КаталогРепо, "src");
	СоздатьКаталог(КаталогИсходников);
	
	РезультатИнициализацииГитЧисло = ИнициализироватьТестовоеХранилищеГит(КаталогРепо);
	Утверждения.ПроверитьИстину(РезультатИнициализацииГитЧисло=0, "Инициализация git-хранилища в каталоге: "+КаталогРепо);
	
	СоздатьФайлАвторовГит_ДляТестов(КаталогИсходников);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"AUTHORS"));
	Распаковщик.ЗаписатьФайлВерсийГит(КаталогИсходников,0);
	ПроверитьСуществованиеФайлаКаталога(ОбъединитьПути(КаталогИсходников,"VERSION"));
	
	Распаковщик.СинхронизироватьХранилищеКонфигурацийСГит(КаталогИсходников, ПутьКФайлуХранилища1С, МинВерсия, МаксВерсия,,,, Лимит);
	
	ИмяФайлаЛогаГит = ВременныеФайлы.НовоеИмяФайла("txt");
	
	Батник = Новый КомандныйФайл;
	Батник.ДобавитьКоманду("cd /d " + ОбернутьВКавычки(КаталогИсходников));
	Батник.ДобавитьКоманду("git log --pretty=oneline >"+ОбернутьВКавычки(ИмяФайлаЛогаГит));
	
	КодВозврата = Батник.Исполнить();
	Утверждения.ПроверитьРавенство(0, КодВозврата, "Получение краткого лога хранилища git");
	
	ЛогГит = Новый ЧтениеТекста;
	ЛогГит.Открыть(ИмяФайлаЛогаГит);
	КоличествоКоммитов = 0;
	Пока ЛогГит.ПрочитатьСтроку() <> Неопределено Цикл
		КоличествоКоммитов = КоличествоКоммитов + 1;
	КонецЦикла;
	ЛогГит.Закрыть();
	Возврат КоличествоКоммитов;

КонецФункции

Функция ОбернутьВКавычки(Знач Строка);
	Возврат """" + Строка + """";
КонецФункции

Функция ИнициализироватьТестовоеХранилищеГит(Знач КаталогРепозитория, Знач КакЧистое = Ложь)

	КодВозврата = Неопределено;
	ЗапуститьПриложение("git init" + ?(КакЧистое, " --bare", ""), КаталогРепозитория, Истина, КодВозврата);
	
	Возврат КодВозврата;

КонецФункции

Функция ПутьКВременномуФайлуХранилища1С()
	
	Возврат ОбъединитьПути(КаталогFixtures(), "ТестовыйФайлХранилища1С.1CD");
	
КонецФункции

Процедура СоздатьФайлАвторовГит_ДляТестов(Знач Каталог)

	ФайлАвторов = Новый ЗаписьТекста;
	ФайлАвторов.Открыть(ОбъединитьПути(Каталог, "AUTHORS"), "utf-8");
	ФайлАвторов.ЗаписатьСтроку("Администратор=Администратор <admin@localhost>");
	ФайлАвторов.ЗаписатьСтроку("Отладка=Отладка <debug@localhost>");
	ФайлАвторов.Закрыть();

КонецПроцедуры

Процедура ПроверитьСуществованиеФайлаКаталога(парамПуть, допСообщениеОшибки = "")
	
	Если Не ЗначениеЗаполнено(парамПуть) Тогда
		ВызватьИсключение "Не указан путь <"+допСообщениеОшибки+">";
	КонецЕсли;
	
	лфайл = Новый Файл(парамПуть);
	Если Не лфайл.Существует() Тогда
		ВызватьИсключение "Не существует файл <"+допСообщениеОшибки+">";
	КонецЕсли;
	
КонецПроцедуры

Функция КаталогFixtures()
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "fixtures");
КонецФункции

//////////////////////////////////////////////////////////////////////////////

Инициализация();