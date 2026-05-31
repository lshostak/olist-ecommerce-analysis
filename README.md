# Brazilian E-Commerce Analysis — Olist

## Опис проєкту
End-to-end аналіз 100k+ замовлень платформи Olist (2016-2018).
Відповіді на 16 аналітичних питань з використанням SQL, Python та Power BI.

## Інструменти
- **Python**: pandas, numpy, matplotlib, seaborn, scikit-learn, scipy
- **SQL**: MySQL, DBeaver, CTE, Window Functions
- **Power BI**: інтерактивний дашборд (5 сторінок)
- **ML**: Logistic Regression, Random Forest (ROC-AUC = 0.74)

## Структура проєкту
olist-project/
├── 01_etl.ipynb          # ETL пайплайн
├── 02_eda.ipynb           # Перевірка якості даних
├── 03_eda_viz.ipynb       # Візуалізації (8 графіків)
├── 03_stats.ipynb         # Статистичні тести
├── 04_ml.ipynb            # ML модель
├── 05_export_for_powerbi.ipynb
├── sql/
│   └── olist_sql_analysis.sql
├── .env.example           # Шаблон змінних середовища
└── README.md

## Ключові інсайти
- Black Friday пік: GMV +53% MoM (листопад 2017)
- Retention критично низький: 0.65% за 90 днів
- Топ 10% продавців генерують 67% виручки (Парето)
- Затримка доставки — головний фактор поганих відгуків

## Як запустити
1. Клонувати репозиторій
2. Створити .env файл (дивись .env.example)
3. Запустити 01_etl.ipynb для завантаження даних
4. Запускати notebooks по порядку