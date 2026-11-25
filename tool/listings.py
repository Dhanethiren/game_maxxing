#!/usr/bin/env python3
"""Store listing text for every language the game speaks.

Writes store/listings/<lang>.md (paste-ready for Play Console and App Store
Connect) and fails if any field breaks the store's length limit.

    python3 tool/listings.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'store', 'listings')

# Play: title 30, short 80, full 4000.  App Store: name 30, subtitle 30,
# keywords 100 (comma-separated, no spaces), promotional text 170.
LIMITS = {'title': 30, 'short': 80, 'full': 4000, 'subtitle': 30, 'keywords': 100, 'promo': 170}

L = {}

L['en'] = dict(
    play_lang='English (United States) – en-US', apple_lang='English (U.S.)',
    title='Calm Grid: Block Puzzle',
    short='Relaxing block puzzle game. No timer, no rush: fill lines and clear the board.',
    subtitle='Relaxing puzzle, no timer',
    keywords='relax,zen,brain,logic,offline,cube,combo,daily,mind,unwind,classic,casual,gem,tile,8x8,quiet',
    promo='Clear more lines at once for bigger, brighter sounds. Play offline at your own pace, in 11 languages.',
    full="""Calm Grid is a relaxing block puzzle game for quiet moments. Drag blocks onto the 8×8 grid, complete a row or column, and watch it clear with a soft chime. There's no timer and no rush: play at your own pace.

CLASSIC MODE
An endless puzzle where you chase your best score. Plan ahead, chain clears into combos, and empty the whole board for a Perfect Clear. Clear several lines with one block and every extra line plays a bigger, brighter sound.

JOURNEY MODE
Hundreds of puzzle levels with score and gem goals, 1–3 stars per level and win-streak bonuses.

MADE TO HELP YOU UNWIND
• Soft colours and hand-crafted tiles
• Gentle sounds that rise with every combo, and calm music you can turn off
• Plays offline: no Wi-Fi needed
• Your game saves after every move

DAILY FUN
• Daily reward, daily spin and three new goals every day
• 15 achievements to unlock
• Six colour themes, including a dark Midnight theme

Works on phones and tablets, in 11 languages.
Calm Grid is supported by ads. Most of them are your choice: watch one to continue a run or double your coins.""")

L['es'] = dict(
    play_lang='Spanish (Latin America) – es-419, and Spanish (Spain) – es-ES', apple_lang='Spanish (Mexico), Spanish (Spain)',
    title='Calm Grid: Puzzle de bloques',
    short='Puzzle de bloques relajante. Sin reloj ni prisas: completa líneas y despeja.',
    subtitle='Puzzle relajante, sin reloj',
    keywords='rompecabezas,bloque,relajante,zen,mente,lógica,sin internet,clásico,combo,diario,cubos,casual',
    promo='Completa varias líneas a la vez y escucha sonidos cada vez más brillantes. Juega sin conexión y a tu ritmo.',
    full="""Calm Grid es un puzzle de bloques relajante para tus momentos de calma. Arrastra bloques al tablero de 8×8, completa una fila o columna y mira cómo desaparece con un suave sonido. No hay reloj ni prisas: juega a tu ritmo.

MODO CLÁSICO
Un puzzle sin fin para superar tu récord. Planifica, encadena combos y vacía todo el tablero. Completa varias líneas con un solo bloque y cada línea extra suena más grande y brillante.

MODO VIAJE
Cientos de niveles con objetivos de puntos y gemas, de 1 a 3 estrellas por nivel y premios por rachas de victorias.

PENSADO PARA RELAJARTE
• Colores suaves y fichas hechas a mano
• Sonidos suaves que suben con cada combo y música tranquila que puedes apagar
• Juega sin conexión: no necesitas wifi
• Tu partida se guarda en cada jugada

CADA DÍA
• Recompensa diaria, ruleta diaria y tres objetivos nuevos cada día
• 15 logros por desbloquear
• Seis temas de color, incluido uno oscuro

