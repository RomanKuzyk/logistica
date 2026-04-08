# Tooling and Skills

## Що перевірено
Curated installable skills через Codex `skill-installer` не містять готового Flutter/Android skill.

Перевірені available curated skills містять загальні або суміжні варіанти (`frontend-skill`, `playwright`, `doc` тощо), але нічого спеціально під:
- Flutter project structure
- Dart architecture
- Android integration for Flutter
- migration з legacy iOS workflow

## Висновок
Ставити випадкові суміжні skills зараз нераціонально. Вони не дадуть спеціалізованих інструкцій саме для цього rewrite.

## Що зроблено замість цього
Створено локальний custom skill:
- `~/.codex/skills/flutter-android-workflow/`

Призначення:
- bootstrap Flutter Android project;
- вести роботу від legacy research docs до конкретного Flutter implementation backlog;
- тримати в одному місці практичні правила по scanner/media/upload/printing/workflow parity.

## Як встановлювати skills у Codex
### Curated skill
Список:
```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/list-skills.py
```

Встановлення curated skill:
```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo openai/skills \
  --path skills/.curated/<skill-name>
```

### Skill з GitHub repo/path
```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo <owner>/<repo> \
  --path <path/to/skill>
```

або:
```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --url https://github.com/<owner>/<repo>/tree/<ref>/<path>
```

### Локальний custom skill
Просто створюється каталог у:
- `~/.codex/skills/<skill-name>/SKILL.md`

Після додавання або оновлення skill потрібно перезапустити Codex.

## Toolchain status у цьому середовищі
- `flutter` — відсутній
- `dart` — відсутній
- `adb` — доступний
- `java` — доступна
- `gradle` — відсутній

## Що треба встановити перед scaffold
1. Flutter SDK (stable)
2. Android SDK / Android Studio command-line tools
3. За потреби Gradle через Android toolchain
4. Перевірити `flutter doctor`
