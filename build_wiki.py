"""
Wiki Build Tool
将 docs/ 下的 Markdown 文件转换为 HTML 片段，供游戏客户端加载。

输出目录: build/（构建后自动镜像同步到 ../src/server/WarService/wiki）
  ├── index.json      (导航结构 + 各页版本号)
  └── pages/          (HTML 片段)
       ├── index.html
       ├── cities-overview.html
       ├── economy-gold.html
       └── ...

注: wiki.css 不再由本工具生成/同步，改为直接在 WarService/wiki/wiki.css 手工维护。

用法: python build_wiki.py
"""

import os
import re
import json
import shutil
import hashlib
import yaml
import markdown
from pathlib import Path

# === 配置 ===
SCRIPT_DIR = Path(__file__).parent
DOCS_DIR = SCRIPT_DIR / "docs"
BUILD_DIR = SCRIPT_DIR / "build"
PAGES_DIR = BUILD_DIR / "pages"
MKDOCS_YML = SCRIPT_DIR / "mkdocs.yml"
MANIFEST_PATH = BUILD_DIR / ".manifest.json"   # 增量构建清单：记录各页源/产物哈希
GEN_VERSION = "2"   # 生成器版本：改动转换逻辑时 +1，可强制全量重建
# 搜索索引：由 Material (mkdocs build) 生成于 site/search/，本工具只原样拷贝，不重新生成
SEARCH_INDEX_SRC = SCRIPT_DIR / "site" / "search" / "search_index.json"
# 部署目录：构建产物直接同步到游戏工程 WarService/wiki，省去手动拷贝
# （从脚本位置推导：e:\War\wiki -> e:\War\src\server\WarService\wiki）
DEPLOY_DIR = (SCRIPT_DIR / ".." / "src" / "server" / "WarService" / "wiki").resolve()


def md_path_to_page_id(md_path: str) -> str:
    """
    将 markdown 相对路径转为 page ID。
    例: 'cities/overview.md' -> 'cities-overview'
        'index.md' -> 'index'
    """
    p = md_path.replace("\\", "/")
    p = re.sub(r"\.md$", "", p)
    p = p.strip("/")
    if not p:
        return "index"
    return p.replace("/", "-")


def resolve_link(href: str, current_file: str) -> str:
    """
    解析 markdown 中的内部链接，将相对 .md 路径转为 page ID。
    例: '../cities/routes.md' (从 economy/gold.md) -> 'cities-routes'
        '../economy/resources.md#oil' -> 'economy-resources#oil'
    """
    # 分离锚点
    anchor = ""
    if "#" in href:
        href, anchor = href.rsplit("#", 1)
        anchor = "#" + anchor

    # 外部链接不处理
    if href.startswith("http://") or href.startswith("https://"):
        return href + anchor

    # 非 .md 文件不处理（如图片）
    if not href.endswith(".md"):
        return href + anchor

    # 基于 DOCS_DIR 解析相对路径
    current_dir = Path(current_file).parent
    resolved = (DOCS_DIR / current_dir / href).resolve()

    try:
        rel_to_docs = resolved.relative_to(DOCS_DIR.resolve())
    except ValueError:
        return href + anchor

    page_id = md_path_to_page_id(str(rel_to_docs))
    return page_id + anchor


def convert_links(html: str, source_file: str) -> str:
    """
    替换 HTML 片段中的 <a href="..."> 链接。
    将 .md 内部链接转为 data-page 属性，方便前端 JS 处理导航。
    """
    def replace_href(match):
        full_tag = match.group(0)
        href = match.group(1)

        resolved = resolve_link(href, source_file)

        # 外部链接保持原样
        if resolved.startswith("http://") or resolved.startswith("https://"):
            return full_tag

        # 内部链接：用 data-page 标记，前端 JS 拦截处理
        anchor = ""
        page_id = resolved
        if "#" in resolved:
            page_id, anchor = resolved.split("#", 1)
            anchor = "#" + anchor

        return full_tag.replace(
            f'href="{href}"',
            f'href="#" data-page="{page_id}" data-anchor="{anchor}"'
        )

    return re.sub(r'<a\s[^>]*href="([^"]*)"[^>]*>', replace_href, html)


def parse_nav(nav_items, parent_path="") -> list:
    """
    递归解析 mkdocs.yml 的 nav 结构，生成导航树。
    """
    result = []
    for item in nav_items:
        if isinstance(item, dict):
            for title, value in item.items():
                if isinstance(value, str):
                    # 叶子节点：直接是 .md 文件路径
                    page_id = md_path_to_page_id(value)
                    result.append({
                        "title": title,
                        "page": page_id
                    })
                elif isinstance(value, list):
                    # 分组节点：包含子导航
                    children = parse_nav(value)
                    result.append({
                        "title": title,
                        "children": children
                    })
    return result


def build_nav_index() -> dict:
    """
    从 mkdocs.yml 构建导航索引。
    """
    with open(MKDOCS_YML, "r", encoding="utf-8") as f:
        config = yaml.safe_load(f)

    nav = config.get("nav", [])
    nav_tree = parse_nav(nav)

    return {
        "site_name": config.get("site_name", "Wiki"),
        "nav": nav_tree
    }


def convert_md_to_html(md_file: Path) -> str:
    """
    将单个 .md 文件转换为 HTML 片段。
    """
    with open(md_file, "r", encoding="utf-8") as f:
        md_content = f.read()

    # 使用 markdown 库转换，启用表格、目录、告示框（!!!）、删除线（~~）等扩展
    html = markdown.markdown(
        md_content,
        extensions=["tables", "toc", "fenced_code", "nl2br", "admonition", "pymdownx.tilde"],
        extension_configs={
            "toc": {
                "permalink": False,
                "toc_depth": "2-3"
            },
            # ~~删除线~~ -> <del>；关闭单波浪号的 <sub> 下标，避免误伤普通文本
            "pymdownx.tilde": {
                "subscript": False
            }
        }
    )

    # 计算相对于 docs 目录的路径
    rel_path = md_file.relative_to(DOCS_DIR)

    # 转换内部链接
    html = convert_links(html, str(rel_path))

    return html