Para móviles y tablets, en 11 idiomas.
Calm Grid se financia con anuncios. La mayoría son opcionales: mira uno para seguir jugando o duplicar tus monedas.""")

L['pt'] = dict(
    play_lang='Portuguese (Brazil) – pt-BR', apple_lang='Portuguese (Brazil)',
    title='Calm Grid: Jogo de Blocos',
    short='Quebra-cabeça de blocos relaxante. Sem tempo, sem pressa: complete linhas.',
    subtitle='Quebra-cabeça sem cronômetro',
    keywords='quebra cabeça,bloco,relaxar,zen,mente,lógica,offline,clássico,combo,diário,cubos,casual',
    promo='Complete várias linhas de uma vez e ouça sons cada vez mais brilhantes. Jogue offline, no seu ritmo.',
    full="""Calm Grid é um jogo de blocos relaxante para os seus momentos de calma. Arraste blocos para o tabuleiro 8×8, complete uma linha ou coluna e veja ela sumir com um som suave. Sem cronômetro e sem pressa: jogue no seu ritmo.

MODO CLÁSSICO
Um quebra-cabeça sem fim para bater o seu recorde. Planeje, faça combos e esvazie o tabuleiro inteiro. Complete várias linhas com um bloco só e cada linha extra soa maior e mais brilhante.

MODO JORNADA
Centenas de níveis com metas de pontos e gemas, de 1 a 3 estrelas por nível e bônus por sequência de vitórias.

FEITO PARA RELAXAR
• Cores suaves e peças feitas à mão
• Sons suaves que sobem a cada combo e música calma que você pode desligar
• Jogue offline: não precisa de Wi-Fi
• Seu jogo é salvo a cada jogada

TODO DIA
• Recompensa diária, roleta diária e três metas novas todo dia
• 15 conquistas para desbloquear
• Seis temas de cores, incluindo um tema escuro

Para celulares e tablets, em 11 idiomas.
O Calm Grid é mantido por anúncios. A maioria é opcional: assista a um para continuar jogando ou dobrar suas moedas.""")

L['fr'] = dict(
    play_lang='French (France) – fr-FR', apple_lang='French',
    title='Calm Grid : Puzzle de blocs',
    short='Puzzle de blocs relaxant. Sans chrono, sans stress : complétez des lignes.',
    subtitle='Puzzle relaxant, sans chrono',
    keywords='casse-tête,bloc,relaxant,zen,cerveau,logique,hors ligne,classique,combo,quotidien,cube',
    promo='Complétez plusieurs lignes d’un coup pour des sons toujours plus éclatants. Jouez hors ligne, à votre rythme.',
    full="""Calm Grid est un puzzle de blocs relaxant pour vos moments calmes. Faites glisser des blocs sur la grille 8×8, complétez une ligne ou une colonne et regardez-la disparaître avec un doux carillon. Pas de chrono, pas de pression : jouez à votre rythme.

MODE CLASSIQUE
Un puzzle sans fin pour battre votre record. Anticipez, enchaînez les combos et videz toute la grille. Complétez plusieurs lignes avec un seul bloc : chaque ligne en plus sonne plus fort et plus brillant.

MODE VOYAGE
Des centaines de niveaux avec des objectifs de points et de gemmes, 1 à 3 étoiles par niveau et des bonus de séries de victoires.

PENSÉ POUR SE DÉTENDRE
• Couleurs douces et tuiles faites main
• Des sons doux qui montent à chaque combo, et une musique calme que vous pouvez couper
• Jouable hors ligne : pas besoin de Wi-Fi
• Votre partie est sauvegardée à chaque coup

CHAQUE JOUR
• Récompense du jour, roue du jour et trois nouveaux objectifs
• 15 succès à débloquer
• Six thèmes de couleurs, dont un thème sombre

