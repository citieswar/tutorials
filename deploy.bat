@echo off


echo [1/5] ����޸�...
git add -A

echo [2/5] �ύ�����زֿ�...
git commit -m "Auto update wiki"

echo [3/5] ���͵� GitHub...
git push origin main

echo [4/5] ���� GitHub Pages...
mkdocs gh-deploy --clean --force

echo ��ɣ���վ�Ѹ��¡�
pause
