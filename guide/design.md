# 신현중학교 알림창 — 디자인 가이드

`input/design/project/` 의 핸드오프 번들(Claude Design export)에서 추출한 디자인 시스템 명세입니다.
새 화면·활동지·문서를 만들 때 이 문서의 토큰과 컴포넌트 패턴을 그대로 사용하세요.

- 원본 파일: `학교 웹앱.dc.html` (주 디자인), `폰트 미리보기.dc.html`, `폰트 미리보기 v2.dc.html`
- 런타임: `support.js` (Claude Design 캔버스용 `<x-dc>` 런타임 + unpkg React). **재구현 시에는 정적 HTML/CSS로 옮기고, 시각 결과만 픽셀 단위로 맞춥니다.**

---

## 1. 무드

레트로 "프로그램 창(window)" UI. 두꺼운 남보라 테두리 + **블러 없는 하드 섀도우** + 파스텔 격자 배경.
제목은 두툼한 교육용 서체, 라벨은 픽셀 영문(Silkscreen)으로 옛날 소프트웨어 창 느낌을 유지합니다.
톤은 친근한 해요체, 목록 항목에는 이모지를 붙입니다. 대상은 중학생.

---

## 2. 디자인 토큰

### 2.1 색상

```css
:root{
  /* 잉크 · 종이 · 페이지 */
  --ink:        #4b3b6b;   /* 모든 테두리 · 본문 글자 */
  --paper:      #fffdf7;   /* 카드 바탕 (크림) */
  --paper-pink: #fdf6fa;   /* 입력칸 · 분홍빛 카드 바탕 */
  --page:       #e7e3f7;   /* 페이지 배경 */
  --grid:       #d8d2ee;   /* 배경 격자선 */

  /* 파스텔 팔레트 (카드 헤더 스트립 · 배지 · 칩) */
  --pink:   #f9cade;   --pink-strong:#f7a8c4;  --pink-edge:#ee9dbf;  /* focus 테두리 */
  --purple: #d6c4f5;   --purple-mut: #c9c2ea;
  --blue:   #c4d8f7;   --blue-strong:#9db2f2;                        /* 주요 버튼 */
  --mint:   #bfe9dd;   --aqua:       #a9dce4;
  --yellow: #fbe6a2;   --yellow-cap: #f0c95c;
  --green:  #d8f0c4;   --green-mut:  #c9e8b8;
  --apricot:#ffe0cc;   --salmon:     #f7bfb2;
  --sky:    #cfeaf5;
  --lilac:  #eec6ea;
  --beige:  #e8d9b8;   --olive:      #e3e0b0;

  /* 글자 보조색 */
  --muted:     #8b7cb8;   /* 설명·캡션 */
  --muted-2:   #6b5b93;   /* 비활성 탭 글자 */
  --muted-3:   #a596cc;
  --link:      #c96a97;   --link-hover:#8f6fd6;
  --footer:    #6b7fa8;

  /* 하드 섀도우 색 = 잉크의 저투명도 */
  --sh-strong: rgba(75,59,107,.22);  /* 메인 창 */
  --sh:        rgba(75,59,107,.18);  /* 카드 */
  --sh-soft:   rgba(75,59,107,.15);  /* 작은 요소 */
  --sh-press:  rgba(75,59,107,.35);  /* 눌린 상태 */
}
```

**상태색 (색만으로 구분하지 말고 글자도 함께 표기)**

| 상태 | 배경 | 글자 |
|---|---|---|
| 완료 / past | `#ece9f3` | `#8a82a6` |
| 진행 중 / live | `#7b5cd6` | `#fffdf7` |
| 예정 / upcoming | `#fffdf7` (점선 테두리 `#cfc6e6`) | `#7b6ba8` |

### 2.2 타이포그래피

| 역할 | 서체 (원본) | 대체 서체 (CDN 제약 시) | 용도 |
|---|---|---|---|
| Display | **GangwonEduPower** (`GangwonEdu`) | `Do Hyeon` | 페이지·섹션 큰 제목 |
| Round | **CookieRun** (700) | `Jua` | 소제목·버튼·칩·표 헤더·강조 라벨 |
| Body | **Maplestory** (300 / 700) | `Gowun Dodum` | 본문·설명·긴 글 |
| Pixel | **Silkscreen** (400/700) | `Silkscreen` (그대로) | 파일명 라벨·태그·**영문/숫자 전용** |
| Form | **Maplestory** (300) | `Gowun Dodum` | input/textarea/select/button |

- 폰트 미리보기 파일 결론: **제목=GangwonEdu, 나머지=CookieRun(라운드) + Maplestory(본문)** 3단 위계.
- **한글 폰트 규칙**: 제목(GangwonEdu)을 제외한 모든 한글 텍스트는 **CookieRun 또는 Maplestory 로만** 지정한다. Silkscreen은 라틴 글리프만 있으므로 한글이 섞이는 라벨엔 쓰지 않는다(한글 부분이 시스템 기본 서체로 폴백됨). 픽셀 영문 라벨은 레트로 창 느낌 유지를 위해 그대로 둔다.
- `body { font-family:'Maplestory'; font-weight:300; color:var(--ink); }`
- 링크: `a{color:var(--link)} a:hover{color:var(--link-hover)}`

**타입 스케일 (px)**