Pour téléphones et tablettes, en 11 langues.
Calm Grid est financé par la publicité. La plupart des pubs sont à votre choix : regardez-en une pour continuer une partie ou doubler vos pièces.""")

L['de'] = dict(
    play_lang='German – de-DE', apple_lang='German',
    title='Calm Grid: Block-Puzzle',
    short='Entspannendes Block-Puzzle. Kein Zeitdruck: Reihen füllen und abräumen.',
    subtitle='Entspannt puzzeln, ohne Timer',
    keywords='blöcke,entspannung,zen,denkspiel,logik,offline,klassisch,kombo,täglich,würfel,rätsel,ruhe',
    promo='Räume mehrere Reihen auf einmal ab – jede weitere Reihe klingt größer und heller. Offline spielbar, ganz in deinem Tempo.',
    full="""Calm Grid ist ein entspannendes Block-Puzzle für ruhige Momente. Ziehe Blöcke auf das 8×8-Feld, fülle eine Reihe oder Spalte und sieh zu, wie sie mit einem sanften Klang verschwindet. Kein Timer, kein Druck: spiel in deinem Tempo.

KLASSISCHER MODUS
Ein endloses Puzzle für deinen persönlichen Rekord. Plane voraus, verkette Kombos und räume das ganze Feld ab. Räume mehrere Reihen mit einem Block ab – jede weitere Reihe klingt größer und heller.

REISE-MODUS
Hunderte Level mit Punkte- und Edelsteinzielen, 1–3 Sternen pro Level und Boni für Siegesserien.

ZUM ENTSPANNEN GEMACHT
• Sanfte Farben und handgemachte Steine
• Sanfte Klänge, die mit jeder Kombo steigen, und ruhige Musik zum Ausschalten
• Offline spielbar: kein WLAN nötig
• Dein Spiel wird nach jedem Zug gespeichert

JEDEN TAG
• Tagesbelohnung, Glücksrad und drei neue Ziele pro Tag
• 15 Erfolge zum Freischalten
• Sechs Farbdesigns, darunter ein dunkles

Für Smartphones und Tablets, in 11 Sprachen.
Calm Grid wird durch Werbung finanziert. Die meiste Werbung ist freiwillig: Sieh dir eine an, um weiterzuspielen oder deine Münzen zu verdoppeln.""")

L['it'] = dict(
    play_lang='Italian – it-IT', apple_lang='Italian',
    title='Calm Grid: Puzzle a blocchi',
    short='Puzzle a blocchi rilassante. Niente timer né fretta: completa le linee.',
    subtitle='Puzzle rilassante, senza timer',
    keywords='rompicapo,blocchi,relax,zen,mente,logica,offline,classico,combo,giornaliero,cubi,casual',
    promo='Completa più linee in una volta: ogni linea in più suona più grande e brillante. Gioca offline, con calma.',
    full="""Calm Grid è un puzzle a blocchi rilassante per i tuoi momenti di calma. Trascina i blocchi sulla griglia 8×8, completa una riga o una colonna e guardala sparire con un suono delicato. Niente timer e niente fretta: gioca con i tuoi tempi.

MODALITÀ CLASSICA
Un puzzle infinito per battere il tuo record. Pianifica, concatena le combo e svuota tutta la griglia. Completa più linee con un solo blocco: ogni linea in più suona più grande e brillante.

MODALITÀ VIAGGIO
Centinaia di livelli con obiettivi di punti e gemme, da 1 a 3 stelle per livello e bonus per le serie di vittorie.

PENSATO PER RILASSARTI
• Colori tenui e tessere fatte a mano
• Suoni delicati che salgono a ogni combo e musica tranquilla che puoi spegnere
• Si gioca offline: non serve il Wi-Fi
• La partita si salva a ogni mossa

OGNI GIORNO
• Ricompensa giornaliera, ruota del giorno e tre nuovi obiettivi
• 15 traguardi da sbloccare
• Sei temi di colore, incluso uno scuro

