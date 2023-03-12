from bs4 import BeautifulSoup
import requests
import time
import datetime
import csv


header = ['Title', 'Price', 'Date']

with open('AmazonWebScraperDataset.csv', 'w', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)


def check_price():

    url = 'https://www.amazon.com/dp/069101650X/?coliid=I3LTHGRVENI05M&colid=5W8MXMZAX9H7&psc=1&ref_=gv_ov_lig_pi_dp'

    headers = {"User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/110.0",
               "Accept-Encoding": "gzip, deflate",
               "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT": "1",
               "Connection": "close", "Upgrade-Insecure-Requests": "1", "Referer": "http://www.google.com"}

    page = requests.get(url, headers=headers)

    soup1 = BeautifulSoup(page.content, "html.parser")

    soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

    title = soup2.find(id='productTitle').get_text().strip()

    dollar = soup2.find("span", attrs={'class': 'a-price-whole'}).text.strip()
    cents = soup2.find("span", attrs={'class': 'a-price-fraction'}).text.strip()
    price = float(dollar[:2] + '.' + cents[:2])

    today = datetime.datetime.today()

    data = [title, price, today]

    with open('AmazonWebScraperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)


while True:
    check_price()
    # TIME IN SECONDS
    time.sleep(10800)
