# 🛒 Brazilian E-Commerce Analysis — Olist

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![SQL](https://img.shields.io/badge/SQL-MySQL-orange?logo=mysql)
![PowerBI](https://img.shields.io/badge/Power_BI-Dashboard-yellow?logo=powerbi)
![ML](https://img.shields.io/badge/ML-Random_Forest-green?logo=scikit-learn)

## 📌 Про проєкт

End-to-end аналіз **100,000+ замовлень** бразильської e-commerce платформи Olist 
за 2016–2018 роки. Проєкт охоплює повний цикл роботи з даними: від ETL пайплайну 
до ML моделі та інтерактивного дашборду.

> **Для резюме:** Провела end-to-end аналіз Brazilian E-Commerce датасету 
> (100k+ замовлень Olist): побудувала ETL-пайплайн (Python → MySQL), виконала 
> SQL-аналіз з 10+ віконними функціями, провела статистичні тести (t-test, ANOVA, 
> chi-square), побудувала ML-модель класифікації (Random Forest, ROC-AUC = 0.74) 
> та візуалізувала результати в Power BI дашборді (5 сторінок).

---

## 🔗 Посилання

| Ресурс | Посилання |
|---|---|
| 📊 Power BI дашборд | [Переглянути дашборд](https://app.powerbi.com/view?r=eyJrIjoiMDFhZTEyMmEtNDhlYy00ZDljLTkzNTEtYmQ4MDA1YzZkM2M5IiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9) |
| 📄 Фінальний звіт | [Переглянути звіт](https://drive.google.com/file/d/10rzJ1V5dQEcaQky6A3J-v5XMbPErCnXO/view?usp=sharing) |
| 📦 Датасет (Kaggle) | [Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |

---

## 🛠 Інструменти

| Інструмент | Для чого |
|---|---|
| Python (pandas, numpy) | ETL, очищення даних, трансформація |
| matplotlib, seaborn | аналітичні візуалізації |
| scipy.stats | t-test, ANOVA, Spearman, chi-square |
| scikit-learn | ML модель: Logistic Regression + Random Forest |
| MySQL + DBeaver | SQL аналіз з віконними функціями |
| Power BI | Інтерактивний дашборд (4 сторінки) |
| SQLAlchemy | ETL: Python → MySQL |

---
---

## ❓ Аналітичні питання (16 питань)

<details>
<summary>Показати всі питання</summary>

| # | Питання | Інструмент |
|---|---|---|
| Q1 | Як змінювався GMV щомісяця? Чи є сезонність? | SQL + Python |
| Q2 | Який середній чек (AOV) і як він змінювався? | SQL |
| Q3 | Який відсоток замовлень доставлено успішно? | SQL |
| Q4 | Як змінювалась кількість нових клієнтів? | SQL |
| Q5 | Яка частка замовлень доставляється із запізненням? | SQL |
| Q6 | Чи є різниця в оцінці між вчасними та запізнілими доставками? | t-test |
| Q7 | Які штати мають найбільший час доставки? | SQL |
| Q8 | Чи корелює вартість доставки з оцінкою? | Spearman |
| Q9 | Топ-10% продавців — яку частку виручки генерують? | SQL NTILE |
| Q10 | Які категорії найприбутковіші за GMV і AOV? | SQL |
| Q11 | Чи відрізняється рейтинг продавців між штатами? | ANOVA |
| Q12 | Який розподіл кількості товарів в замовленні? | SQL |
| Q13 | Яка частка покупців повертається? (retention) | SQL |
| Q14 | Які штати генерують найбільше замовлень? | SQL |
| Q15 | Чи відрізняється completion rate між категоріями? | Chi-square |
| Q16 | Чи можна передбачити поганий відгук? | ML |

</details>

---

## 📊 Ключові результати
💰 Total GMV:        R$ 13.6M за 2 роки
📦 Замовлень:        96,478 доставлених
⭐ Avg Rating:       4.09 / 5.0
🚚 Вчасна доставка: 93.3%
👥 Унікальних клієнтів: 98,028

### Топ інсайти
- 📈 **Black Friday 2017**: пік GMV +53% MoM (R$988K за листопад)
- 🔄 **Retention**: лише 0.65% покупців повертаються за 90 днів
- 🏆 **Парето**: топ 10% продавців генерують 67% виручки
- 🚨 **Головна проблема**: затримка доставки знижує рейтинг на 1.45 бали
- 🤖 **ML**: Random Forest ROC-AUC = 0.74 для передбачення поганих відгуків

---

## 🤖 ML Модель

**Задача:** Бінарна класифікація — передбачити поганий відгук (≤ 2 зірки)

| Модель | ROC-AUC | 
|---|---|
| Logistic Regression | 0.740 |
| Random Forest | 0.728 |

**Топ фічі (Random Forest):**
1. `delivery_delay_days` — 0.232
2. `price` — 0.200
3. `freight_value` — 0.188
4. `delivery_days_actual` — 0.163

---

## 🚀 Як запустити

```bash
# 1. Клонувати репозиторій
git clone https://github.com/YOUR_USERNAME/olist-ecommerce-analysis.git

# 2. Встановити залежності
pip install pandas numpy matplotlib seaborn scikit-learn scipy sqlalchemy pymysql python-dotenv jupyter

# 3. Створити .env файл
cp .env.example .env
# Заповнити своїми даними підключення до MySQL

# 4. Запустити notebooks по порядку
jupyter notebook
```

---
