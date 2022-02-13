# Skryptowe_RubyScrap

Scraper w Ruby z wykożystaniem Nokogiri (https://nokogiri.org/)

## Jak działa

Przykładowy output jest widoczny w załaczonym pliku results.txt

Crawler w Ruby

Należy stworzyć crawler produktów na Amazonie lub Allegro w Ruby
wykorzystują bibliotekę Nokogiri.

3.0 Należy pobrać podstawowe dane o produktach (tytuł, cena), dowolna
kategoria
- wskazanie ścierzki do /s kategorii na stronie Amazona
- wykonywane jest zapytanie na tą stronę, gdzie z kart pobierane są nazwa i ceny (regular i sales) produktu
- ilość przejrzanych kart typu categories moze zostać ustawiona w zmiennej $pages_limit (to znaczy: że przejdzie do "next" u dou strony 2 razy -> w sumie 3 strony)
- wszystkie informacje zapisywane są w tablicy $products
- wyświetlanie wyników w trakcie pobierania informacji opcjonalne -> zmienna $display_results = false
- zapisywanie do pliku domyślnie ustawione na true -> zmienne $save_to_file = true, $filename = "results.txt"

3.5 Należy pobrać podstawowe dane o produktach wg słów kluczowych
- jeśli tablica keywors nie jest pusta, przeszukiwanie odbywa się poprzez wyszukiwanie (ale już nie po kategoriach) $keywords = []#["smart watch"]#["grill","vegetables"]
- podobnie jak w poprzednim przypadku pobierane są informacje ze zwróconej strony

4.0 Należy rozszerzyć dane o produktach o dane szczegółowe widoczne
tylko na podstronie o produkcie
- po zebraniu wszystkich produktow i ich linków można wywołać serię zapytań na strony produktów.
- dodatkowym atrybutem jest pobieranie sekcji "about this item" ze strony produktu (jeśli się da, jeśli taka istnieje)
- ilość produktów do deep search jest zdefiniowana w zmiennej $deep_search_limit = 20 (tzn. pierwszych 20 znalezionych produktów zostanie sprawdzone dokładniej)

4.5 Należy zapisać linki do produktów
- full link jest zapisywany w pliku

5.0 Dane należy zapisać w bazie danych np. SQLite via Sequel

## Sposób użycia

Sterowanie wykonaniem scrapera realizowane jest przez zmienne glogalne zdefiniowane na początku dokumentu

#it is set, won't work in other places
$base_url = "https://www.amazon.com"

#Spoof User Agent to circumvent bot restrictions
$user_agent = 

#Scraping works with amazon /s pages -> the "deeper" categories page
$starting_page = 
#"/s?i=industrial&srs=21216824011&bbn=21216824011&dc&qid=1644707744&ref=lp_21216824011_nr_i_3" #Smart Home Smart Locks & Entry
"/s?i=specialty-aps&bbn=16225009011&rh=n%3A%2116225009011%2Cn%3A281407&ref=nav_em__nav_desktop_sa_intl_accessories_and_supplies_0_2_5_2" #COMPUTER ACESSOORIES & SUPPLY CATEGORY

#setting those would trigger different scraping behavior
#leave those empty if you want to browse by the starting page
#if keywords are specified, it would launch an requests to amazon search functionality for each keyword -> and collect products based on the returned pages
$keywords = []#["smart watch"]#["grill","vegetables"]
#how many search pages to check
$keywords_pages_limit = 2
#how many categories pages can be browsed (those that are on the bottom of the page > navigation 1,2,3,4,5...etc)
$pages_limit = 3

#timeout, to reduce the rate
$timeout = 3 #seconds

#deep search / entering the product specific pages
$deep_search = true
#deep search limit / how many products to check/ if set to 0 does it to all elements
$deep_search_limit = 20

#display_results / display in console while scraping
$display_results = false

#save to file
$save_to_file = true
#filename
$filename = "results.txt"

to run:

`ruby scraper.rb`
