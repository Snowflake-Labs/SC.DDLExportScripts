REPO=https://test.pypi.org
FILES_REPO=https://test-files.pythonhosted.org
pythonPackage=snowconvert-export-tera;curl -Ls $REPO/pypi/$pythonPackage/json > snowconvert-export-tera.json
LATEST=$(cat snowconvert-export-tera.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["info"]["version"])');
echo "DOWNLOADING LATEST VERSION: $LATEST"
echo "download $FILES_REPO/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-$LATEST.tar.gz"
rm -f snowconvert-expor-tera*
wget $FILES_REPO/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-$LATEST.tar.gz
tar -xzf snowconvert-export-tera-$LATEST.tar.gz
cd snowconvert-export-tera-$LATEST
python setup.py install