| 토큰 | 크기 | 예 |
|---|---|---|
| display-lg | 30–36 | 페이지 제목, 활동지 주제 |
| display-md | 25–26 | 창 타이틀바 제목, 탭 섹션 제목 |
| title | 19–20 | 활동 카드 제목 (CookieRun 700) |
| subtitle | 16–17 | 힌트 박스 제목, TOTAL 값 |
| body | 15 (줄높이 1.7–1.85) | 본문 |
| input | 16 | 입력칸 텍스트 |
| small | 13–14 | 설명·캡션 (`--muted`) |
| pixel | 10–11 | Silkscreen 라벨 |
| pixel-xs | 8–9 | 표 안 시각, 보조 수치 |

**폰트 로딩 스니펫**

```html
<!-- 원본 (로컬 TTF + jsdelivr + Google) -->
<link href="https://fonts.googleapis.com/css2?family=Silkscreen:wght@400;700&family=Gowun+Dodum&display=swap" rel="stylesheet">
<style>
  @font-face{font-family:'GangwonEdu';font-weight:400;font-display:swap;
    src:url('https://cdn.jsdelivr.net/gh/fonts-archive/GangwonEduPower/GangwonEduPower.woff2') format('woff2');}
  @font-face{font-family:'CookieRun';font-weight:400;src:url('fonts/CookieRun-Regular.ttf') format('truetype');}
  @font-face{font-family:'CookieRun';font-weight:700;src:url('fonts/CookieRun-Bold.ttf') format('truetype');}
  @font-face{font-family:'Maplestory';font-weight:300;src:url('fonts/Maplestory-Light.ttf') format('truetype');}
  @font-face{font-family:'Maplestory';font-weight:700;src:url('fonts/Maplestory-Bold.ttf') format('truetype');}
</style>

<!-- 대체 (Google Fonts만 — Claude Artifacts 등 CSP 제약 환경) -->
<link href="https://fonts.googleapis.com/css2?family=Do+Hyeon&family=Jua&family=Gowun+Dodum&family=Silkscreen:wght@400;700&display=swap" rel="stylesheet">
```

항상 폴백 스택을 붙입니다: `'Do Hyeon','Apple SD Gothic Neo',sans-serif` 등.

### 2.3 여백 · 레이아웃

| 토큰 | 값 |
|---|---|
| 페이지 패딩 | `28px 20px 60px` (모바일 축소 가능) |
| 콘텐츠 최대 폭 | `1080px` (문서형은 `980px`), `margin:0 auto` |
| 세로 스택 간격 | `18px` (`.wrap`), 카드 안은 `8–12px` |
| 창 본문 패딩 | `24px 22px 30px` |
| 카드 헤더 패딩 | `8px 14px` |
| 카드 본문 패딩 | `18px 20px 20px` |
| 힌트 그리드 | `repeat(auto-fit, minmax(190px,1fr))`, gap `12px` |
| 정보 입력 그리드 | `repeat(auto-fit, minmax(150px,1fr))`, gap `14px` |

레이아웃은 **flex/grid + `gap`** 으로만. 개별 margin 쌓지 않기. 넓은 표·그래프는 `overflow-x:auto` 컨테이너로 감쌉니다.

### 2.4 테두리 · 모서리 · 그림자

| 요소 | 테두리 | radius | 그림자 |
|---|---|---|---|
| 메인 창 | `4px solid var(--ink)` | `16px` | `8px 8px 0 var(--sh-strong)` |
| 주제(topic) 카드 | `4px solid var(--ink)` | `14px` | `6px 6px 0 rgba(75,59,107,.2)` |
| 일반 카드 | `3px solid var(--ink)` | `12–14px` | `5px 5px 0 var(--sh)` |
| 힌트 박스 | `3px solid var(--ink)` | `11px` | 없음 |
| 칩 / 입력 / 배지 | `3px solid var(--ink)` | `8–10px` | 칩만 `3px 3px 0 var(--sh-soft)` |
| 픽셀 태그 | `3px solid var(--ink)` | `6px` | 없음 (독립 시 `4px 4px 0`) |
| 내부 구분선 | `2px dashed rgba(75,59,107,.22~.3)` | — | — |
| 알약 / 원 | — | `999px` / `50%` | — |

- 그림자는 **항상 오프셋만, blur 0**, 색은 `rgba(75,59,107,α)`.
- **눌림 효과**: 그림자를 `1px 1px 0` 으로 줄이고 `transform:translate(3px,3px)`.
- `overflow:hidden` 을 창·카드에 걸어 헤더 스트립 모서리를 깔끔히.

---

## 3. 컴포넌트 패턴

값은 원본에서 그대로 뽑았습니다. 인라인 style 대신 CSS 클래스로 옮겨도 무방하나 시각 결과는 동일해야 합니다.

### 3.1 페이지 배경 (격자)

```css
body{
  background-color:var(--page);
  background-image:linear-gradient(var(--grid) 1px,transparent 1px),
                   linear-gradient(90deg,var(--grid) 1px,transparent 1px);
  background-size:28px 28px;
}
```

### 3.2 메인 창 + 타이틀바

```html
<div class="window">
  <div class="titlebar">
    <div class="win-title">🏫 신현중학교 정보</div>
    <div class="spacer"></div>
    <!-- 탭 (선택) -->
    <div class="win-btns"><span>_</span><span>□</span><span class="x">X</span></div>
  </div>
  <div class="win-body"><!-- 콘텐츠 --></div>
</div>
```