def _hash(text: str) -> str:
    """内容哈希（取 sha1 前 10 位），用作页面版本号 / 变更判定。"""
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:10]


def load_manifest() -> dict:
    """读取上次构建清单；生成器版本不符或文件不存在时返回空（触发全量重建）。"""
    if not MANIFEST_PATH.exists():
        return {}
    try:
        with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (json.JSONDecodeError, OSError):
        return {}
    if data.get("gen_version") != GEN_VERSION:
        return {}
    return data.get("pages", {})


def save_manifest(pages: dict) -> None:
    """写回构建清单。"""
    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump({"gen_version": GEN_VERSION, "pages": pages}, f, ensure_ascii=False, indent=2)


def deploy_to_warservice() -> None:
    """把构建产物同步到游戏工程 WarService/wiki（镜像：拷贝现有 + 清理多余）。"""
    if not DEPLOY_DIR.exists():
        print(f"  ! 部署目录不存在，跳过同步: {DEPLOY_DIR}")
        return

    deploy_pages = DEPLOY_DIR / "pages"
    deploy_pages.mkdir(parents=True, exist_ok=True)

    # 顶层文件（wiki.css 由 WarService/wiki 手工维护，不在此同步，避免覆盖手改）
    for name in ("index.json",):
        src = BUILD_DIR / name
        if src.exists():
            shutil.copy2(src, DEPLOY_DIR / name)

    # 搜索索引：从 site/search/ 原样拷贝（用户用 Material 生成，不在此重建）
    if SEARCH_INDEX_SRC.exists():
        shutil.copy2(SEARCH_INDEX_SRC, DEPLOY_DIR / "search_index.json")
        print("  -> 已拷贝搜索索引 search_index.json")
    else:
        print(f"  ! 未找到搜索索引，跳过拷贝: {SEARCH_INDEX_SRC}")

    # 页面片段：镜像同步
    src_files = {p.name for p in PAGES_DIR.glob("*.html")}
    for html in PAGES_DIR.glob("*.html"):
        shutil.copy2(html, deploy_pages / html.name)
    # 清理部署目录里已不存在的旧片段
    removed = 0
    for old in deploy_pages.glob("*.html"):
        if old.name not in src_files:
            old.unlink()
            removed += 1

    print(f"  -> 已同步到 {DEPLOY_DIR}")
    print(f"     片段 {len(src_files)} 个，清理旧片段 {removed} 个")


def main():
    print("=" * 50)
    print("Wiki Build Tool (incremental)")
    print("=" * 50)

    PAGES_DIR.mkdir(parents=True, exist_ok=True)

    old_manifest = load_manifest()
    new_manifest = {}
    versions = {}

    # 1. 增量转换 Markdown 文件
    print("\n[1/3] 转换 Markdown 文件（增量）...")
    md_files = sorted(DOCS_DIR.rglob("*.md"))
    current_ids = set()
    changed = skipped = 0
    for md_file in md_files:
        rel_path = md_file.relative_to(DOCS_DIR)
        page_id = md_path_to_page_id(str(rel_path))
        current_ids.add(page_id)
        output_file = PAGES_DIR / f"{page_id}.html"

        with open(md_file, "r", encoding="utf-8") as f:
            md_content = f.read()
        src_hash = _hash(md_content)

        prev = old_manifest.get(page_id)
        if prev and prev.get("src_hash") == src_hash and output_file.exists():
            # 源文件未变且产物存在 -> 跳过重新生成，沿用旧版本号
            out_hash = prev.get("out_hash", src_hash)
            skipped += 1
        else:
            html = convert_md_to_html(md_file)
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(html)
            out_hash = _hash(html)
            changed += 1
            print(f"  [生成] {rel_path} -> pages/{page_id}.html  (v={out_hash})")

        new_manifest[page_id] = {"src_hash": src_hash, "out_hash": out_hash}
        versions[page_id] = out_hash

    # 2. 清理已删除的页面
    deleted = 0
    for page_id in list(old_manifest.keys()):
        if page_id not in current_ids:
            stale = PAGES_DIR / f"{page_id}.html"
            if stale.exists():
                stale.unlink()
            deleted += 1
            print(f"  [删除] pages/{page_id}.html")

    # 3. 构建导航索引（含各页面版本号）
    print("\n[2/3] 构建导航索引...")
    nav_index = build_nav_index()
    nav_index["versions"] = versions
    index_path = BUILD_DIR / "index.json"
    with open(index_path, "w", encoding="utf-8") as f:
        json.dump(nav_index, f, ensure_ascii=False, indent=2)
    print(f"  -> {index_path.relative_to(SCRIPT_DIR)}")

    # 保存清单
    save_manifest(new_manifest)

    # 4. 同步到游戏工程 WarService/wiki（仅 index.json + pages/*.html；wiki.css 手工维护）
    print("\n[3/3] 同步到 WarService/wiki...")
    deploy_to_warservice()

    print("\n" + "=" * 50)
    print(f"构建完成！生成/更新 {changed} 个，跳过 {skipped} 个，删除 {deleted} 个")
    print(f"输出目录: {BUILD_DIR}")
    print(f"部署目录: {DEPLOY_DIR}")
    print("=" * 50)


if __name__ == "__main__":
    main()
