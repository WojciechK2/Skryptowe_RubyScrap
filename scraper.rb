#!/usr/local/bin/ruby -w

require 'nokogiri'
require 'open-uri'

#it is set, won't work in other places
$base_url = "https://www.amazon.com"

#Spoof User Agent to circumvent bot restrictions
$user_agent = 
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
#"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
#'Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.18'

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

#deep search
$deep_search = true
#deep search limit / how many products to check/ if set to 0 does it to all elements
$deep_search_limit = 20

#display_results / display in console while scraping
$display_results = false

#save to file
$save_to_file = true
#filename
$filename = "results.txt"

#main function for scraping, path can be swapped depending on the need
def scrape(path)
	
	time = Time.now.to_i
	#this is not the best
	if time - $last_time < $timeout
		puts "Scraping too fast"
		sleep($timeout)
	end
	
	url = $base_url + path
	doc = Nokogiri::HTML(URI.open(url,"User-Agent" => $user_agent))
	
	$last_time = Time.now.to_i
	return doc
end

#parsing for amazon /s categories pages
def parse_categories_doc(doc)

	product_tiles = doc.css('div.s-result-item')
	
	products = []

	for x in 0..(product_tiles.length()-1)

		item_name = product_tiles[x].css('span.a-size-base-plus.a-color-base.a-text-normal').text
		
		#there are different parts of the HTML with those tags, so skipped if empty
		if item_name == ""
			next
		else

			#getting the regular price
			begin
				#DUMB Exception handling, as there are trouble with span.a-offscreen (multiple tags with that name ".first" sometimes doesn't work
				regular_price = product_tiles[x].css('span.a-price.a-text-price').css('span.a-offscreen').first.text
			rescue
				regular_price = product_tiles[x].css('span.a-price.a-text-price').css('span.a-offscreen').text
			rescue
				regular_price = "Price not listed"
			end
			
			#getting sales price 
			begin
				sales_price = product_tiles[x].css('span.a-price').css('span.a-offscreen').first.text

			rescue
				sales_price = "Price not listed"
			end
			
			#getting the product link
			begin
				product_link = product_tiles[x].css('a.a-link-normal')
				product_link = product_link.attribute('href').value
			rescue
				product_link = product_tiles[x].css('a.a-link-normal')
				product_link = product_link.attribute('href').value
			end
			#if there is no sale listed -> price is listed in sales_price tags, just rewrite

			if regular_price == ""
				regular_price = sales_price
			#elsif sales_price.nil?
			#	regular_price = "Price not listed"
			end
			
			product = [item_name,regular_price,sales_price,product_link]
			
			products << product	
		end
	end
	#returning a table of tables
	return products
	
end

def search_for_next_category_page(doc)
	begin
	next_page = doc.css('a.s-pagination-item.s-pagination-next.s-pagination-button.s-pagination-separator')
	next_path = next_page.attribute('href').value

	rescue
		puts "No more next pages"
	end
	
	return next_path
end

def deepScrape(doc)

	product_description = []

	description = doc.css('#feature-bullets')
	
	list_items = description.css('li').css('span.a-list-item')
	
	list_items.each do |item|
		product_description.push(item.text + " | ")
	end
	
	return product_description

end

def displayResults
	$products.each do |prod|
		#TODO delete tag prefix
		puts "tag product_name: >>>" + prod[0]
		puts "tag1 product_regular_price: >>>" + prod[1]
		puts "tag2 product_sales_price: >>>" + prod[2]
		puts "tag3 product_link: >>>" + prod[3]
		
		if !prod[4].nil?
			if prod[4].empty? 
				next
			else
				prod[4].each do |desc|
					puts "tag4 description: >>>" + desc
				end
			end
		else
			next
		end

		if !prod[5].nil?
			if prod[5].empty? || prod[5].nil?
				next
			else
				puts "tag5 full_link: >>>" + prod[5]
			end
		else
			next
		end
	end
end