- `.titlebar` 배경: `linear-gradient(90deg,#f9cade 0%,#d6c4f5 55%,#c4d8f7 100%)`, `border-bottom:4px solid var(--ink)`, `padding:14px 16px`, `align-items:flex-end`.
- `.win-title`: `font-family:'GangwonEdu'; font-size:25px; letter-spacing:.5px; white-space:nowrap`.
- `.win-btns span`: `26×22px; border:3px solid var(--ink); border-radius:5px; background:var(--paper); font-family:'Silkscreen'; font-size:9–11px`. `.x` 배경 `var(--pink-strong)`.

### 3.3 픽셀 태그 / 파일명 라벨

Silkscreen 대문자 + 언더스코어 + 가짜 확장자. 섹션 정체성을 인코딩하는 장치이지 장식이 아닙니다.

```
TODAY_TOPIC   MY_INFO   ACTIVITY_1   RULE_01.txt   WORKSHEET_01
LUNCH.EXE     LOADING   MESSAGE      NOTE          TOTAL   READ ME
```

우측 보조 라벨엔 동작어: `WRITE / CHECK / DRAW / REFLECT / SUBMIT / SHARE / NEXT`.

```css
.tag{font-family:'Silkscreen',monospace;font-size:11px;
  border:3px solid var(--ink);border-radius:6px;padding:4px 8px;background:var(--yellow);}
```

### 3.4 탭 (활성 / 비활성)

`학교 웹앱.dc.html` 의 `tabStyle(active,color,cap)` 규칙:

- 공통: `font-family:'CookieRun'; font-weight:700; font-size:15px; border-radius:12px 12px 0 0; display:flex; align-items:center; gap:6px; margin-bottom:-4px; white-space:nowrap`. 좌·우·상 `3px solid var(--ink)`.
- **활성**: `padding:9px 16px 8px; background:var(--paper); color:var(--ink); border-bottom:none; box-shadow:inset 0 5px 0 <cap>, 0 -3px 8px rgba(75,59,107,.14); z-index:2`.
- **비활성**: `padding:6px 15px 5px; margin-top:3px; background:<color>; color:var(--muted-2); border-bottom:3px solid var(--ink); box-shadow:inset 0 -7px 10px rgba(75,59,107,.09); z-index:1`.

| 탭 | color | cap (활성 상단 라인) |
|---|---|---|
| 이용 규칙 | `#fbe6a2` | `#f0c95c` |
| 시간표 | `#c4d8f7` | `#7fa9e8` |
| 오늘의 급식 | `#bfe9dd` | `#6fc9b0` |
| 수업 활동지 | `#f9cade` | `#ee9dbf` |

### 3.5 섹션 / 활동 카드

```html
<section class="card" style="--accent:var(--mint)">
  <div class="card-head"><span>ACTIVITY_1</span><span class="r">WRITE</span></div>
  <div class="card-body">
    <div class="act-line">
      <div class="num">1</div>
      <h3 class="act-title">우리 학교를 떠올리는 낱말 세 개</h3>
    </div>
    <p class="hint-line">예) 넓은 운동장, 도서관 고양이, 급식실 카레</p>
    <!-- 힌트 그리드 / 입력 등 -->
  </div>
</section>
```

```css
.card{border:3px solid var(--ink);border-radius:14px;overflow:hidden;
  background:var(--paper);box-shadow:5px 5px 0 var(--sh);}
.card-head{padding:8px 14px;border-bottom:3px solid var(--ink);background:var(--accent);
  font-family:'Silkscreen',monospace;font-size:11px;
  display:flex;justify-content:space-between;align-items:center;}
.card-head .r{font-size:10px;opacity:.75;}
.card-body{padding:18px 20px 20px;display:flex;flex-direction:column;gap:12px;}
.act-line{display:flex;align-items:center;gap:10px;}
.num{width:30px;height:30px;flex:none;border:3px solid var(--ink);border-radius:8px;
  background:var(--accent);display:flex;align-items:center;justify-content:center;
  font-family:'Silkscreen',monospace;font-size:12px;}
.act-title{margin:0;font-family:'CookieRun',sans-serif;font-weight:700;font-size:20px;}
.hint-line{margin:0;font-size:14px;color:var(--muted);}
```

카드 바탕은 accent의 아주 옅은 틴트를 쓰기도 함 (`#eef9f8`, `#f4f8fe`, `#fffaee`, `#f8f4fe`, `#f1fbf7` …).

### 3.6 힌트 박스 그리드

```css
.hint-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:12px;}
.hint-box{border:3px solid var(--ink);border-radius:11px;padding:12px 14px;
  display:flex;flex-direction:column;gap:5px;background:var(--apricot);}
.hint-box .k{font-family:'Silkscreen',monospace;font-size:10px;}   /* HINT_01 */
.hint-box .t{font-family:'CookieRun',sans-serif;font-weight:700;font-size:17px;}
.hint-box .d{font-size:14px;line-height:1.6;}
```

박스마다 배경색을 돌려 씀: `--apricot` → `--green` → `--sky` → `--pink` …

### 3.7 칩 / 토글 버튼

`chip(active,pal)` 규칙:

```css
.chip{cursor:pointer;padding:8px 15px;border:3px solid var(--ink);border-radius:9px;
  background:var(--paper);font-family:'CookieRun',sans-serif;font-weight:700;font-size:15px;
  box-shadow:3px 3px 0 var(--sh-soft);}
.chip.is-on{background:var(--accent,var(--pink-strong));
  box-shadow:2px 2px 0 var(--sh-press);transform:translate(1px,1px);}
```

### 3.8 입력 필드

