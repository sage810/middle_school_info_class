# build.md — `output/data4.html` 빌드(구현) 노트

`guide/design.md` 가 "무엇을 어떻게 보이게 할지"(시각 계약)라면, 이 문서는 그 계약을
**`output/data4.html` 이라는 한 파일에서 실제로 어떻게 구현했는가**를 기록한다.

## 개요 — data4.html 이 어떤 파일인가

- `input/design/project/학교 웹앱.dc.html`(= design.md 의 원본 핸드오프)의 **구현본**.
- 런타임: `output/support.js` + 파일 하단의 `<script type="text/x-dc" data-dc-script>` 안
  `class Component extends DCLogic { state = {…}; renderVals() {…} }`.
- 마크업: `<x-dc>` 안에 `<helmet>`(→ `<head>` 로 이동) + 본문 템플릿.
  바인딩은 `{{ 표현식 }}`, 분기는 `<sc-if value="{{ bool }}">`, 반복은 `<sc-for list="{{ arr }}" as="x">`.
- 최상위 본문 래퍼에 `zoom:1.1` 이 걸려 있고, 그 안에 `max-width:1080px; margin:0 auto` 본문이 있다.
- 탭 4개(`state.tab`): `rules` / `time` / `meal` / `sheet`. 시간표·급식 탭은 NEIS 실데이터
  (인라인 스냅샷 + `scripts/fetch-neis.ps1` → `build-webapp-data.ps1`).