Per smartphone e tablet, in 11 lingue.
Calm Grid è sostenuto dalla pubblicità. Quasi sempre sei tu a scegliere: guarda un video per continuare una partita o raddoppiare le monete.""")

L['ru'] = dict(
    play_lang='Russian – ru-RU', apple_lang='Russian',
    title='Calm Grid: Блок-головоломка',
    short='Спокойная головоломка с блоками. Без таймера: собирайте линии и очищайте поле.',
    subtitle='Головоломка без таймера',
    keywords='блоки,пазл,релакс,дзен,логика,мозг,без интернета,классика,комбо,кубики,спокойствие',
    promo='Собирайте несколько линий за раз — каждая лишняя линия звучит ярче и громче. Играйте без интернета, в своём темпе.',
    full="""Calm Grid — спокойная головоломка с блоками для минут отдыха. Перетаскивайте блоки на поле 8×8, заполняйте строки и столбцы и смотрите, как они исчезают под мягкий звон. Никакого таймера и спешки: играйте в своём темпе.

КЛАССИКА
Бесконечная головоломка для новых рекордов. Думайте наперёд, собирайте комбо и очищайте всё поле. Соберите несколько линий одним блоком — каждая лишняя линия звучит ярче и громче.

ПУТЕШЕСТВИЕ
Сотни уровней с целями по очкам и кристаллам, от 1 до 3 звёзд за уровень и бонусы за серии побед.

ЧТОБЫ РАССЛАБИТЬСЯ
• Мягкие цвета и фигуры ручной работы
• Нежные звуки, которые растут с каждым комбо, и спокойная музыка (её можно выключить)
• Играйте без интернета
• Игра сохраняется после каждого хода

КАЖДЫЙ ДЕНЬ
• Ежедневная награда, колесо удачи и три новые цели
• 15 достижений
• Шесть цветовых тем, включая тёмную

Для телефонов и планшетов, на 11 языках.
Calm Grid поддерживается рекламой. Чаще всего вы сами решаете, смотреть ли её: чтобы продолжить игру или удвоить монеты.""")

L['tr'] = dict(
    play_lang='Turkish – tr-TR', apple_lang='Turkish',
    title='Calm Grid: Blok Bulmaca',
    short='Rahatlatıcı blok bulmaca. Süre yok, acele yok: satırları doldur ve temizle.',
    subtitle='Rahatlatıcı, süresiz bulmaca',
    keywords='blok,bulmaca,rahatlatıcı,zeka,mantık,internetsiz,klasik,kombo,günlük,küp,beyin,sakin',
    promo='Tek hamlede birden çok satır temizle: her ek satır daha büyük ve parlak bir ses çalar. İnternetsiz, kendi hızında oyna.',
    full="""Calm Grid, sakin anların için rahatlatıcı bir blok bulmaca oyunu. Blokları 8×8 tahtaya sürükle, bir satırı ya da sütunu doldur ve yumuşak bir sesle kaybolmasını izle. Süre yok, acele yok: kendi hızında oyna.

KLASİK MOD
Rekorunu kovaladığın sonsuz bir bulmaca. Önceden düşün, kombolar yap ve tüm tahtayı temizle. Tek blokla birden çok satır temizle: her ek satır daha büyük ve parlak bir ses çalar.

YOLCULUK MODU
Puan ve mücevher hedefli yüzlerce seviye, seviye başına 1–3 yıldız ve galibiyet serisi bonusları.

RAHATLAMAN İÇİN
• Yumuşak renkler ve el yapımı taşlar
• Her komboyla yükselen yumuşak sesler ve kapatılabilen sakin müzik
• İnternetsiz oynanır: Wi-Fi gerekmez
• Oyunun her hamleden sonra kaydedilir

HER GÜN
• Günlük ödül, günlük çark ve her gün üç yeni hedef
• Açılacak 15 başarım
• Koyu tema dahil altı renk teması

