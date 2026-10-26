workspace "Сервис доставки еды" "Учебная модель архитектуры" {
    model {
        client = person "Клиент" "Оформляет заказ"
        courier = person "Курьер" "Доставляет заказ"
        restaurant_mgr = person "Менеджер ресторана" "Управляет меню"

        payment_gateway = softwareSystem "Платежный шлюз" "Эквайринг" "Внешняя"
        geo_service = softwareSystem "Геосервис / Карты" "Маршруты" "Внешняя"
        notification_svc = softwareSystem "SMS/Push-шлюз" "Уведомления" "Внешняя"

        delivery_service = softwareSystem "Сервис доставки еды" {
            client_app = container "Мобильное приложение клиента" "Клиентский интерфейс" "React Native"
            courier_app = container "Мобильное приложение курьера" "Интерфейс курьера" "Flutter"
            admin_panel = container "Веб-панель ресторана" "Админка" "React"
            api = container "Backend API" "Бизнес-логика" "Python, FastAPI" {
                orderSvc = component "OrderService" "Логика заказов" "Python"
                repo = component "OrderRepository" "Доступ к БД" "SQLAlchemy"
            }
            worker = container "Воркер диспетчеризации" "Фоновый поиск" "Python"
            db = container "Основная БД" "Хранилище данных" "PostgreSQL" "Database"
            bus = container "Шина событий" "Очередь" "RabbitMQ" "Queue"
        }

        client -> client_app "Пользуется" "HTTPS"
        courier -> courier_app "Пользуется" "HTTPS"
        restaurant_mgr -> admin_panel "Пользуется" "HTTPS"

        client_app -> api "Вызывает" "JSON/HTTPS"
        courier_app -> api "Вызывает" "JSON/HTTPS"
        admin_panel -> api "Вызывает" "JSON/HTTPS"

        api -> db "Читает/Пишет" "SQL"
        api -> bus "События" "AMQP"
        bus -> worker "Доставка" "AMQP"
        worker -> db "Обновляет" "SQL"

        api -> payment_gateway "Оплата" "HTTPS"
        api -> geo_service "Координаты" "HTTPS"
        worker -> notification_svc "Пуши" "HTTPS"

        client_app -> orderSvc "POST /orders"
        orderSvc -> repo "Использует"
        repo -> db "JDBC"
    }

    views {
        systemContext delivery_service "Context" {
            include *
            autolayout lr
        }
        container delivery_service "Containers" {
            include *
            autolayout lr
        }
        component api "Components" {
            include *
            autolayout lr
        }
        theme default
    }
}