```css
.field{font-family:'Maplestory',sans-serif;font-weight:300;color:var(--ink);font-size:16px;
  padding:11px 12px;border:3px solid var(--ink);border-radius:9px;
  background:var(--paper-pink);outline:none;}
.field:focus{border-color:var(--pink-edge);background:#fff;}
textarea.field{min-height:88px;resize:vertical;padding:13px;border-radius:10px;
  background:#fff;font-size:15px;line-height:1.7;}
::placeholder{color:#b3a8cc;}
```

`select` 는 커스텀 화살표(겹친 `linear-gradient`)를 쓰고 나머지는 위와 동일.

### 3.9 체크 행

```css
.check-row{display:flex;align-items:center;gap:11px;padding:11px 13px;
  border:3px solid var(--ink);border-radius:10px;background:var(--paper-pink);cursor:pointer;}
.check-row.is-on{background:#eaf8f2;}
.check-row .box{width:24px;height:24px;flex:none;border:3px solid var(--ink);border-radius:6px;
  background:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;}
.check-row.is-on .box{background:var(--mint);}   /* 내용은 ✓ */
```

### 3.10 버튼

```css
.btn{cursor:pointer;padding:12px 24px;border:3px solid var(--ink);border-radius:10px;
  font-family:'CookieRun',sans-serif;font-weight:700;font-size:18px;
  background:var(--blue-strong);color:#26224a;box-shadow:4px 4px 0 rgba(75,59,107,.3);}
.btn:active{background:#8296e0;box-shadow:1px 1px 0 rgba(75,59,107,.3);transform:translate(3px,3px);}
.btn.secondary{background:var(--paper);color:var(--ink);box-shadow:4px 4px 0 rgba(75,59,107,.2);}
```

### 3.11 표 (시간표 · 급식 · 도수분포표)

- 바깥 테두리 `3px solid var(--ink)`, `border-radius:12px`, `overflow:hidden`, 하드 섀도우.
- 헤더 행: 파스텔 배경 + `border-bottom:3px solid var(--ink)`, 라벨은 `Silkscreen` 또는 `CookieRun`.
- 행 구분: `2px dashed rgba(75,59,107,.22~.3)`.
- 셀 안 시각/수치: `Silkscreen` 8–9px `--muted`.
- 숫자 정렬엔 `font-variant-numeric:tabular-nums`.
- 달력형은 `grid-template-columns:repeat(7,1fr)`, 셀 `min-height:120px`; 오늘 칸은 `box-shadow:inset 0 0 0 4px #ee9dbf` + 날짜 알약 강조.

### 3.12 그리기 / 드롭 영역

```css
.drop-zone{height:150px;border:3px dashed #b3a8cc;border-radius:10px;
  display:flex;align-items:center;justify-content:center;
  font-family:'Silkscreen',monospace;font-size:11px;color:#9c8dc4;
  background:repeating-linear-gradient(45deg,#fffdf7,#fffdf7 10px,#f8f1e2 10px,#f8f1e2 20px);}
```

### 3.13 NOTE / MESSAGE 박스

- **NOTE**: `border:3px solid var(--ink); border-radius:12px; background:var(--yellow); padding:12px 16px; box-shadow:4px 4px 0 var(--sh)`. 라벨 `Silkscreen` 10px `#8a7132`.
- **MESSAGE**: 좌측에 떠다니는 원형 아이콘 —
  `54×54px; border-radius:50%; border:3px solid var(--ink); background:var(--pink); font-size:26px; animation:floaty 3s ease-in-out infinite`.

### 3.14 푸터

```html
<div class="foot">
  <svg width="16" height="16" viewBox="0 0 16 16" fill="#6b7fa8"><!-- github --></svg>
  <span>@sage810</span>
</div>
```

`display:flex; align-items:center; justify-content:center; gap:8px`. 텍스트 `Maplestory` 300 / 14px / `--footer`.

---

## 4. 색상 배정 규칙

### 4.1 활동 카드 accent 순환

8색 순환 (원본 활동지 순서 + 확장):

| # | 색 | 토큰 | 배정 |
|---|---|---|---|
| 1 | `#a9dce4` | `--aqua` | ACTIVITY_1 |
| 2 | `#c4d8f7` | `--blue` | ACTIVITY_2 |
| 3 | `#fbe6a2` | `--yellow` | ACTIVITY_3 |
| 4 | `#d6c4f5` | `--purple` | ACTIVITY_4 |
| 5 | `#bfe9dd` | `--mint` | ACTIVITY_5 |
| 6 | `#eec6ea` | `--lilac` | ACTIVITY_6 |
| 7 | `#f7bfb2` | `--salmon` | ACTIVITY_7 |
| 8 | `#e3e0b0` | `--olive` | ACTIVITY_8 |

- **7번 = `--salmon #f7bfb2`**(문서 옛 표기 "살구"), **8번 = `--olive #e3e0b0`**. 둘 다 §2.1 팔레트의 기존 토큰 그대로이며, `--ink #4b3b6b` 글자가 그 위에서 대비 충분(§7, salmon ≈ 6:1 / olive ≈ 7:1).
- 8번을 넘어가면 다시 1번(`--aqua`)으로 돌아가 순환한다.
- 같은 accent를 카드 헤더 스트립·번호 배지·힌트 강조에 함께 사용.

### 4.2 과목별 색 (시간표 재현용)

