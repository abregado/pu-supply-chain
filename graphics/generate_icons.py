import csv
from PIL import Image, ImageDraw

with open('icon-names.csv') as csvfile:
    readCSV = csv.reader(csvfile,delimiter=',')
    icons = []
    for row in readCSV:
        icons.append([row[0],row[1]])
        bgim = PIL.open("./icons/"+row[1]+".png")
        img = bgim.copy()

        draw = ImageDraw.Draw(img)
        draw.text((0,0),row[0],(0,0,0,1))



    print(icons)