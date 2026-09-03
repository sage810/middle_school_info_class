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
