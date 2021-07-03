REPO=https://test.pypi.org
FILES_REPO=https://test-files.pythonhosted.org
pythonPackage=snowconvert-export-tera;curl -Ls $REPO/pypi/$pythonPackage/json > snowconvert-export-tera.json
LATEST=$(cat snowconvert-export-tera.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["info"]["version"])');
echo "LATEST VERSION IS $LATEST"
echo "download $FILES_REPO/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-$LATEST.tar.gz"
rm -f snowconvert-expor-tera*
wget $FILES_REPO/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-$LATEST.tar.gz
tar -xzf snowconvert-export-tera-$LATEST.tar.gz
cd snowconvert-export-tera-$LATEST
python setup.py install
#https://test-files.pythonhosted.org/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-0.0.3.tar.gz;
## https://pypi.io/packages/source/{ package_name_first_letter }/{ package_name }/{ package_name }-{ package_version }.tar.gz
#https://test.pypi.org/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-0.0.1a4.tar.gz
#https://test.pypi.org/packages/source/s/snowconvert-export-tera/snowconvert-export-tera-0.0.1a4.tar.gz

#https://pypi.io/packages/source/p/pip/pip-19.3.1.tar.gz
#https://pypi.org/packages/source/p/pip/pip-19.3.1.tar.gz
#https://files.pythonhosted.org/packages/source/p/pip/pip-19.3.1.tar.gz
#https://files.pythonhosted.org/packages/ce/ea/9b445176a65ae4ba22dce1d93e4b5fe182f953df71a145f557cffaffc1bf/pip-19.3.1.tar.gz