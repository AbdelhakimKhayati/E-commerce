# استخدم صورة PHP مع FPM
FROM php:8.1-fpm

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# تثبيت Node.js و npm
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# تثبيت مكتبات PHP المطلوبة
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install zip pdo_mysql

# نسخ ملفات المشروع إلى الحاوية
COPY . /var/www/html

# إعداد مجلد العمل
WORKDIR /var/www/html

# التأكد من نسخ الملفات وعرض المحتوى
RUN ls -la /var/www/html

# السماح للـ Composer بالعمل كـ Superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# تثبيت الحزم
RUN composer install --no-interaction --no-dev --optimize-autoloader

# تثبيت الحزم الأمامية وتجميعها باستخدام npm
RUN npm install && npm run production

# إعطاء التصاريح اللازمة لتشغيل Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html

# CMD لتشغيل الخادم (يمكن تعديل ذلك حسب الحاجة)
CMD php artisan serve --host=0.0.0.0 --port=80

# كشف المنفذ 80
EXPOSE 80
