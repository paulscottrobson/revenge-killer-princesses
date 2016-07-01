from PIL import Image


class Graphic:
	def __init__(self,graphic):
		gfx = Image.open(graphic)
		print(gfx.size())




g1 = Graphic("heart1.png")