def saveToFile(filename)
	File.open(filename, "w") do |aFile|
		if aFile

			aFile.syswrite("\n base_url" + $base_url)
			aFile.syswrite("\n starting page" + $starting_page)
			aFile.syswrite("\n user-agent" + $user_agent)
			aFile.syswrite("\n deep_search_limit " + $deep_search_limit.to_s)
			
			aFile.syswrite("\n keywords: ")
			$keywords.each do |key|
				aFile.syswrite("\n\t " + key)
			end

			$products.each do |prod|

				#TODO delete tag prefix
				aFile.syswrite("\n-----------------------------------------------------------------")

				aFile.syswrite("\n product_name: " + prod[0])
				aFile.syswrite("\n product_regular_price: " + prod[1])
				aFile.syswrite("\n product_sales_price: " + prod[2])
				aFile.syswrite("\n product_link: " + prod[3])
				
				if !prod[4].nil?
					if prod[4].empty? 
						next
					else
						prod[4].each do |desc|
							aFile.syswrite("\n description: " + desc)
						end
					end
				else
					next
				end

				if !prod[5].nil?
					if prod[5].empty? || prod[5].nil?
						next
					else
						aFile.syswrite("\n full_link: " + prod[5])
					end
				else
					next
				end
				
			
				aFile.syswrite("\n-----------------------------------------------------------------")
			   
			end
		else
		   puts "Unable to open file!"
		end
	end
end

####
#MAIN LOOP

current_pages = 0

path = $starting_page

$products = []

$time = Time.now.to_i
$last_time = $time 

if $keywords.empty?

	puts "No keyword specified, going to path set in globals"

	#execution when no keywords are specified, scraper will follow next categories pages up to the defined page limit
	while current_pages < $pages_limit do	
			
			puts "Accessing path: "
			puts path
		
			doc = scrape path

			prod = parse_categories_doc doc

			prod.each do |p|
				$products.push(p)
			end

			next_page_path = search_for_next_category_page doc
			
			if !next_page_path.nil?
				path = next_page_path
			else
				break
			end
			
			current_pages += 1

	end

#execution when keywords are specified, scraper will make a call to the search engine ad then save returned products
else
	
	$keywords.each do |keyword|
		current_pages = 0
	
		puts "Keyword: " + keyword
		
		path = "/s?k=#{keyword}&crid=3PAEZ6DYNWTWO&sprefix=#{keyword}%2Caps%2C314&ref=nb_sb_noss"
	
		while current_pages < $keywords_pages_limit do
			
			puts "Accessing path: "
			puts path
		
			doc = scrape path
					
			prod = parse_categories_doc doc
			
			prod.each do |p|
				$products.push(p)
			end
			
			next_page_path = search_for_next_category_page doc
			
			if !next_page_path.nil?
				path = next_page_path
			else
				break
			end
			
			current_pages += 1
		end
	end
end

#Display results of the basic scrape
if $display_results
	displayResults
end

#DEEP SEARCH -> going through gathered products links
#Collecting "About this item list" as it doesn't show on categories pages
if $deep_search
	
	puts "Fetched products #{$products.length()} elements"
	
	if $deep_search_limit != 0
	
		puts "Begin to scan through first #{$deep_search_limit} elements"
	
	end
	
	index = 0
	
	$products.each do |pp|
		puts index.to_s + "DEEP SEARCH PRODUCT: " + pp[0]
		
		puts "Path: " + pp[3]
		
		path = pp[3]
		
		doc = scrape path
		
		additional_info = deepScrape doc
		
		pp.push(additional_info)
		
		product_full_link = $base_url + path
		
		pp.push(product_full_link)
		
		index += 1
		
		if $deep_search_limit == 0
			next
		else
			if index <= $deep_search_limit
				next
			else
				break
			end
		end	
	end	
end

#Display results of the basic scrape
if $display_results
	displayResults
end

if $save_to_file
	saveToFile $filename
end


