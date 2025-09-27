@echo off


echo [1/5] 添加修改...
git add -A

echo [2/5] 提交到本地仓库...
git commit -m "Auto update wiki"

echo [3/5] 推送到 GitHub...
git push origin main

echo [4/5] 部署到 GitHub Pages...
mkdocs gh-deploy --clean --force

echo 完成！网站已更新。
pause