| 과목 | 색 | 과목 | 색 |
|---|---|---|---|
| 국어 | `#f9cade` | 음악 | `#d6c4f5` |
| 수학 | `#c4d8f7` | 미술 | `#ffe0cc` |
| 영어 | `#fbe6a2` | 한문 | `#cfeaf5` |
| 과학 | `#bfe9dd` | 진로 | `#9db2f2` |
| 사회 | `#e8d9b8` | 보건 | `#f5b7c8` |
| 역사 | `#f7bfb2` | 자율 | `#e3e0b0` |
| 도덕 | `#eec6ea` | 창체 | `#c9c2ea` |
| 기술가정 | `#d8f0c4` | 체육 | `#c9e8b8` |
| 정보 | `#a9dce4` | | |

### 4.3 알레르기 번호 색 (급식 재현용)

`1 난류 #ff4d6d` · `2 우유 #ff7a1a` · `3 메밀 #ffb800` · `4 땅콩 #e8d000` · `5 대두 #9ed900` · `6 밀 #2fc744` · `7 고등어 #00c9a7` · `8 게 #00bcd4` · `9 새우 #0091ff` · `10 돼지고기 #3d5afe` · `11 복숭아 #7c4dff` · `12 토마토 #b429ff` · `13 아황산류 #e040fb` · `14 호두 #ff2d95` · `15 닭고기 #ff5252` · `16 소고기 #c1440e` · `17 오징어 #00867d` · `18 조개류 #5d6dff` · `19 잣 #8d6e00` (글자 흰색, `border-radius:6px; padding:2px 7px`).

---

## 5. 모션

```css
@keyframes floaty{0%,100%{transform:translateY(0)}50%{transform:translateY(-6px)}}
@media (prefers-reduced-motion:reduce){ *{animation:none !important} }
```

떠다니는 아이콘 정도만. 과한 애니메이션은 "AI가 만든 느낌"을 주므로 자제.

---

## 6. 인쇄 (활동지용)

`support.js` 의 인쇄 기준을 따름:

```css
@media print{
  @page{margin:.5cm;}
  figure,table,.card{break-inside:avoid;}
  *{ -webkit-print-color-adjust:exact; print-color-adjust:exact;
     animation:none !important; transition-duration:0s !important; }
  .toolbar{display:none;}          /* 화면 전용 조작 UI */
  *{box-shadow:none !important;}   /* 잉크 절약 */
}
```

색 헤더 스트립은 인쇄에서도 유지(정보 위계), 하드 섀도우는 제거.

---

## 7. 접근성

- 포커스: `:focus-visible{outline:3px solid var(--pink-edge);outline-offset:2px}` — 절대 제거하지 않기.
- 상태는 색 + 글자 둘 다로 표시 (완료 / 진행 중 / 예정).
- 토글·칩은 `<button type="button" aria-pressed>` 로, 빈칸 input엔 `aria-label`.
- 잉크(`#4b3b6b`)는 모든 파스텔 위에서 대비 충분. 파스텔 위 흰 글자는 피함 (상태 알약 제외).
- `prefers-reduced-motion` 존중.

---

## 8. 재구현 시 주의

- **`.dc.html` 은 편집용 원본**. 배포는 정적 HTML/CSS(원하면 React 등)로 옮기고 시각만 일치시킴. `<x-dc>` / `{{ }}` / `support.js` 는 가져가지 않음.
- 인라인 style → CSS 클래스로 정리 가능. 단 값(px·hex)은 위 토큰 그대로.
- **폰트**: 로컬 TTF(`fonts/`)가 없거나 jsdelivr 폰트 파일이 차단되는 환경(예: Claude Artifacts CSP는 폰트를 `fonts.gstatic.com` 만 허용)에서는 §2.2 대체 서체(Google Fonts) 사용. Silkscreen은 공통.
- 넓은 표/그래프는 `overflow-x:auto` 래퍼 필수. 본문 가로 스크롤 금지.
- 단일 라이트 테마 디자인(레트로 창). 다크 대응은 하지 않되 `body` 배경·모든 색을 토큰으로 명시.

---

## 9. 빠른 시작 (복붙용 골격)

```html
<div class="page"><div class="wrap">
  <div class="window">
    <div class="titlebar">
      <div class="win-title">🏫 신현중학교 정보</div><div class="spacer"></div>
      <span class="tag" style="background:var(--purple)">WORKSHEET</span>
      <div class="win-btns"><span>_</span><span>□</span><span class="x">X</span></div>
    </div>
    <div class="win-body">
      <section class="topic">
        <div class="topic-bar">TODAY_TOPIC</div>
        <div class="topic-in">
          <div class="eyebrow">정보 · N차시</div>
          <h2>여기에 주제</h2>
          <p>한 문장 설명.</p>
        </div>
      </section>

      <section class="card" style="--accent:var(--mint)">
        <div class="card-head"><span>ACTIVITY_1</span><span class="r">WRITE</span></div>
        <div class="card-body">
          <div class="act-line"><div class="num">1</div><h3 class="act-title">활동 제목</h3></div>
          <p class="hint-line">안내 문장</p>
          <textarea class="field" placeholder="여기에 적어요"></textarea>
        </div>
      </section>
    </div>
  </div>
  <div class="foot">
    <svg width="16" height="16" viewBox="0 0 16 16" fill="#6b7fa8"><!-- github --></svg>
    <span>@sage810</span>
  </div>
</div></div>
```

