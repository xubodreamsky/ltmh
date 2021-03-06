#!/bin/bash

Install_ImageMagick()
{
cd $ltmh_dir/src
. ../tools/download.sh
. ../options.conf

src_url=http://www.imagemagick.org/download/ImageMagick-6.9.0-10.tar.xz && Download_src

tar Jxf ImageMagick-6.9.0-10.tar.xz
cd ImageMagick-6.9.0-10
./configure
make && make install
cd ../
/bin/rm -rf ImageMagick-6.9.0-10
ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick

if [ -e "$php_install_dir/bin/phpize" ];then
	src_url=http://pecl.php.net/get/imagick-3.1.2.tgz && Download_src
	tar xzf imagick-3.1.2.tgz
	cd imagick-3.1.2
	make clean
	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
	$php_install_dir/bin/phpize
	./configure --with-php-config=$php_install_dir/bin/php-config
	make && make install
	cd ../
	/bin/rm -rf imagick-3.1.2

	if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/imagick.so" ];then
		[ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`\"@" $php_install_dir/etc/php.ini
		sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "imagick.so"@' $php_install_dir/etc/php.ini
	         service php-fpm restart 
	        echo -e "\033[31mPHP imagick module install failed, Please contact the author! \033[0m"
	fi
fi
cd ../
}