Telefon ve tabletlerde, 11 dilde.
Calm Grid reklamlarla desteklenir. Reklamların çoğunu sen seçersin: oyuna devam etmek ya da altınlarını ikiye katlamak için izle.""")

L['id'] = dict(
    play_lang='Indonesian – id', apple_lang='Indonesian',
    title='Calm Grid: Puzzle Balok',
    short='Puzzle balok yang menenangkan. Tanpa waktu, tanpa buru-buru: penuhi baris.',
    subtitle='Puzzle santai tanpa waktu',
    keywords='balok,teka teki,santai,otak,logika,offline,klasik,kombo,harian,kubus,asah otak,tenang',
    promo='Hapus beberapa baris sekaligus: setiap baris tambahan terdengar makin meriah. Main offline, sesuai iramamu.',
    full="""Calm Grid adalah game puzzle balok yang menenangkan untuk waktu santaimu. Seret balok ke papan 8×8, penuhi satu baris atau kolom, lalu lihat balok hilang dengan suara lembut. Tanpa batas waktu dan tanpa buru-buru: main sesuai iramamu.

MODE KLASIK
Puzzle tanpa akhir untuk memecahkan rekormu. Rencanakan langkah, buat kombo, dan kosongkan seluruh papan. Hapus beberapa baris dengan satu balok: setiap baris tambahan terdengar makin meriah.

MODE PETUALANGAN
Ratusan level dengan target poin dan permata, 1–3 bintang per level, dan bonus menang beruntun.

DIBUAT UNTUK BERSANTAI
• Warna lembut dan keping buatan tangan
• Suara lembut yang naik di setiap kombo, dan musik tenang yang bisa dimatikan
• Bisa dimainkan offline: tanpa Wi-Fi
• Permainan tersimpan di setiap langkah

SETIAP HARI
• Hadiah harian, putaran harian, dan tiga target baru
• 15 pencapaian untuk dibuka
• Enam tema warna, termasuk tema gelap

Untuk ponsel dan tablet, dalam 11 bahasa.
Calm Grid didukung iklan. Sebagian besar iklan adalah pilihanmu: tonton untuk melanjutkan permainan atau menggandakan koin.""")

L['ja'] = dict(
    play_lang='Japanese – ja-JP', apple_lang='Japanese',
    title='Calm Grid: ブロックパズル',
    short='時間制限なしの癒やしブロックパズル。ラインをそろえて消していこう。',
    subtitle='時間制限なしの癒やしパズル',
    keywords='ブロック,パズル,癒やし,脳トレ,頭の体操,オフライン,クラシック,コンボ,暇つぶし,シンプル,キューブ',
    promo='一度にたくさんのラインを消すほど、音がどんどん華やかに。オフラインで、自分のペースで遊べます。',
    full="""Calm Gridは、ひと息つきたいときにぴったりの癒やし系ブロックパズルです。ブロックを8×8の盤面にドラッグして、横か縦の列をそろえると、やさしいチャイムとともに消えていきます。時間制限もせかされることもありません。自分のペースで遊べます。

クラシックモード
ベストスコアを目指すエンドレスパズル。先を読んでコンボをつなぎ、盤面をすべて消しましょう。1つのブロックで複数のラインを消すと、ラインが増えるほど音が大きく華やかになります。

ジャーニーモード
スコアやジェムを目標にした数百のレベル。各レベルで星1〜3個、連勝ボーナスもあります。

リラックスのために
• やさしい色合いと手作り風のタイル
• コンボのたびに高まるやさしいサウンドと、オフにもできる穏やかな音楽
• オフラインで遊べる：Wi-Fi不要
• 1手ごとに自動保存

毎日のお楽しみ
• デイリー報酬、デイリールーレット、毎日3つのミッション
• 15個の実績
• ダークテーマを含む6つのカラーテーマ