```css
.page{min-height:100vh;padding:28px 20px 60px;}
.wrap{max-width:1080px;margin:0 auto;display:flex;flex-direction:column;gap:18px;}
.window{background:var(--paper);border:4px solid var(--ink);border-radius:16px;
  overflow:hidden;box-shadow:8px 8px 0 var(--sh-strong);}
.titlebar{display:flex;align-items:flex-end;gap:14px;flex-wrap:wrap;padding:14px 16px;
  border-bottom:4px solid var(--ink);
  background:linear-gradient(90deg,#f9cade 0%,#d6c4f5 55%,#c4d8f7 100%);}
.win-title{font-family:'GangwonEdu',sans-serif;font-size:25px;letter-spacing:.5px;white-space:nowrap;}
.spacer{flex:1;}
.win-btns{display:flex;gap:6px;}
.win-btns span{width:26px;height:22px;border:3px solid var(--ink);border-radius:5px;
  background:var(--paper);display:flex;align-items:center;justify-content:center;
  font-family:'Silkscreen',monospace;font-size:10px;}
.win-btns .x{background:var(--pink-strong);}
.win-body{padding:24px 22px 30px;display:flex;flex-direction:column;gap:18px;}
.topic{border:4px solid var(--ink);border-radius:14px;overflow:hidden;background:var(--paper-pink);
  box-shadow:6px 6px 0 rgba(75,59,107,.2);}
.topic-bar{padding:9px 14px;border-bottom:3px solid var(--ink);
  background:linear-gradient(90deg,#f9cade,#d6c4f5);font-family:'Silkscreen',monospace;font-size:11px;}
.topic-in{padding:20px 22px;display:flex;flex-direction:column;gap:10px;}
.eyebrow{font-family:'Silkscreen',monospace;font-size:10px;color:var(--muted);}
.topic-in h2{margin:0;font-family:'GangwonEdu',sans-serif;font-size:30px;line-height:1.3;text-wrap:balance;}
.foot{display:flex;align-items:center;justify-content:center;gap:8px;padding-top:4px;
  font-family:'Maplestory',sans-serif;font-size:14px;color:var(--footer);}
```

(§2.1 토큰 블록과 §3 의 나머지 컴포넌트 CSS를 함께 붙여 쓰세요.)

---

## 10. 플로팅 위젯 — 활동 진행률

**적용 범위**: `학교 웹앱` 의 **수업 활동지 탭**(`state.tab==='sheet'`, `isSheet`)에서만 렌더한다. 다른 탭·다른 문서에는 쓰지 않는다.

**목적**: 가운데 정렬된 본문(`max-width:1080px; margin:0 auto`) **바깥, 화면 왼쪽 여백**에 "활동 진행률" 카드를 띄우고, 스크롤해도 뷰포트에 고정되어 같은 자리에 보이게 한다. (2026-09-03: 오른쪽 → **왼쪽**으로 이동, 폭 축소 — 아래 10.1.) 진행률 원천은 활동지 입력 완료 항목 수(예: 이름칸 1 + 활동1 서술답 1 + 4단계 체크 4 + 소감칸 1 = 총 7) 대비 완료 수의 퍼센트. 실제 계산·바인딩은 builder 담당이고, 이 절은 **시각·토큰·구조만** 규정한다.

이 위젯은 §3 의 기존 컴포넌트만으로는 표현되지 않는 **진행 바**를 포함한다. 진행 바는 §2.1 팔레트·§2.2 서체·§2.4 스케일 안에서만 구성했고 새 색·radius·서체를 만들지 않았다(아래 10.4 참고). 카드 껍데기·헤더 스트립·픽셀 라벨은 §3.5 활동 카드 / §3.3 픽셀 태그 패턴을 그대로 재사용한다.

### 10.1 배치 (§2.3 · §8 준수)

| 속성 | 값 | 근거 |
|---|---|---|
| `position` | `fixed` | 스크롤해도 뷰포트에 고정 |
| `width` | **`120px`** (컴팩트, 허용 100–140px) | `left` calc 의 위젯폭 항과 일치. 좁게 만들어 겹침 구간을 최소화 |
| `left` | `max(8px, calc((100vw - 1080px)/2 - 120px - 12px))` <br>(최상위 `zoom` 문서면 `1080px` → 시각폭, 예: `zoom:1.1` → `(100vw - 1188px)`) | 넓으면 본문 왼쪽 여백에 온전히(겹침 0), 여백 부족하면 `8px` clamp → 창 왼쪽 테두리 쪽과만 약간 겹침 |
| `top` | `96~116px` (구현 시 미세조정) | 타이틀바/탭 아래에서 시작 |
| `z-index` | `5` (낮게) | 타이틀바·탭(`z-index:2`)보다 시각적으로 앞서지 않도록 |

- `left` calc 의 위젯폭 항(`120px`)은 `width` 와 **반드시 같은 수**.
- **왼쪽 여백에 배치 + 컴팩트(120px)** 로, 시각 본문폭 1188px 기준 **뷰포트 ≈1470px 이상이면 본문과 전혀 안 겹친다**. 1300~1470px 은 창 왼쪽 테두리와 소폭 겹침(내용 카드는 안 가림). ~1280px 이하는 제목/첫 카드 좌상단과 겹침 — 그보다 좁으면 §10.2 로 숨긴다.
- 컴팩트 판에서는 헤더 우측 보조 라벨(`.r`)과 하단 안내문(`.sp-note`)을 뺀다. 큰 수치는 `20px`, 카운트는 `n/7` 로 축약.
- 본문 자체에는 가로 스크롤이 생기면 안 된다(§8). 위젯은 `fixed` 라 문서 흐름/스크롤폭에 기여하지 않지만, `right` 음수 계산이 뷰포트를 넘지 않도록 `max(8px, …)` 를 반드시 유지한다.

