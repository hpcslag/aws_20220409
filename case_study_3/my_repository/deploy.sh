set -e

rm -rf /usr/local/lib/my_api
# mkdir -p /usr/local/lib/my_api
cp -R "/tmp/go-deploy" "/usr/local/lib/my_api"
sudo chmod +x /usr/local/lib/my_api

sudo systemctl restart my_api

echo "Done."

exit 0