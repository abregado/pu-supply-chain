import csv
import math

from PIL import Image, ImageDraw, ImageFont, ImageColor

font = ImageFont.truetype('TitilliumWeb-SemiBold.ttf', 22)
strfont = ImageFont.truetype('TitilliumWeb-SemiBold.ttf', 22)
color = ImageColor.getrgb("white")

with open('icon-names.csv') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    icons = []
    for row in readCSV:
        icons.append([row[0],row[1]])
        bgim = Image.open("icon-bg/"+row[1]+".png")
        img = bgim.copy()

        draw = ImageDraw.Draw(img)
        size = draw.textsize(row[0], font)
        pos = (32 - (size[0]/2), 26 - size[1]/2)
        draw.text(pos, row[0], color, font)

        img.save("icons/" + str(row[0]).lower() + ".png")
        if row[1] == 'structure':
            print("found structure")
            genstrimg = Image.open("entity/generic-three-by-three.png")
            strimg = genstrimg.copy()
            draw = ImageDraw.Draw(strimg)
            size = draw.textsize(row[0], strfont)
            draw.text((4, -4), row[0], color, strfont)
            strimg.save("entity/" + str(row[0]).lower() + ".png")



    print(icons)