### 10.2 반응형 — "가능하면 항상 보이게", 진짜 좁은 화면에서만 생략

> **정정(2026-09-03)**: 이전 판은 "여백이 부족하면 숨긴다"였고 breakpoint 를
> `max-width:1480px`(zoom 문서는 1700px)로 잡았다. 그런데 그러면 1366·1440·1536·1600
> 같은 **일반 노트북 전부에서 위젯이 안 보였다.** → 전략을 바꾼다: 여백이 부족하면
> **숨기지 말고 본문 오른쪽 끝에 살짝 겹쳐서라도 보여준다.** 숨김은 모바일/태블릿
> 급(`max-width:820px`)에서만.

```css
.sheet-progress{
  right: max(8px, calc((100vw - <본문 시각폭>px)/2 - <위젯폭>px - 12px));
}
@media (max-width:820px){ .sheet-progress{ display:none !important; } }
```

- `right` 의 `max(8px, …)` 가 반응형을 담당한다:
  - **넓은 화면**: `calc(…)` 가 양수 → 위젯이 본문 바깥 오른쪽 여백에 온전히 들어간다(겹침 없음).
  - **여백 부족(일반 노트북, ≈1300~1620px)**: `calc(…)` 가 음수 → `8px` 로 clamp 되어 위젯이 뷰포트 오른쪽 끝에 붙고, 본문 오른쪽 끝 카드 모서리와 **일부 겹친다**(진행률 카드는 작고 우상단이라 허용). 숨기는 것보다 낫다.
  - **모바일/태블릿(`≤820px`)**: `display:none`. 활동지 본문 폼·체크 행에서 진행 상태 확인 가능하므로 정보 손실 없음(§7 — 위젯은 보조 표시).
- 위젯폭은 `210px` 권장(겹침을 줄이려 §10.1 의 220px 에서 축소), 간격 `12px`, 최소 우측 여백 `8px`.
- **최상위 `zoom` 보정**: 이 값은 문서에 확대가 없다는 전제다. `학교 웹앱`(`output/data4.html`)은 최상위 래퍼에 `zoom:1.1` 이 걸려 본문 `max-width:1080px` 가 **화면상 약 1188px** 로 보이므로, `calc` 의 본문 시각폭에 `1188px` 를 넣는다. 구현 상세는 `guide/build.md` "활동 진행률 플로팅 위젯" 절.

| 문서 유형 | 본문 시각폭 | `right` calc 기준값 |
|---|---|---|
| zoom 없음 (기준) | 1080px | `(100vw - 1080px)/2 - 210px - 12px` |
| `학교 웹앱`, `zoom:1.1` | ~1188px | `(100vw - 1188px)/2 - 210px - 12px` |

두 경우 모두 숨김 breakpoint 는 `max-width:820px` 로 동일(뷰포트 실측이므로 zoom 무관).

### 10.3 카드 스타일

