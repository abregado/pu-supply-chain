import csv
import math

from PIL import Image, ImageDraw, ImageFont

font = ImageFont.truetype('TitilliumWeb-SemiBold.ttf', 22)

with open('icon-names.csv') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    icons = []
    for row in readCSV:
        icons.append([row[0],row[1]])
        bgim = Image.open("icon-bg/"+row[1]+".png")
        img = bgim.copy()

        draw = ImageDraw.Draw(img)
        size = draw.textsize(row[0], font)
        print(size)
        pos = (32 - (size[0]/2), 26 - size[1]/2)
        draw.text(pos, row[0], (0, 0, 0, 1), font)

        img.save("icons/" + str(row[0]).lower() + ".png")



    print(icons)