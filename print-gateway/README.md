# Print Gateway (Linux prototype)

Прототип сервісу для друку стікерів на Brother QL-810W у локальній мережі.

## Ціль (MVP)
- Прийняти print job (URL або bytes PDF).
- Підготувати зображення під **DK-22223** (стрічка 50 мм, безперервна).
- Надрукувати з **cut** після кожного стікера.
- Розмір стікера: **50 мм × 30 мм** (5 см × 3 см).

## Як це має працювати в нашому сетапі
- `api-nodejs` вже вміє віддавати PDF: `/ext/print/PRINT_PARCELS_BARCODE/<IdRef>` (Cloudflare/CDN ок).
- Android/Flutter згодом буде кликати gateway (а не принтер напряму).

## Залежності
- Docker на Linux-хості (в тій самій LAN, що і принтер).
- Доступ до принтера `tcp://<printer_ip>:9100`.

## Конфіг (ENV)
- `PG_BIND` (default `0.0.0.0:8089`)
- `PG_PRINTER_IP` (required) — напр. `192.168.123.119`
- `PG_PRINTER_MODEL` (default `QL-810W`)
- `PG_DPI` (default `300`) — зараз підтримуємо лише 300dpi
- `PG_LABEL_HEIGHT_MM` (default `24`) — **висота контенту** (див. примітку про фізичні 30 мм нижче)
- `PG_CUT_COMPENSATION_MM` (default `0`) — компенсація зайвої подачі (для QL continuous + autocut)
- `PG_CROP_TOP_MM` (default `0`) — тестовий crop render зверху (мм)
- `PG_CROP_BOTTOM_MM` (default `0`) — тестовий crop render знизу (мм)
- `PG_TRIM_THRESHOLD` (default `245`) — поріг “білизни” при trim whitespace (менше = агресивніше)
- `PG_TRIM_PAD_PX` (default `2`) — padding навколо bbox після trim (px)
- `PG_FIT_MODE` (default `width_fill`) — `width_fill` (заповнити по ширині) або `contain` (вписати в box W×H без обрізання, залишає поля з боків)
- `PG_VERTICAL_FIT` (default `stretch`) — `center_pad` або `stretch` (заповнює `PG_LABEL_HEIGHT_MM` без додаткових полів)
- `PG_SIDE_PADDING_MM` (default `2`) — білі поля з боків у режимі `width_fill` (quiet zones для штрихкоду)
- `PG_BROTHER_LABEL` (default `50`) — id стрічки в `brother_ql` (для DK-22223 50мм це `50`)
- `PG_BACKEND` (default `network`)
- `PG_PRINTER_URI` (default `tcp://<ip>:9100`)
- `PG_DRY_RUN` (default `0`) — 1 = рендеримо, але не шлемо на принтер (для дебагу)
- `PG_CUT_MODE` (default `cut_at_end`) — `autocut` або `cut_at_end`
- `PG_FEED_MARGIN_DOTS` (default `0`) — override для `ESC i d` (подача/поля принтера, dots @300dpi)

## Запуск (Docker)
```bash
cd print-gateway
# (опціонально) створити .env для docker compose
cp .env.example .env
# відредагуй PG_PRINTER_IP (і при потребі інші змінні)
docker compose up --build
```

## Smoke test
### 1) Healthcheck
```bash
curl -sS http://localhost:8089/healthz
```

### 2) Друк з PDF URL (приклад з нашого backend)
```bash
curl -sS -X POST http://localhost:8089/v1/print/pdf-url \\
  -H 'Content-Type: application/json' \\
  -d '{\"pdfUrl\":\"https://api.globalcars.com.ua/ext/print/PRINT_PARCELS_BARCODE/0x82ab02cd7749c8a011f097c65fe6c08a\"}'
```

## Примітки
- Для DK-22223 це **continuous tape**, тому довжина (30 мм) контролюється висотою зображення.
- `brother_ql` друкує по **printable** ширині стрічки (для `50` це 554 dots @300dpi), по боках є поля.
- **Важливо (QL-810W + DK-22223):** принтер має мінімальні фізичні поля/подачу для різу (~3 мм зверху і ~3 мм знизу).
  - Тому якщо рендерити рівно 30 мм контенту, фізичний відріз буде ~35–36 мм.
  - Практичний профіль для фізичних **50×30 мм**: `PG_LABEL_HEIGHT_MM=24`, `PG_FEED_MARGIN_DOTS=0`, `PG_CUT_MODE=cut_at_end`, `PG_VERTICAL_FIT=stretch`.
  - Для штрихкодів рекомендовано `PG_FIT_MODE=width_fill` + `PG_SIDE_PADDING_MM=2` (quiet zones). Якщо треба зробити максимально вузько — `PG_FIT_MODE=contain`.

## Профілі (рекомендовано)
### `ql810w_dk22223_50x30_barcode`
Для **Brother QL-810W** + **DK-22223 (50мм, continuous)**, фізична етикетка ~**50×30мм**:
- `PG_DPI=300`
- `PG_BROTHER_LABEL=50`
- `PG_LABEL_HEIGHT_MM=24`
- `PG_CUT_MODE=cut_at_end`
- `PG_FEED_MARGIN_DOTS=0`
- `PG_VERTICAL_FIT=stretch`
- `PG_FIT_MODE=width_fill`
- `PG_SIDE_PADDING_MM=2` (проміжний варіант; підкручувати 0..4 за відчуттям)
