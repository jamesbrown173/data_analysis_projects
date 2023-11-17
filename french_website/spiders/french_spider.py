

################################################################################################ This code writes to CSV
import scrapy
import pprint

class FrenchSpiderSpider(scrapy.Spider):
    name = "french_spider"
    allowed_domains = ["WEBSITE_OMITTED"]

    # Proxy settings
    custom_settings = {
        'DOWNLOADER_MIDDLEWARES': {
            'client_website.middlewares.ProxyMiddleware': 543,  # Adjust the priority as needed
        },
    }
    # Adjust the range based on your requirements
    start_urls = [f"WEBSITE_OMITTED{i}" for i in range(1, 999999)]


    def parse(self, response):

        # Initialize an empty dictionary to store the results for each item
        page_profile_dict = {}

        # Extract data using CSS selectors
        page_profile_dict["page_URL"] = response.url
        page_profile_dict["URL"] = response.css('h4:contains("URL") + div.value::text').get()
        page_profile_dict["Titre court"] = response.css('h4:contains("Titre court") + div.value::text').get()
        page_profile_dict["Résumé"] = response.css('h4:contains("Résumé") + div.value::text').get()
        page_profile_dict["Lieu"] = response.css('h4:contains("Lieu") + div.value::text').get()
        page_profile_dict["ISSN"] = response.css('h4:contains("ISSN") + div.value::text').get()
        page_profile_dict["Edition"] = response.css('h4:contains("Edition") + div.value::text').get()
        page_profile_dict["Editeur"] = response.css('h4:contains("Editeur") + div.value::text').get()
        page_profile_dict["Description"] = response.css('h4:contains("Description") + div.value::text').get()
        page_profile_dict["A une parte"] = response.css('h4:contains("A une parte") + div.value::text').get()
        page_profile_dict["Titre"] = response.css('h4:contains("Titre") + div.value::text').get()
        page_profile_dict["Auteur"] = response.css('h4:contains("Auteur") + div.value::text').get()
        page_profile_dict["Année"] = response.css('h4:contains("Année") + div.value::text').get()
        page_profile_dict["Type"] = response.css('h4:contains("Type") + div.value::text').get()
        page_profile_dict["Pages"] = response.css('h4:contains("Pages") + div.value::text').get()
        page_profile_dict["ISBN"] = response.css('h4:contains("ISBN") + div.value::text').get()
        page_profile_dict["Titre du périodique"] = response.css(
            'h4:contains("Titre du périodique") + div.value::text').get()
        page_profile_dict["Numéro"] = response.css('h4:contains("Numéro") + div.value::text').get()

        # Mot-cle handing
        values = response.css('div.value').xpath('string()').get().split('<br>')
        formatted_values = ', '.join(value.strip() for value in values if value.strip())
        page_profile_dict["Mot-clé"] = formatted_values

        # Thesaurus handling
        thesaurus_names = response.css('h4:contains("Thésaurus") + div.value a.resource-name::text').getall()
        thesaurus_links = response.css('h4:contains("Thésaurus") + div.value a.resource-name::attr(href)').getall()
        thesaurus_entries = [f"{name} - Link to {link}" for name, link in zip(thesaurus_names, thesaurus_links)]
        formatted_thesaurus = ', '.join(thesaurus_entries)
        page_profile_dict["Thesaurus"] = formatted_thesaurus

        # Print or yield the dictionary as needed
        pprint.pprint(page_profile_dict, sort_dicts=False)

        # You can also yield the dictionary if you want to store the data or continue processing
        yield page_profile_dict

