#=======================================
# Update OS information
#---------------------------------------
echo "VARIANT=\"NemOS\"" >> /usr/lib/os-release
echo "VARIANT_ID=\"nemos\"" >> /usr/lib/os-release
echo "IMAGE_ID=\"${kiwi_iname}\"" >> /usr/lib/os-release
echo "IMAGE_VERSION=\"${kiwi_iversion}\"" >> /usr/lib/os-release
echo "BUILD_ID=\"$(date -I -u)\"" >> /usr/lib/os-release
echo "NEMOS_HOME_URL=\"https://launchpad.net/nemos\"" >> /usr/lib/os-release
echo "NEMOS_BUG_REPORT_URL=\"https://bugs.launchpad.net/nemos\"" >> /usr/lib/os-release
