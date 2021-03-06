#!/bin/bash
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Add Virtual Host for LTMH  ,  Written by Andy "
echo "========================================================================="
echo "LTMH is a tool to auto-compile & install Tengine+MySQL+HHVM on Linux "
echo "This script is a tool to add virtual host for tengine "
echo "For more information please visit http://www.hhvmc.com"
echo ""
echo "========================================================================="

if [ "$1" != "--help" ]; then


	domain="www.hhvmc.com"
	echo "Please input domain:"
	read -p "(Default domain: www.hhvmc.com):" domain
	if [ "$domain" = "" ]; then
		domain="www.hhvmc.com"
	fi
	if [ ! -f "/usr/local/nginx/conf/vhost/$domain.conf" ]; then
	echo "==========================="
	echo "domain=$domain"
	echo "===========================" 
	else
	echo "==========================="
	echo "$domain is exist!"
	echo "==========================="	
	fi
	
	echo "Do you want to add more domain name? (y/n)"
	read add_more_domainame

	if [ "$add_more_domainame" == 'y' ]; then

	  echo "Type domainname,example(bbs.hhvmc.com forums.hhvmc.com ip.hhvmc.com):"
	  read moredomain
          echo "==========================="
          echo domain list="$moredomain"
          echo "==========================="
	  moredomainame=" $moredomain"
	fi

	vhostdir="/home/wwwroot/$domain"
	echo "Please input the directory for the domain:$domain :"
	read -p "(Default directory: /home/wwwroot/$domain):" vhostdir
	if [ "$vhostdir" = "" ]; then
		vhostdir="/home/wwwroot/$domain"
	fi
	echo "==========================="
	echo Virtual Host Directory="$vhostdir"
	echo "==========================="

	echo "==========================="
	echo "Allow Rewrite rule? (y/n)"
	echo "==========================="
	read allow_rewrite

	if [ "$allow_rewrite" == 'n' ]; then
		rewrite="none"
	else
		rewrite="other"
		echo "Please input the rewrite of programme :"
		echo "wordpress,discuz,typecho,sablog,dabr rewrite was exist."
		read -p "(Default rewrite: other):" rewrite
		if [ "$rewrite" = "" ]; then
			rewrite="other"
		fi
	fi
	echo "==========================="
	echo You choose rewrite="$rewrite"
	echo "==========================="

	echo "==========================="
	echo "Allow access_log? (y/n)"
	echo "==========================="
	read access_log

	if [ "$access_log" == 'n' ]; then
	  al="access_log off;"
	else
	  echo "Type access_log name(Default access log file:$domain.log):"
	  read al_name
	  if [ "$al_name" = "" ]; then
		al_name="$domain"
	  fi
	  al="access_log  /home/wwwlogs/$al_name.log  access;"
	echo "==========================="
	echo You access log file="$al_name.log"
	echo "==========================="
	fi

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start create virtul host..."
	char=`get_char`


if [ ! -d /usr/local/nginx/conf/vhost ]; then
	mkdir /usr/local/nginx/conf/vhost
fi

echo "Create Virtul Host directory......"
mkdir -p $vhostdir
touch /home/wwwlogs/$al_name.log
echo "set permissions of Virtual Host directory......"
chmod -R 755 $vhostdir
chown -R www:www $vhostdir

if [ ! -f /usr/local/nginx/conf/$rewrite.conf ]; then
  echo "Create Virtul Host ReWrite file......"
	touch /usr/local/nginx/conf/$rewrite.conf
	echo "Create rewirte file successful,now you can add rewrite rule into /usr/local/nginx/conf/$rewrite.conf."
else
	echo "You select the exist rewrite rule:/usr/local/nginx/conf/$rewrite.conf"
fi

cat >/usr/local/nginx/conf/vhost/$domain.conf<<eof
server
	{
		listen 80;
		#listen [::]:80;
		server_name $domain$moredomainame;
		index index.html index.htm index.php default.html default.htm default.php;
		root  $vhostdir;

		include $rewrite.conf;
		#error_page   404   /404.html;
		location ~ [^/]\.php(/|$)
			{
				# comment try_files $uri =404; to enable pathinfo
				#fastcgi_pass 127.0.0.1:9000;
				#fastcgi_pass  unix:/tmp/php-cgi.sock;
				fastcgi_pass unix:/var/run/hhvm/server.sock;
				fastcgi_index index.php;
				include fastcgi.conf;
				#include pathinfo.conf;
				fastcgi_intercept_errors on;
				error_page 500 501 502 503 = @fpm;
			}



		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
eof


echo "Test Nginx configure file......"
/usr/local/nginx/sbin/nginx -t
echo ""
echo "Restart Nginx......"
/usr/local/nginx/sbin/nginx -s reload

echo "========================================================================="
echo "Add Virtual Host for LTMH  ,  Written by Andy "
echo "========================================================================="
echo "For more information please visit http://www.hhvmc.com"
echo ""
echo "Your domain:$domain"
echo "Directory of $domain:$vhostdir"
echo ""
echo "========================================================================="
fi