Разные отделы продают в разных регионах (5 шт стран америка,….)
Смоделировать бд по териториям(континент – регион-страна)(3 разных объект:имя, лукап,) либо 1  объект с лукапом сам на себя
1)в  континенте только имя
2)в регионе название + к какому континету относится
3)страна название, исо код, в каком регионе

Есть аккаунт, создается системным юзером(админом).В аккаунте есть поле билинг контри, там прописывается исо код страны. Создать тригер который связывает аккаунт по билинг контри с объектом ‘страна’, и при изменении билинга изменяет страну.Если по исо коду такой страны нет то оставлять пустым.

Если страна не найдена выводить банер(сообщение) на странице аккаунта(вверху) что страна не найдена.(lwc или стандартные если найдется).ё

Саилс тим объект в котором указывается кто является руководителем + создать чайлд объект с мастердетаелами для юзеров(джаншен объект) + джаншен объект с лукапами на страну.

Каждый час запуск job все новые аккаунты у которых оунер пустой переписыват оунера на лидера команды которая привязана к региону, в котором находится аккаунт.

По итогу:  бд нарисовать, создать тригре, пейдж лайаут, джоба шедолд. Тесты
3 континента, в каждом континете по 3 региона и в каждом регионе по 3 страны
3 саилс команды – 1 за один континет и все регионы в нем.2 команда отвечает за 2 региона в одном континенте. 3 все оставшиеся
1 саилс команда – 1 лид и два работника
Скрипт на создание ~500 аккаунтов в разных странах, и не одинаковые по колву в разных странах
Создание репортов и дашбордов(сгруппировать аккаунты по 1стране и по 2оунеру) сверху дашборд запилить
Когда в саелс тиме устанавливается новый lead, то у всех работников этой тимы (кроме нового лида) менеджером становиться лид(flow) + лукап фильтр на лида(выбор только из членов команды)
!!!создать объект эмплоии(имя, фамиля, департамент(пиклист 1саилс2сапорт)) создать кастомное поле оунер на аккаунте (лукап на оунер кастомный)


