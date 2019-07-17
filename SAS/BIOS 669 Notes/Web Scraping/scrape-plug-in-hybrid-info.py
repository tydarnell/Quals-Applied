import urllib.request

page = urllib.request.urlopen("https://www.plugincars.com/cars")

from bs4 import BeautifulSoup

soup = BeautifulSoup(page, "html.parser")

carz_all = soup.find_all(class_="carz-text-area")
#print(carz_all)

#proof of concept
#for string in carz_all[2].stripped_strings:
#    print(string)
    
len(carz_all)
#47

#for m in range(0,47):
#    for string in carz_all[m].stripped_strings:
#        print(string)

f = open('evinfo.txt', 'w')
for m in range(0,47):
    for string in carz_all[m].stripped_strings:
        f.write(string + '\n')
f.close()