# -*- coding: utf-8 -*-
"""生成 1024x1024 App 图标：精灵球风格占位图。"""
from PIL import Image, ImageDraw
import os

SIZE = 1024
img = Image.new("RGB", (SIZE, SIZE), (10, 10, 14))
d = ImageDraw.Draw(img)

cx = cy = SIZE // 2
R = 450          # 球半径
band = 64        # 中间黑带厚度

# 上半球（红）/ 下半球（白），先画整圆再切
d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=(238, 21, 21))
d.rectangle([cx - R, cy, cx + R, cy + R], fill=(245, 245, 245))
# 外黑圈
d.ellipse([cx - R, cy - R, cx + R, cy + R], outline=(20, 20, 20), width=band)
# 中间黑带
d.rectangle([cx - R, cy - band // 2, cx + R, cy + band // 2], fill=(20, 20, 20))
# 中心按钮：白圈 + 黑芯
br = 95
d.ellipse([cx - br, cy - br, cx + br, cy + br], fill=(245, 245, 245), outline=(20, 20, 20), width=18)
ir = 42
d.ellipse([cx - ir, cy - ir, cx + ir, cy + ir], fill=(245, 245, 245))

out = os.path.join(os.path.dirname(__file__), "..", "PokeBonk", "Assets.xcassets",
                   "AppIcon.appiconset", "Icon-1024.png")
img.save(os.path.abspath(out), "PNG")
print("saved", os.path.abspath(out))
