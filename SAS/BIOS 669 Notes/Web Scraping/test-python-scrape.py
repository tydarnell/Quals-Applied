import urllib.request

page = urllib.request.urlopen("https://www.plugincars.com/cars")

from bs4 import BeautifulSoup

soup = BeautifulSoup(page, "html.parser")

carz_all = soup.find_all(class_="carz-text-area")
#print(carz_all)

for string in carz_all[2].stripped_strings:
    print(string)
    