- **앞으로 data4.html 을 수정할 때마다 이 문서에 절(##)을 이어 붙인다.**

---

## 활동 진행률 플로팅 위젯 (design.md §10)

### 근거
design.md §10 (10.1~10.9). 수업 활동지 탭에서만, 가운데 본문 바깥 오른쪽 여백에
"활동 진행률" 카드를 뷰포트 고정으로 띄운다. §10.9 의 복붙용 CSS/HTML 스니펫을 기준으로 구현.

### 바꾼 위치 (data4.html)

| 부분 | 위치(대략) | 내용 |
|---|---|---|
| `<style>` (helmet) | 27–85행 부근 | `.sheet-progress` 및 하위 클래스(`.sp-head/.sp-body/.sp-title/.sp-count .big/.sub/.track/.fill/.sp-note/.sp-done`) + 3개 `@media`. design.md §2 토큰을 **리터럴 hex**(이 파일은 CSS 변수 미사용)로 바꿔 넣음. |
| 위젯 마크업 | `</x-dc>` **바로 앞**(852–868행 부근) | §10.9 HTML 구조를 클래스 기반으로. `zoom:1.1` 래퍼 **밖**(`<x-dc>` 직속)에 마운트. |
| `renderVals()` | 1410–1420행 부근 | 7항목 진행률 집계 + 반환값 추가. |
| (제거) | 옛 `<sc-if isSheet>` 내부 | 이전 반복에서 인라인 스타일로 넣었던 위젯 마크업을 삭제하고 위 위치로 이설. |

### `<style>` 에 추가한 클래스 (요지)
- `.sheet-progress`: `position:fixed; top:116px; width:120px; z-index:5; left:max(8px, calc((100vw - 1188px)/2 - 120px - 12px)); background:#fffdf7; border:3px solid #4b3b6b; border-radius:12px; box-shadow:5px 5px 0 rgba(75,59,107,.18); overflow:hidden; display:flex; flex-direction:column`.  ← **왼쪽 여백 + 컴팩트(120px)** (아래 "왼쪽 이동·축소" 참고). `.sp-head` `text-align:center`(보조 라벨 `.r` 제거), `.sp-note` 제거, big 20px, 카운트 `n/7`.
- `.sp-head`: `padding:8px 14px; border-bottom:3px solid #4b3b6b; background:#d6c4f5; Silkscreen 11px; space-between`. `.sp-head .r`: `font-size:10px; opacity:.75`.
- `.sp-body`: `padding:14px; flex column; gap:10px` (개별 margin 없음).
- `.sp-title`: CookieRun 700 16px `#4b3b6b` (Silkscreen 금지).
- `.sp-count .big`: CookieRun 700 26px `font-variant-numeric:tabular-nums` `#4b3b6b`.  `.sp-count .sub`: Maplestory 300 13px `#8b7cb8`.
- `.track`: `height:12px; border:2px solid #4b3b6b; border-radius:999px; overflow:hidden; background:#ece9f3`.
- `.fill`: `height:100%; background:#9db2f2`(단색·그라디언트 없음) `transition:width .3s ease`. **`width` 만** 인라인 바인딩.
- `.sp-note`: Maplestory 300 12px `#8b7cb8`.  `.sp-done`: 알약 `background:#ece9f3; color:#8a82a6; border-radius:999px; padding:2px 10px; CookieRun 700 12px`.
- `@media (max-width:820px){ .sheet-progress{ display:none !important } }` — 모바일/태블릿만 숨김 (아래 "가시성 정정" 참고)
- `@media print{ .sheet-progress{ display:none !important } }`
- `@media (prefers-reduced-motion:reduce){ .sheet-progress .fill{ transition:none !important } }`

### `<sc-if isSheet>` 밖 마크업 (요지)
`</x-dc>` 바로 앞에:
```
<div class="sheet-progress" aria-label="활동 진행률" style="display:{{ sheetWidgetDisplay }}">
  <div class="sp-head"><span>PROGRESS</span><span class="r">WORKSHEET</span></div>
  <div class="sp-body">
    <div class="sp-title">활동 진행률</div>
    <div class="sp-count"><span class="big">{{ sheetPct }}%</span><span class="sub">{{ sheetDone }} / {{ sheetTotal }} 완료</span></div>
    <div class="track" role="progressbar" aria-valuemin="0" aria-valuemax="{{ sheetTotal }}"
         aria-valuenow="{{ sheetDone }}" aria-valuetext="{{ sheetAria }}">
      <div class="fill" style="{{ sheetFillStyle }}"></div>
    </div>
    <div class="sp-note">입력하면 자동으로 반영돼요</div>
    <sc-if value="{{ sheetSaved }}" hint-placeholder-val="{{ false }}">
      <span class="sp-done">✓ 제출 완료</span>
    </sc-if>
  </div>
</div>
```
- 수치(`{{ sheetPct }}%`, `{{ sheetDone }} / {{ sheetTotal }}`)는 **트랙 밖**에만 표기(§10.8 — 필 위 글자 금지).
- 제출 완료 알약은 `<sc-if sheetSaved>` 로만 노출. `saved` 는 진행률 집계에 미포함.

### `renderVals()` 에 추가한 값과 7항목 공식
```js
const sheetChecklist = [
  !!(s.fName && s.fName.trim()),   // 1. 이름
  !!(s.a1 && s.a1.trim()),         // 2. 활동1 서술답
  !!s.checks[0], !!s.checks[1], !!s.checks[2], !!s.checks[3],   // 3~6. 데이터 분석 4단계 체크
  !!(s.reflect && s.reflect.trim())// 7. 수업 소감
];
const sheetDone  = sheetChecklist.filter(Boolean).length;   // 완료 개수
const sheetTotal = sheetChecklist.length;                   // 7
const sheetPct   = Math.round(sheetDone / sheetTotal * 100);
const sheetFillStyle    = 'width:' + sheetPct + '%';        // 색·높이·transition 은 .fill 클래스
const sheetSaved        = !!s.saved;                        // 완료 알약 표시용(집계 X)
const sheetAria         = sheetTotal + '개 중 ' + sheetDone + '개 완료';
const sheetWidgetDisplay= s.tab === 'sheet' ? 'flex' : 'none';
// return { … sheetDone, sheetTotal, sheetPct, sheetFillStyle, sheetSaved, sheetAria, sheetWidgetDisplay }
```
`checks` 토글·`fName`/`a1`/`reflect` 의 `onChange` 는 이미 `setState`→재렌더 하므로 진행률이 자동 갱신된다.
기존 state·다른 탭·`save`/`reset` 은 건드리지 않았다.

### zoom 보정 — 택한 방법과 이유
- 문제: 본문 래퍼 `zoom:1.1`. `zoom` 은 Chrome 에서 그 안의 `position:fixed` 요소의 좌표계·`vw`·`px`
  를 1.1배로 부풀려, `right`/`top`/`width` 가 어긋나고 본문과 겹친다.
- 시도 1: `.sheet-progress{ zoom:calc(1/1.1) }` 로 상쇄 → 헤드리스 스크린샷에서 우측이 잘림. 폐기.
- **채택**: 위젯을 **`zoom:1.1` 래퍼 밖**(`<x-dc>` 직속, `</x-dc>` 바로 앞)에 마운트.
  `position:fixed` 가 실제 뷰포트 기준으로 계산된다.
- 추가 보정: 본문(`max-width:1080px`)이 `zoom:1.1` 로 **시각적으로 1188px(=1080×1.1)** 폭이므로,
  `right` 계산의 본문폭 기준을 `1080px` → **`1188px`** 로 바꿈:
  `right:max(16px, calc((100vw - 1188px)/2 - 220px - 20px))`.
  이 값이면 뷰포트가 넓어져도 위젯과 (시각) 본문 우측 끝 사이 간격이 항상 ~20px 로 유지된다.
### 가시성 정정 (2026-09-03)
- 처음엔 "여백 부족하면 숨김" + breakpoint `max-width:1700px` 로 구현 → **1366·1440·1536·1600
  같은 일반 노트북 전부에서 위젯이 안 보임**(사용자 보고 "진행률 안보이는데?"). 폐기.
- **현재**: 숨기지 않고 **본문 오른쪽 끝에 살짝 겹쳐서라도 보여준다**. `right:max(8px, calc(…))`
  가 알아서 처리 — 넓으면 여백에 온전히, 여백 부족하면 `8px` clamp 로 오른쪽 끝에 붙어 본문
  카드 우상단 모서리와 일부 겹침(작은 카드라 허용). 폭도 220→**210px**, 간격 20→**12px**,
  우측 최소 16→**8px** 로 축소해 겹침 최소화.
- `@media` 숨김 breakpoint 는 `max-width:820px`(모바일/태블릿)만. 그 아래에선 활동지 본문
  폼·체크로 상태 확인 가능(§7). 자세한 규칙은 design.md §10.2.

### 왼쪽 이동·축소 (2026-09-03)
- 사용자 요청: "진행바를 **왼쪽 여백**으로, **레이아웃과 겹치지 않게 크기 변경**".
- `right:` → `left:`. 폭 210→**120px**(컴팩트), 헤더 보조 라벨(`.r` "WORKSHEET")과 하단 안내문
  (`.sp-note` "입력하면 자동으로 반영돼요") 제거, big 26→20px, 카운트 `n / 7 완료` → `n/7`, 패딩·gap 축소.
- `left:max(8px, calc((100vw - 1188px)/2 - 120px - 12px))`. 시각 본문폭 1188 기준:
  - **뷰포트 ≈1470px 이상**: 왼쪽 여백에 온전히 들어가 **본문과 겹침 0**.
  - 1300~1470px: 창 왼쪽 테두리 쪽과만 소폭 겹침(내용 카드는 안 가림).
  - ~1280px 이하: 제목/첫 카드 좌상단과 겹침 → 그보다 좁으면 `@media (max-width:820px)` 로 숨김.
- 헤드리스 확인: 1920·1440 겹침 없음 / 1280 제목 일부 겹침 / ≤820 숨김.

### 탭 게이팅
`<sc-if isSheet>` 밖에 있으므로 sc-if 로 못 감싼다. 대신 `renderVals` 의
`sheetWidgetDisplay`(`s.tab==='sheet' ? 'flex' : 'none'`)를 위젯 루트의 인라인 `display` 로 바인딩.
`@media` 의 `display:none !important` 는 인라인보다 우선하므로 좁은 화면·인쇄에서는 그대로 숨는다.

### 재현 체크리스트
1. `output/data4.html` 을 데스크톱/노트북 뷰포트(≥821px)에서 열고 **수업 활동지** 탭 → **왼쪽**에 컴팩트 카드가 뜬다. ≈1470px+ 는 본문과 겹침 0, 그 아래는 창 왼쪽 테두리와 소폭 겹침.
2. 페이지를 아래로 스크롤 → 카드가 뷰포트 좌상단에 그대로 고정(`position:fixed`).
3. 이름/활동1 답/4단계 체크/소감을 채우면 `n%`·`n / 7`·바가 즉시 갱신(최대 7/7 = 100%).
4. "제출하기" 누르면 `✓ 제출 완료` 알약이 추가로 표시(진행률 수치는 그대로).
5. 뷰포트를 820px 이하로 좁히면 카드가 사라진다(본문 폼으로 진행 상태 확인 가능).
6. 다른 탭(이용 규칙/시간표/급식)으로 전환하면 카드가 사라진다.
7. 인쇄 미리보기(Ctrl+P)·`prefers-reduced-motion` 에서 각각 숨김·트랜지션 제거.

---

## 만화 판매량 표 복사 방지 (ACTIVITY_5)

### 목적
수업 활동지 탭 ACTIVITY_5(`속성(feature) 이해하기`)의 표 **"2026년 상반기 일본 만화 판매량 TOP 10"** 을
학생이 드래그로 긁어 복사하지 못하게 한다. (표 자체는 그대로 읽을 수 있고, 가로 스크롤도 유지.)

### 바꾼 위치 (data4.html)
| 부분 | 위치(대략) | 내용 |
|---|---|---|
| `<style>` (helmet) | `.sheet-progress` 미디어쿼리 아래 | `.no-copy { user-select:none; -webkit-user-select:none; -ms-user-select:none; }` 1줄 추가 |
| 표 컨테이너 div | ACTIVITY_5, `minWidth:460px …` 인라인 style div (약 733행) | `id="mangaTable" class="no-copy"` 부여. **인라인 style·`overflowX:auto` 래퍼는 그대로.** |
| `componentDidMount()` | `loadMeal(new Date())` 다음 | `['copy','cut','contextmenu','dragstart']` 를 **`document`** 에 위임 등록, `e.target.closest('#mangaTable')` 인 경우에만 `e.preventDefault()` |

### 방식과 이유
- **선택 자체 차단**: `.no-copy` 의 `user-select:none` → 표 안 텍스트가 드래그로 선택되지 않으므로 복사할 내용이 안 생긴다. (시각 효과 없음.)
- **이벤트 차단(방어선 추가)**: 키보드 Ctrl+C/X, 우클릭 메뉴, 셀을 밖으로 끌어놓기(dragstart)까지 막는다.
- **왜 `document` 위임인가**: 활동지 탭은 `<sc-if value="{{ isSheet }}">` 로 감싸여 있고 support.js 의 `walkIf` 는
  조건이 false면 서브트리를 **아예 렌더하지 않는다**(`v ? <Fragment> : null`). 기본 탭이 `rules` 라
  `componentDidMount` 시점에는 `#mangaTable` DOM 이 없다 → `getElementById('mangaTable')` 는 `null`.
  그래서 요소에 직접 `addEventListener` 하지 않고 `document` 에 한 번만 위임 등록하고
  핸들러에서 `e.target.closest('#mangaTable')` 로 그 표 안에서 발생한 이벤트만 막는다(마운트 타이밍 무관, 다른 표·입력칸엔 영향 없음).
- 인라인 `oncopy=` 속성 대신 `addEventListener`(support.js 런타임 규칙).

### 대상 id / 클래스
- id: `mangaTable` (표 컨테이너 div, `overflowX:auto` 스크롤 래퍼의 자식)
- class: `no-copy` (= `user-select:none`)

### 재현 체크리스트
1. 활동지 탭 → ACTIVITY_5 표에서 텍스트를 드래그해도 선택 안 됨.
2. `getComputedStyle(document.getElementById('mangaTable')).userSelect === 'none'`.
3. 표 안에서 `new Event('copy'|'cut'|'contextmenu'|'dragstart',{cancelable:true})` 를 dispatch → `dispatchEvent` 가 `false`(= preventDefault 됨).
4. 표를 감싼 `overflowX:auto` 래퍼는 좁은 뷰포트에서 여전히 가로 스크롤(`scrollWidth > clientWidth`).
5. 다른 표·입력칸·탭·진행률 위젯은 변화 없음, 표 테두리·색·레이아웃도 동일.

---

## activity accent 색 확장 (salmon·olive 추가)

### 바꾼 위치 (data4.html)
- `SUB_PALETTE` 선언 **바로 다음**(약 993~998행): 새 상수 `SHEET_ACT_ACCENT` 추가.
  ```js
  var SHEET_ACT_ACCENT = ['#a9dce4','#c4d8f7','#fbe6a2','#d6c4f5','#bfe9dd','#eec6ea','#f7bfb2','#e3e0b0'];
  ```
- 기존 activity 카드 헤더 색은 카드마다 인라인 `background:` 로 **하드코딩**되어 있고(1 `#a9dce4` · 2 `#c4d8f7` · 3 `#fbe6a2` · 4 `#d6c4f5` · 5 `#bfe9dd` · 6 `#eec6ea` · 7 `#f7bfb2`), 그대로 **미변경**.
- ACTIVITY_7 카드는 이미 존재하며 헤더·번호 배지가 salmon `#f7bfb2` 로 하드코딩되어 있어 손대지 않음.
- ACTIVITY_8 카드는 없음 — **새로 만들지 않음**(색 등록만).

### 순환 (design.md §4.1 과 일치, 8색 후 루프)
| N | 이름 | hex |
|---|---|---|
| 1 | mint | `#a9dce4` |
| 2 | blue | `#c4d8f7` |
| 3 | yellow | `#fbe6a2` |
| 4 | purple | `#d6c4f5` |
| 5 | mint | `#bfe9dd` |
| 6 | lilac | `#eec6ea` |
| 7 | salmon | `#f7bfb2` |
| 8 | olive | `#e3e0b0` |

`ACTIVITY_N` 헤더 색 = `SHEET_ACT_ACCENT[(N-1) % 8]`. 다음 활동 카드(ACTIVITY_8~) 추가 시 이 상수에서 색을 고른다.

### 안 건드린 것
기존 6색·레이아웃·진행률 위젯 색(`#d6c4f5`/`#9db2f2`/`#ece9f3`), `SUB_PALETTE`, `SUB_COLOR(_EXT)`.

---

## 순서 배열 드래그 활동 (PREVIOUSLY 카드)

### 목적
수업 활동지 탭 PREVIOUSLY 카드에 "데이터로 문제를 해결하는 4단계"의 **순서 자체**를 학생이 복원하는
선행 조직자(advance organizer) 활동을 얹는다. 뒤섞인 칩 4장(문제 정하기 / 데이터 수집·특성 파악 /
데이터 분석하기 / 결과 해석·공유)을 번호 칸 ①~④ 로 끌어다 놓고 `✅ 순서 확인` 으로 채점한다.
spec `spec/data4-4steps-sequencing.activity.md` · brief `brief/data4-4steps-sequencing.build-brief.md` ·
design.md **§11**(순서 배열 / 드래그 슬롯 컴포넌트) 계약을 그대로 구현.

### 바꾼 위치 (data4.html)
| 부분 | 행 범위(수정 후) | 내용 |
|---|---|---|
| `<style>` (helmet) | 93–165 | design.md §11.2 `.seq-*` 스니펫 이식(`.seq-activity/.seq-head/.seq-tag/.seq-title/.seq-hint/.seq-tray/.seq-chip/.seq-rows/.seq-row/.seq-num/.seq-slot/.seq-mark/.seq-controls/.seq-check-btn/.seq-reset-btn/.seq-result` + `:focus-visible` + `prefers-reduced-motion`). 색·px 는 §2 토큰만, 테두리는 모든 상태에서 `#4b3b6b`. |
| `<style>` (helmet) | 166–179 | **전역 `@media print` 신설**(이 파일엔 없던 블록). |
| PREVIOUSLY 카드 본문 | 613–649 (약 36줄 추가) | NOTE 박스(`#fbe6a2`) `</div>` 직후, 카드 본문 래퍼 안. `2px dashed rgba(75,59,107,.28)` 구분선 1줄 + `.seq-activity` 블록(헤더 `ORDER`+제목, 발문 `<p>`, `#seqTrayPrev` 칩 4개, `.seq-rows` 슬롯 4칸, `.seq-controls` 확인/리셋/결과). 기존 복습 불릿 3개·NOTE 는 유지. |
| `</body>` 앞 | 1640–1909 (약 270줄, 새 `<script>` 1개) | 순서 배열 엔진(IIFE). x-dc `<script type="text/x-dc">` 와 별개인 순수 vanilla `<script>`. DClogic 클래스·`renderVals`·`componentDidMount` 는 건드리지 않음. |
| 1074행 `closest('#mangaTable')` | (불변) | dragstart 위임 스코프를 넓히지 않음 — 넓히면 `.seq-chip` 드래그가 `preventDefault` 로 막힌다. |

### 방식과 이유
- **엔진 신규**: data4 에는 data3 계열 dnd 엔진(CSS/JS)이 전혀 없어 CSS·마크업·JS 를 새로 넣었다.
  다음 순서 배열 활동은 `.seq-*` 마크업만 추가하면 이 엔진이 그대로 배선한다(`.seq-activity` 단위로 스코프).
- **document 위임 (activity guide §1-8 패턴)**: PREVIOUSLY 카드는 `<sc-if value="{{ isSheet }}">` 안이라
  다른 탭에선 렌더되지 않고 탭 전환마다 언마운트/재마운트된다. 그래서 칩·슬롯·버튼에 직접
  `addEventListener` 하지 않고 `document` 에 `click`/`keydown`/`dragstart`·`dragover`·`dragenter`·
  `dragleave`·`dragend`·`drop` 을 한 번만 위임 등록하고, 핸들러에서 `e.target.closest('.seq-activity …')`
  로 이 활동 안 이벤트만 처리한다.
- **상태 보관 = DOM-only + 매 마운트 재init (spec §7 대안 B)**: 칩 위치는 DOM(어느 슬롯/트레이의
  자식인가)만으로 표현한다. 새 `.seq-activity` 노드가 나타나면 `MutationObserver` → `scan()` →
  `initActivity()` 가 `data-seq-init="1"` 이 없을 때 1회 배선(슬롯 `aria-label` 동기화, 트레이 `is-empty`).
  칩 초기 뒤섞임 `["step3","step1","step4","step2"]` 는 **정적 마크업**에 그대로 박아 두어 JS 실패·인쇄에도
  순서가 남는다. React(support.js) 재렌더는 정적 서브트리를 건드리지 않으므로 60초 `now` tick 에도
  배치가 유지되고, **탭 전환 시에만** 초기 뒤섞임으로 리셋된다(spec 이 감수한 트레이드오프).
- **마우스 드래그**: HTML5 DnD. 찬 슬롯에 놓으면 두 칩 자리 교환(다른 슬롯에서 온 경우) 또는 기존 칩을
  트레이로 되돌림(트레이에서 온 경우). 슬롯 밖(트레이)에 놓으면 칩은 트레이로 복귀. `zoom:1.1` 대응으로
  좌표 산술 없이 **이벤트 타깃(`closest`)만** 사용.
- **터치/키보드 대체**: 칩(`<button type="button" aria-pressed>`) 클릭 = 선택 토글(`.is-on`), 선택 상태에서
  슬롯 클릭 = 배치, 빈손으로 찬 슬롯 클릭 = 칩 회수, 트레이 클릭 = 선택 칩 회수. 슬롯은
  `role="button" tabindex="0"` 이라 Enter/Space 를 수동 처리, Esc 는 어디서나 선택 해제. 칩은 네이티브
  버튼 클릭 경로를 그대로 쓴다(Space/Enter 이중 처리 방지).
- **채점(`✅ 순서 확인`)**: 슬롯 4칸이 다 안 차면 `incomplete` 문구만. 다 차면 칸별로
  `slot.dataset.answer === chip.dataset.answerKey` 비교 → `.is-correct`(`#d8f0c4`+`.seq-mark ✓`) /
  `.is-wrong`(`#f7bfb2`+`.seq-mark ✗`), `#seqResultPrev`(`role="status"`)에 `"4칸 모두 정답! "` /
  `"4칸 중 {n}칸 정답. "` / `"4칸 중 0칸 정답. "` + spec §4 피드백 문구. 정답 배열은 텍스트로 노출하지 않음.
- **리셋(`🔄 다시 섞기`)**: 모든 슬롯 비우고 칩을 트레이로 복귀, Fisher–Yates 로 **정답과 다른** 순열 재배치,
  채점 클래스·결과 문구·선택 상태 초기화.
- **진행률 비포함**: spec §7-1 / design.md §11.6 대로 `renderVals` 의 `sheetChecklist`(7항목)에 넣지 않음.
  선행 조직자라 완료율 대상 아님. 넣으려면 엔진이 결과를 `state` 에 write + 체크리스트 원소 추가 필요.

### 새 클래스 / id
- 클래스: `.seq-activity` · `.seq-head` · `.seq-tag` · `.seq-title` · `.seq-hint` · `.seq-tray`
  (`.is-over`/`.is-empty`) · `.seq-chip`(`.is-on`/`.is-dragging`) · `.seq-rows` · `.seq-row` · `.seq-num` ·
  `.seq-slot`(`.is-over`/`.is-filled`/`.is-correct`/`.is-wrong`) · `.seq-mark` · `.seq-controls` ·
  `.seq-check-btn` · `.seq-reset-btn` · `.seq-result`
- id: `seqTrayPrev`(트레이) · `seqSlotPrev1`~`seqSlotPrev4`(슬롯) · `seqResultPrev`(결과, `role="status"`)
- data 속성: 칩 `data-value="seq-prev-stepN"` / `data-answer-key="stepN"`, 슬롯 `data-slot` /
  `data-check-group="seqTrayPrev"` / `data-answer="stepN"`, 버튼 `data-target-tray="seqTrayPrev"` /
  `data-result-id="seqResultPrev"`, 활동 노드 런타임 플래그 `data-seq-init="1"`
- 정답(슬롯→칩): `seqSlotPrev1→step1` · `seqSlotPrev2→step2` · `seqSlotPrev3→step3` · `seqSlotPrev4→step4`
  (유일 해, 초기 뒤섞임 `step3, step1, step4, step2`)

### `@media print` 신설 내용 (data4.html 에 전역 print 블록이 없었음)
```css
@media print {
  @page { margin: .5cm; }
  * { -webkit-print-color-adjust: exact; print-color-adjust: exact;
      animation: none !important; transition-duration: 0s !important; }
  * { box-shadow: none !important; }                 /* 잉크 절약 (design.md §6) */
  figure, table, .card, .seq-activity { break-inside: avoid; }
  .seq-tray { display: none; }                        /* 미배치 칩 풀 숨김 */
  .seq-slot { border: 2px solid #4b3b6b; background: #fff; }
  .seq-slot.is-correct, .seq-slot.is-wrong { background: #fff; }   /* 색 → 아이콘/텍스트 */
  .seq-slot.is-correct .seq-mark::after { content: ' ✓ 정답'; }
  .seq-slot.is-wrong .seq-mark::after { content: ' ✗ 다시'; }
  .seq-num { background: #d6c4f5; }                   /* 색 배지 정보위계 유지 */
}
```
- `.sheet-progress` 전용 `@media print`(위젯 숨김, 27~92행)는 그대로 두고 이 전역 블록을 추가로 신설.

### 재현 체크리스트
1. 수업 활동지 탭 → PREVIOUSLY 카드 맨 아래, NOTE 박스 밑에 `2px dashed` 구분선 + `ORDER` 라벨 +
   "오늘 쓸 4단계, 순서부터 맞춰 보기" 제목 + 뒤섞인 칩 4장(첫 칩 = "데이터 분석하기") + ①~④ 빈 칸이 보인다.
2. 칩 클릭 → 보라(`#d6c4f5`) 강조 + `aria-pressed="true"`. 이어서 빈 칸 클릭 → 칩이 그 칸으로 이동,
   칸이 솔리드(`.is-filled`)로 바뀌고 슬롯 `aria-label` 이 "① 자리: 데이터 분석하기" 로 갱신.
3. 마우스로 칩을 칸에 드래그해도 배치됨. 찬 칸끼리 드래그하면 두 칩이 교환됨. 칸의 칩을 트레이로
   드래그하면 복귀. 트레이가 비면 `EMPTY` 표시.
4. 정답 순서(문제 정하기 / 데이터 수집·특성 파악 / 데이터 분석하기 / 결과 해석·공유)로 채운 뒤
   `✅ 순서 확인` → 4칸 모두 `#d8f0c4` + `✓`, `#seqResultPrev` = "4칸 모두 정답! …".
5. 일부만 맞추고 확인 → 맞은 칸 초록+`✓`, 틀린 칸 `#f7bfb2`+`✗`, 결과 = "4칸 중 n칸 정답. …"(정답 배열은
   노출 안 됨). 빈 칸이 있으면 "빈 칸이 있어요…" 만 표시(채점 안 함).
6. `🔄 다시 섞기` → 슬롯 비고 트레이가 정답과 다른 새 순열로 재배치, 채점 색/결과 문구/선택 초기화.
7. 키보드: Tab 으로 칩·슬롯·버튼 이동 시 `:focus-visible` = `outline:3px solid #ee9dbf; outline-offset:2px`.
   칩에서 Enter/Space = 선택, 슬롯에서 Enter/Space = 배치/회수, Esc = 선택 해제.
8. 다른 탭으로 갔다가 활동지 탭으로 복귀 → 활동이 초기 뒤섞임으로 리셋(정적 마크업 재마운트, 의도된 동작).
9. Ctrl+P 인쇄 미리보기 → `.seq-tray` 숨김, 슬롯은 흰 배경 + `2px` 검정 테두리, 채점 칸은
   `✓ 정답` / `✗ 다시` 텍스트, 번호 배지 `#d6c4f5` 유지, `.seq-activity` 가 페이지 경계에서 안 쪼개짐.
10. ACTIVITY_5 `#mangaTable` 복사 방지·시간표·급식·진행률 위젯 등 기존 기능은 변화 없음.

### 검증 결과 (조립 시점)
- 새 `<script>` 블록: 중괄호 72/72 · 소괄호 250/250 · 대괄호 10/10 · 백틱 0, 구문 오류 없음
  (Microsoft.JScript 컴파일: `document`/`MutationObserver` 미정의 경고만 — 브라우저 전역이라 정상).
- 태그 델타: `<div>`/`</div>` 426/426 균형. `<script>`/`</script>` 새로 1쌍 추가.