スマートフォンとタブレットに対応、11言語で遊べます。
Calm Gridは広告で運営しています。ほとんどの広告は自分で選べます：ゲームを続けたいときやコインを2倍にしたいときにご覧ください。""")

L['ko'] = dict(
    play_lang='Korean – ko-KR', apple_lang='Korean',
    title='Calm Grid: 블록 퍼즐',
    short='시간 제한 없는 힐링 블록 퍼즐. 줄을 채우고 보드를 비워 보세요.',
    subtitle='시간 제한 없는 힐링 퍼즐',
    keywords='블록,퍼즐,힐링,두뇌,논리,오프라인,클래식,콤보,킬링타임,큐브,심플,브레인',
    promo='한 번에 여러 줄을 지울수록 소리가 더 크고 화려해져요. 오프라인으로, 내 속도대로 즐기세요.',
    full="""Calm Grid는 쉬는 시간에 딱 맞는 힐링 블록 퍼즐 게임이에요. 블록을 8×8 보드로 끌어다 놓고 가로나 세로 줄을 채우면 부드러운 소리와 함께 사라져요. 시간 제한도 없고 서두를 필요도 없어요. 내 속도대로 즐기세요.

클래식 모드
최고 기록에 도전하는 끝없는 퍼즐. 미리 계획하고 콤보를 이어 보드를 모두 비워 보세요. 블록 하나로 여러 줄을 지우면 줄이 늘어날수록 소리가 더 크고 화려해져요.

여정 모드
점수와 보석 목표가 있는 수백 개의 레벨, 레벨마다 별 1~3개, 연승 보너스까지.

편안한 휴식을 위해
• 부드러운 색감과 손으로 만든 듯한 타일
• 콤보마다 높아지는 부드러운 효과음과 끌 수 있는 잔잔한 음악
• 오프라인 플레이: Wi-Fi 필요 없음
• 매 수마다 자동 저장

매일 즐길 거리
• 일일 보상, 일일 룰렛, 매일 새로운 목표 3개
• 15개의 업적
• 다크 테마를 포함한 6가지 색상 테마

휴대폰과 태블릿 지원, 11개 언어.
Calm Grid는 광고로 운영돼요. 대부분의 광고는 직접 선택할 수 있어요: 게임을 이어 하거나 코인을 두 배로 받고 싶을 때 보세요.""")


def main():
    os.makedirs(OUT, exist_ok=True)
    problems = []
    for lang, d in L.items():
        for field, limit in LIMITS.items():
            n = len(d[field])
            if n > limit:
                problems.append(f'{lang}.{field}: {n}/{limit}')
        if ' ' in d['keywords']:
            # Apple counts every character; spaces after commas waste them.
            if ', ' in d['keywords']:
                problems.append(f'{lang}.keywords: remove spaces after commas')
        md = f"""# Calm Grid store listing: {lang}

Play Console language: **{d['play_lang']}** · App Store language: **{d['apple_lang']}**

## Google Play

| Field | Text | Length |
|---|---|---|
| App name | {d['title']} | {len(d['title'])}/30 |
| Short description | {d['short']} | {len(d['short'])}/80 |

**Full description** ({len(d['full'])}/4000):

```
{d['full']}
```

## App Store

| Field | Text | Length |
|---|---|---|
| Name | {d['title']} | {len(d['title'])}/30 |
| Subtitle | {d['subtitle']} | {len(d['subtitle'])}/30 |
| Keywords | `{d['keywords']}` | {len(d['keywords'])}/100 |
| Promotional text | {d['promo']} | {len(d['promo'])}/170 |

Description: use the full description above.
"""
        with open(os.path.join(OUT, f'{lang}.md'), 'w') as f:
            f.write(md)
    if problems:
        raise SystemExit('Too long:\n  ' + '\n  '.join(problems))
    print(f'Wrote {len(L)} listings to store/listings/ (all within store limits).')


if __name__ == '__main__':
    main()
