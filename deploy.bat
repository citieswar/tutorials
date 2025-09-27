@echo off


echo [1/5] edit...
git add -A

echo [2/5] commit...
git commit -m "Auto update wiki"

echo [3/5] push GitHub...
git push origin main

echo [4/5] deploy GitHub Pages...
mkdocs gh-deploy --clean --force

pause