- 껍데기: `background:var(--paper)`(#fffdf7) · `border:3px solid var(--ink)`(#4b3b6b) · `border-radius:12px` · `box-shadow:5px 5px 0 var(--sh)`(rgba(75,59,107,.18), **오프셋만·blur 0**) · `overflow:hidden` · `display:flex; flex-direction:column`. → §2.4 "일반 카드" 행과 동일.
- 헤더 스트립: `padding:8px 14px` · `border-bottom:3px solid var(--ink)` · `background:var(--purple)`(#d6c4f5) *또는* `var(--blue)`(#c4d8f7) · `font-family:'Silkscreen',monospace; font-size:11px` · `display:flex; justify-content:space-between; align-items:center`. → §3.5 `.card-head` 패턴.
- 본문: `padding:14px` · `display:flex; flex-direction:column; gap:10px`. (개별 margin 금지, §2.3)

### 10.4 진행 바 (§10 신규, 기존 토큰만)

- 트랙: `height:12px` · `background:#ece9f3` (§2.1 "완료 상태" 배경색 = 옅은 파스텔 트랙으로 재사용) · `border:2px solid var(--ink)` · `border-radius:999px` (§2.4 알약) · `overflow:hidden`.
- 필: `background:var(--blue-strong)`(#9db2f2) *또는* `var(--mint)`(#bfe9dd) — **단색만, 그라디언트 금지**(design.md 는 하드엣지·단색). `height:100%` · `width:<pct>%` (인라인 바인딩) · `transition:width .3s ease` (§10.5).
- 상태색이 필요하면(예: 미시작 0% 강조, 완료 100% 강조) §2.1 상태색 표를 따른다. 임의 색 추가 금지.
- 테두리 `2px` 는 §2.4 "내부 구분선/소형 요소" 스케일. 껍데기(3px)보다 얇게 두어 위계를 만든다.

### 10.5 숫자·문구 표기 (§2.2)

| 요소 | 서체 | 크기 | 색 |
|---|---|---|---|
| 라틴 라벨 `PROGRESS` / `WORKSHEET` | Silkscreen | 11px / (우측 10px, `opacity:.75`) | `var(--ink)` |
| 한글 제목 "활동 진행률" | **CookieRun 700** (Silkscreen 금지 — §2.2 한글 규칙) | 16px (subtitle) | `var(--ink)` |
| 큰 수치 `n%` 또는 `n / 7` | CookieRun 700 + `font-variant-numeric:tabular-nums` | 26px | `var(--ink)` |
| 보조 문구 (`3 / 7 완료`, `저장됨` 등) | Maplestory 300 | 12–13px | `var(--muted)` (#8b7cb8) |
| 제출 완료 표기 `✓ 제출 완료` | CookieRun 700, 알약(`border-radius:999px; padding:2px 10px`) | 12px | 배경 `#ece9f3` · 글자 `#8a82a6` (§2.1 완료 상태색) |

### 10.6 인쇄 (§6)

```css
@media print{ .sheet-progress{ display:none !important; } }
```

조작·보조 플로팅 UI이므로 인쇄에서 완전히 숨긴다.

### 10.7 모션 (§5)

- 허용 트랜지션은 **필의 `width` 하나뿐**. 다른 애니메이션(floaty 등) 금지.

```css
@media (prefers-reduced-motion:reduce){ .sheet-progress .fill{ transition:none !important; } }
```

### 10.8 접근성 (§7)

- 상태는 **색 + 글자 둘 다**: 진행 바(색/길이) + `n / 7`·`n%` 텍스트를 항상 함께 노출.
- 트랙에 `role="progressbar"`, `aria-valuenow`(완료 수 또는 %), `aria-valuemin="0"`, `aria-valuemax`(7 또는 100), `aria-valuetext="7개 중 3개 완료"` 형태의 텍스트 병기. 최소한 인접 텍스트로 값을 읽을 수 있어야 한다.
- 위젯은 정보 표시 전용이라 인터랙티브 요소가 없다. 만약 링크/버튼을 넣는다면 `:focus-visible{outline:3px solid var(--pink-edge);outline-offset:2px}` 유지.
- 파스텔 위 흰 글자 금지(§7). 필 위에 글자를 얹지 않는다(수치는 트랙 밖에 별도 표기).
- 좁은 화면에서 위젯이 사라져도 본문 폼으로 동일 정보 확인 가능(§10.2).

### 10.9 복붙용 스니펫

```css
/* §10 플로팅 위젯 — 활동 진행률 (수업 활동지 탭 전용) · 왼쪽 여백 컴팩트 판 */
.sheet-progress{
  position:fixed;
  top:96px;                          /* 타이틀바 아래 — 학교 웹앱은 116px */
  left:max(8px, calc((100vw - 1080px)/2 - 120px - 12px));  /* zoom:1.1 문서면 1080→1188 */
  width:120px;                       /* left calc 의 위젯폭 항과 동일 */
  z-index:5;
  display:flex;flex-direction:column;
  background:var(--paper);           /* #fffdf7 */
  border:3px solid var(--ink);       /* #4b3b6b */
  border-radius:12px;
  box-shadow:5px 5px 0 var(--sh);    /* rgba(75,59,107,.18) 오프셋만·blur 0 */
  overflow:hidden;
}
.sheet-progress .sp-head{
  padding:6px 10px;border-bottom:3px solid var(--ink);
  background:var(--purple);          /* #d6c4f5 */
  font-family:'Silkscreen',monospace;font-size:10px;text-align:center;
}
.sheet-progress .sp-body{padding:10px;display:flex;flex-direction:column;gap:7px;}
.sheet-progress .sp-title{                 /* 한글 제목 — Silkscreen 금지 */
  font-family:'CookieRun',sans-serif;font-weight:700;font-size:13px;color:var(--ink);line-height:1.3;
}
.sheet-progress .sp-count{display:flex;align-items:baseline;gap:4px;}
.sheet-progress .sp-count .big{
  font-family:'CookieRun',sans-serif;font-weight:700;font-size:20px;
  font-variant-numeric:tabular-nums;color:var(--ink);
}
.sheet-progress .sp-count .sub{
  font-family:'Maplestory',sans-serif;font-weight:300;font-size:11px;color:var(--muted);
}
.sheet-progress .track{
  height:10px;border:2px solid var(--ink);border-radius:999px;overflow:hidden;
  background:#ece9f3;                /* §2.1 완료 상태 배경 = 옅은 트랙 */
}
.sheet-progress .fill{
  height:100%;width:0%;              /* 구현: width:<pct>% 인라인 바인딩 */
  background:var(--blue-strong);     /* #9db2f2 단색 — 그라디언트 금지 */
  transition:width .3s ease;
}
.sheet-progress .sp-done{             /* 제출 완료 보조 표기 (§2.1 완료 상태색) */
  align-self:flex-start;padding:2px 8px;border-radius:999px;
  background:#ece9f3;color:#8a82a6;
  font-family:'CookieRun',sans-serif;font-weight:700;font-size:11px;
}
@media (max-width:820px){ .sheet-progress{ display:none !important; } }  /* 모바일/태블릿만 숨김 (§10.2) */
@media print{ .sheet-progress{ display:none !important; } }
@media (prefers-reduced-motion:reduce){ .sheet-progress .fill{ transition:none !important; } }
```

```html
<aside class="sheet-progress" aria-label="활동 진행률">
  <div class="sp-head"><span>PROGRESS</span><span class="r">WORKSHEET</span></div>
  <div class="sp-body">
    <div class="sp-title">활동 진행률</div>
    <div class="sp-count">
      <span class="big">43%</span>
      <span class="sub">3 / 7 완료</span>
    </div>
    <div class="track" role="progressbar"
         aria-valuenow="3" aria-valuemin="0" aria-valuemax="7"
         aria-valuetext="7개 중 3개 완료">
      <div class="fill" style="width:43%"></div>
    </div>
    <div class="sp-note">입력하면 자동으로 반영돼요</div>
    <!-- 제출 완료 시에만 -->
    <span class="sp-done">✓ 제출 완료</span>
  </div>
</aside>
```
