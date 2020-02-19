import os
import re

basedir = os.path.dirname(os.path.realpath(__file__))

if __name__ == '__main__':
    icon_folder = f"{basedir}\..\\dist\\graphics\\icons"

    fn_list = list()
    for root, sub, files in os.walk(icon_folder):
        for filename in files:
            fn, ext = os.path.splitext(filename)
            m = re.search("stacked-(.*)", fn)
            if m:
                fn_list.append(m.group(1))

    with open(f"{basedir}\..\\dist\\utils\\icons.lua", mode="w") as f:
        f.write("local Icons = {\n")
        for fn in fn_list:
            if fn != fn_list[-1]:
                f.write(f'    ["{fn}"] = "stacked-{fn}.png",\n')
            else:
                f.write(f'    ["{fn}"] = "stacked-{fn}.png"\n')
        f.write("}\n\n")
        f.write("return Icons\n")
