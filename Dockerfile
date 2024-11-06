# استخدم صورة PHP مع FPM (FastCGI Process Manager) لتشغيل تطبيقات الويب
FROM php:8.1-fpm

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# تثبيت Node.js و npm لتشغيل وإعداد الملفات الأمامية
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# تثبيت مكتبات PHP المطلوبة لـ Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install zip pdo_mysql

# نسخ ملفات المشروع إلى حاوية Docker
COPY . /var/www/html

# إعداد مجلد العمل
WORKDIR /var/www/html

# تثبيت حزم PHP باستخدام Composer بدون حزم التطوير وتهيئة الـ autoloader
RUN composer install --no-dev --optimize-autoloader

# تثبيت الحزم الأمامية وتجميعها باستخدام npm
RUN npm install && npm run production

# إعطاء التصاريح اللازمة للمجلدات لتشغيل Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# إعداد بدء تشغيل خادم Laravel
CMD php artisan serve --host=0.0.0.0 --port=80

# كشف المنفذ 80
EXPOSE 80
