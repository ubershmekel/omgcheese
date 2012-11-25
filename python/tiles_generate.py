from PIL import Image
#import ImageDraw
import os

os.chdir(os.path.dirname(__file__) or '.')

tilesDict = {
        ('tiles.png', 256, 256):
            [
            ['gopher.png', 'cake.png', 'banana.png', 'kiwi.png'],
            ['orange.png', 'grape.png', None, None],
            [None, None, None, None],
            [None, None, None, None],
            ],
        ('buttons.png', 256, 128):
            [
            ['buttonEmpty.png', 'buttonCheck.png', 'buttonStar.png', None]
            ],
        }

OUT_DIR = '../images/'
IN_DIR = "../source_images/"


for out_data, images in tilesDict.items():
    out_fname, tw, th = out_data
    tile_shape = tw, th
    tiles = len(images[0]), len(images)
    im_shape = tile_shape[0] * tiles[0], tile_shape[1] * tiles[1]

    im = Image.new("RGBA", im_shape)
    #draw = ImageDraw.Draw(im)

    for y, row in enumerate(images):
        for x, fname in enumerate(row):
            if fname is None:
                continue
            icon = Image.open(IN_DIR + fname)
            # get the correct size
            #x, y = icon.size
            if icon.size != tile_shape:
                raise Exception('Wrong image size: %s is %s and not %s' % (fname, icon.size, tile_shape))
            l, t, r, b = x * tile_shape[0], y * tile_shape[1], (x + 1) * tile_shape[0], (y + 1) * tile_shape[1]
            im.paste(icon, (l, t, r, b))
     
    #del draw
    target = OUT_DIR + out_fname
    im.save(target)
     
    # optional, show the saved image in the default viewer (works in Windows)
    import webbrowser
    webbrowser.open(target)

