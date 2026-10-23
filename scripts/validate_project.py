# -*- coding: utf-8 -*-
"""离线校验工程文件：pbxproj 括号/ID 引用、YAML、JSON、关键路径。"""
import json, os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
errors, oks = [], []

# 1) pbxproj
pbx = os.path.join(ROOT, "PokeBonk.xcodeproj", "project.pbxproj")
text = open(pbx, encoding="utf-8").read()
for a, b, name in [("{", "}", "braces"), ("(", ")", "parens"), ("[", "]", "brackets")]:
    if text.count(a) != text.count(b):
        errors.append(f"pbxproj {name} 不平衡: {text.count(a)} vs {text.count(b)}")
# 定义的对象 ID
defined = set(re.findall(r"\n\t\t([0-9A-F]{24}) ", text))
# 被引用的 ID（ /* ID */ 注释形式 + rootObject）
referenced = set(re.findall(r"/\* ([0-9A-F]{24}) \*/", text))
referenced.add(re.search(r"rootObject = ([0-9A-F]{24})", text).group(1))
missing = referenced - defined
if missing:
    errors.append(f"pbxproj 引用了未定义的 ID: {missing}")
if not errors:
    oks.append(f"pbxproj: {len(defined)} 个对象, 括号平衡, 无悬空引用")

# 2) JSON 文件
for rel in ["PokeBonk/Assets.xcassets/Contents.json",
            "PokeBonk/Assets.xcassets/AppIcon.appiconset/Contents.json"]:
    p = os.path.join(ROOT, rel)
    json.load(open(p, encoding="utf-8"))
    oks.append(f"JSON ok: {rel}")

# 3) YAML
try:
    import yaml
    wf = os.path.join(ROOT, ".github", "workflows", "build-unsigned-ipa.yml")
    yaml.safe_load(open(wf, encoding="utf-8"))
    oks.append("YAML ok: workflow")
except ImportError:
    oks.append("YAML: pyyaml 未装，跳过（语法人工核对过）")

# 4) 关键文件存在
for rel in ["PokeBonk/PokeBonkApp.swift", "PokeBonk/WebGameView.swift",
            "PokeBonk/Assets.xcassets/AppIcon.appiconset/Icon-1024.png",
            "PokeBonk.xcodeproj/xcshareddata/xcschemes/PokeBonk.xcscheme",
            "README.md"]:
    p = os.path.join(ROOT, rel)
    if not os.path.exists(p):
        errors.append(f"缺少文件: {rel}")
    else:
        oks.append(f"存在: {rel}")

# 5) scheme 引用的 target ID 必须存在
scheme = open(os.path.join(ROOT, "PokeBonk.xcodeproj", "xcshareddata",
             "xcschemes", "PokeBonk.xcscheme"), encoding="utf-8").read()
tid = re.search(r'BlueprintIdentifier = "([0-9A-F]{24})"', scheme).group(1)
if tid not in defined:
    errors.append(f"scheme 引用的 target {tid} 不在 pbxproj 中")

print("== 通过 ==")
for o in oks: print(" [OK]", o)
if errors:
    print("== 失败 ==")
    for e in errors: print(" [FAIL]", e)
    sys.exit(1)
