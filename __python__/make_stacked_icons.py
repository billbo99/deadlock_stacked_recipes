import traceback
import os
from PIL import Image

stacked_matrix = [
    ((0, 12), (0, 0), (12, 6)),
    ((12, 6), (0, 12), (0, 0)),
    ((0, 0), (12, 6), (0, 12)),
    ((0, 12), (6, 0), (12, 12)),
    ((0, 12), (12, 12), (6, 0)),

    ((0, 12), (12, 6), (0, 0)),
    ((12, 6), (0, 0), (0, 12)),
    ((0, 0), (0, 12), (12, 6)),
    ((6, 0), (12, 12), (0, 12)),
    ((6, 0), (0, 12), (12, 12)),

    ((0, 0), (6, 12), (12, 0)),
    ((0, 0), (12, 0), (12, 6)),

    ((12, 12), (0, 12), (6, 0)),
    ((12, 12), (6, 0), (0, 12)),

    ((6, 12), (12, 0), (0, 0)),
    ((6, 12), (0, 0), (12, 0)),
    ((12, 12), (12, 0), (0, 6)),
    ((0, 6), (12, 12), (12, 0)),
    ((12, 0), (0, 6), (12, 12)),

    ((12, 0), (0, 0), (6, 12)),
    ((12, 0), (6, 12), (0, 0)),
    ((12, 12), (0, 6), (12, 0)),
    ((0, 6), (12, 0), (12, 12)),
    ((12, 0), (12, 12), (0, 6)),

    ((6, 6), (12, 12), (0, 0)),
    ((6, 0), (6, 12), (6, 6)),
    ((6, 6), (0, 12), (12, 0)),

    ((0, 6), (12, 6), (6, 6)),
    ((0, 0), (12, 12), (6, 6)),
    ((12, 0), (0, 12), (6, 6)),
    ((12, 6), (0, 6), (6, 6)),
    ((0, 12), (12, 0), (6, 6)),
    ((12, 12), (0, 0), (6, 6)),

    ((6, 6), (12, 0), (0, 12)),
    ((6, 12), (6, 0), (6, 6)),
    ((6, 6), (0, 0), (12, 12)),

    ((0, 6), (6, 6), (12, 6)),
    ((6, 0), (6, 6), (6, 12)),
    ((12, 6), (6, 6), (0, 6)),
    ((6, 12), (6, 6), (6, 0)),

    ((0, 0), (6, 6), (12, 12)),
    ((12, 0), (6, 6), (0, 12)),
    ((12, 12), (6, 6), (0, 0)),
    ((0, 12), (6, 6), (12, 0))
]

basedir = os.path.dirname(os.path.realpath(__file__))

def create_mips(output_folder, input_folder, filename):
    print(f"create_mips .. {filename}")

    input_fn = input_folder + filename
    fn, ext = os.path.splitext(filename)

    i_64 = Image.open(input_fn)
    i_32 = i_64.resize((32, 32), Image.LANCZOS)
    i_16 = i_64.resize((16, 16), Image.LANCZOS)
    i_8 = i_64.resize((8, 8), Image.LANCZOS)
    mipmap = Image.new('RGBA', (120, 64), color=(0, 0, 0, 0))
    mipmap.paste(i_64, (0, 0))
    mipmap.paste(i_32, (64, 0))
    mipmap.paste(i_16, (64 + 32, 0))
    mipmap.paste(i_8, (64 + 32 + 16, 0))
    mipmap.save(f"{output_folder}/{fn}{ext}")


def create_newimage(output_folder, input_folder, filename):
    print(f"create_newimage .. {filename}")

    input_fn = input_folder + filename
    fn, ext = os.path.splitext(filename)

    if not os.path.exists(f"{output_folder}{fn}"):
        os.mkdir(f"{output_folder}{fn}")

    img = Image.open(input_fn)
    width, height = img.size

    if img.mode != "RGBA":
        print(f"Image mode issue .. {fn} .. mode ({img.mode}) is expected to be RGBA")
        return

    if height == 64:
        i_64 = img.crop((0, 0, 64, 64))
        i_64 = i_64.resize((48, 48), Image.LANCZOS)
    elif height == 32:
        i_64 = img.crop((0, 0, 32, 32))
        i_64 = i_64.resize((48, 48), Image.LANCZOS)
    else:
        print(f"Image size issue .. {fn} .. height ({height}) is expected to be 32 or 64")
        return

    sheet = Image.new('RGBA', (64*9, 64*5), color=(0, 0, 0, 0))

    count = 0
    for combo in stacked_matrix:
        newimage = Image.new('RGBA', (64, 64), color=(0, 0, 0, 0))
        newimage.paste(i_64, combo[0], i_64)
        newimage.paste(i_64, combo[1], i_64)
        newimage.paste(i_64, combo[2], i_64)
        newimage.save(f"{output_folder}{fn}/{count:02d}_stacked-{fn}{ext}")

        mod = divmod(count, 9)

        sheet.paste(newimage, (mod[1]*64, mod[0]*64))

        count += 1

    sheet.save(f"{output_folder}{fn}{ext}")


if __name__ == '__main__':
    os.chdir(basedir)
    icon_input = "./raw_input/"
    icon_output = "./raw_output/"
    icon_archive = "./raw_archive/"
    mips_input = "./mips_input/"
    mips_output = "./mips_output/"
    mips_archive = "./mips_archive/"

    for folder in [icon_input, icon_output, icon_archive, mips_input, mips_output, mips_archive]:
        if not os.path.exists(folder):
            os.mkdir(folder)

    for dir_path, sub_dirs, files in os.walk(icon_input):
        for filename in files:
            try:
                create_newimage(icon_output, icon_input, filename)
                os.rename(dir_path+filename, icon_archive+filename)
            except:
                print(traceback.format_exc())

    for dir_path, sub_dirs, files in os.walk(mips_input):
        for filename in files:
            try:
                create_mips(mips_output, mips_input, filename)
                os.rename(dir_path+filename, mips_archive+filename)
            except:
                print(traceback.format_exc())