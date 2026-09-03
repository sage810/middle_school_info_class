# 신현중학교 컴퓨터실 활동지 — 활동 유형 가이드 (AI 에이전트용)

이 문서는 새로운 학습 활동을 추가하려는 AI 에이전트를 위한 기술 참고 문서입니다. 사람이 아니라 다른 AI가 이 파일을 이어받아 작업할 것을 가정하고, 코드 패턴·클래스 이름·주의사항을 구체적으로 적었습니다.

## 0. 파일 구조와 전제 조건

- **단일 파일(self-contained) HTML.** `<style>` 전체가 `<head>` 안 한 블록, `<script>` 전체가 `</body>` 직전 한 블록입니다. 이 파일은 구글 사이트(Google Sites)의 "삽입할 코드" 임베드 박스에 통째로 붙여넣기 때문에, 외부 CSS/JS 파일 분리나 상대경로 참조를 쓸 수 없습니다.
- **이미지는 반드시 base64 data URI로 삽입**합니다 (`<img src="data:image/png;base64,...">`). 외부 이미지 호스팅에 의존하면 안 됩니다.
- **teacher 변형 파일**(`..._teacher.html`)이 항상 짝으로 존재합니다. 내용은 완전히 동일하고, 차이는 `.topbar`와 `.progress-row`의 `position` 값뿐입니다 (`sticky` → `static`). 학생용 파일을 수정했다면 반드시 교사용 파일도 동일하게 재생성(복사 + 두 곳의 sticky→static 치환)해야 두 파일이 어긋나지 않습니다.
- **탭 구조**: `#tab-worksheet`(수업 활동지), `#tab-rules`(이용 수칙), `#tab-timetable`(시간표), `#tab-meal`(오늘의 급식) 등. 새 활동은 대부분 `#tab-worksheet` 안, `<!-- ▼▼▼ ACTIVITY-CONTENT-START ▼▼▼ -->` ~ `<!-- ▲▲▲ ACTIVITY-CONTENT-END ▲▲▲ -->` 마커 사이의 `section-block` 안에 들어갑니다. 이 마커는 파일 자체 주석에 "그대로 보존할 것"이라고 적혀 있으므로 삭제하지 않습니다.
- **채점/진행률/자동저장은 모두 이미 만들어진 공용 시스템**을 씁니다. 새 활동을 만들 때 이 시스템에 올라타도록 마크업 규칙(아래 1장 참고)을 지키기만 하면, 자동저장·진행률 표시·PDF 인쇄가 자동으로 같이 동작합니다. 이 규칙을 벗어난 새 방식(예: 완전히 새로운 채점 함수)을 만들면 진행률 계산과 PDF 출력을 별도로 손봐야 하므로, 가능하면 기존 패턴을 재사용하는 쪽을 우선 고려하세요.

## 1. 이미 구현되어 있는 활동 유형 (그대로 재사용 가능)

### 1-1. 빈칸 채우기 (텍스트 입력)
```html
<textarea class="blank blank--autogrow" rows="1" aria-label="고유한-식별자" placeholder="빈칸"></textarea>
```
- 한 줄 답이면 `blank--autogrow`를 붙여 입력한 글자 길이에 맞춰 가로·세로가 자동으로 늘어나게 합니다 (이 파일의 최신 관례 — 모든 빈칸은 이 방식을 씁니다). `<input>`이 아니라 `<textarea rows="1">`을 씁니다.
- 여러 줄 서술형이면 `blank`만 붙이고 `blank--autogrow`는 생략 — 세로로만 자동으로 늘어납니다.
- `aria-label`은 페이지 전체에서 유일해야 합니다. 자동저장(`saveDraft`/`loadDraft`)과 진행률 계산이 이 속성으로 칸을 식별하기 때문입니다. **이 속성이 없으면 자동저장·진행률에서 아예 빠집니다.**
- 정답이 정해진 빈칸이 아니라 학번/번호/이름 같은 식별 칸은 `.id-fields` 안의 `input.blank`를 그대로 씁니다 (기존 패턴, 진행률 계산에서는 제외되도록 이미 별도 처리됨).

#### 1-1-a. 자동 확장 동작 (넘치는 텍스트가 다 보이게)

`#tab-worksheet`의 **모든 답 빈칸은 `<textarea class="blank">`** 입니다. 과거엔 `<input type="text" class="blank" style="width:90px">` 같은 고정폭 칸이 섞여 있었으나(흐름도·의사결정·판단의열쇠·표 안 빈칸 등), `<input>`은 줄바꿈이 불가능해 긴 답이 잘리므로 **전부 `<textarea class="blank blank--autogrow" rows="1">`로 변환**했습니다. 예외는 `.id-fields`의 반·번호·이름 3개뿐(짧은 식별자라 `input.blank` 유지).

관련 JS 함수(이미 구현되어 있음, 새로 짤 필요 없음):

| 함수 | 역할 |
|---|---|
| `autoGrowTextarea(el)` | 높이만: `height:auto`로 비웠다가 `el.scrollHeight + 테두리` 로 재설정. `blank--autogrow`가 **아닌** 여러 줄 답란용. |
| `autoSizeGrowBlank(el)` | 가로→세로: 화면 밖 mirror `<span>`에 같은 글꼴로 값을 넣어 필요한 px를 재고 `el.style.width`를 그만큼 지정. **최대 폭**은 표 안이면 `el.closest('.table-scroll').clientWidth − 첫 칸 폭 − 40`, 표 밖(문장 속)이면 `el.parentElement.clientWidth`. 폭이 최대에 닿으면 그 뒤론 줄바꿈되며 `autoGrowTextarea(el)`로 높이가 늘어남. 측정 실패(탭 비표시) 시 폴백 520px. `blank--autogrow` 전용. |
| `sizeWorksheetTextarea(el)` | 위 둘 중 선택: `el.classList.contains('blank--autogrow')` 면 `autoSizeGrowBlank`, 아니면 `autoGrowTextarea`. |

배선(변환 시 코드 수정 불필요 — 기존 셀렉터가 전부 커버):
- 입력 리스너: `worksheetInputs()`(`#tab-worksheet input[aria-label], textarea[aria-label]`) 에 `input` 이벤트 → `if (el.tagName === 'TEXTAREA') sizeWorksheetTextarea(el)`.
- 초기 크기 + 탭 열 때 재계산: `worksheetTextareas`(`#tab-worksheet textarea.blank` 스냅샷)을 페이지 로드 후, 그리고 `[수정 43-2]` 에서 `tab-worksheet` 탭이 실제로 보이게 될 때마다 `forEach(sizeWorksheetTextarea)`. (탭이 `display:none`일 땐 폭이 0으로 잡혀 잘못 계산되므로 탭 표시 직후 반드시 다시 계산.)
- 붙여넣기/드래그 차단, 진행률(`.section-block textarea.blank`), 타이핑 속도 가드 — 셀렉터가 이미 `textarea.blank`를 포함하므로 변환분도 자동 적용.
- CSS: `textarea.blank.blank--autogrow{ display:inline-block; width:auto; min-width:90px; max-width:100%; vertical-align:middle }`, `.wide`면 `min-width:160px`, 표(td) 안이면 `display:block`.
- **표 안 빈칸을 쓸 때는 반드시 `.table-scroll` 래퍼 유지** — `autoSizeGrowBlank`의 최대 폭 계산 기준이라 없으면 칸이 무한정 늘어남(1-7 참고).

#### 1-1-b. PDF 저장 시 빈칸 처리 (`buildPrintableClone()`)

"학습지 PDF로 저장하기"(`#saveBtn`, html2canvas + jsPDF)는 `buildPrintableClone()`이 `#tab-worksheet .sheet`를 복제한 뒤, **각 `textarea.blank`를 `<div class="pdf-answer-block">`로 바꿔치기**합니다(html2canvas가 textarea 줄바꿈을 정확히 못 그려서). 값은 원본 live 요소의 `.value`(aria-label로 조회). `[수정 43-3]`에서 이 치환을 **문맥에 맞게** 분기:

- `inlineMode = liveEl.classList.contains('blank--autogrow') && !el.closest('td')` (문장 속 인라인 빈칸):
  `display:inline-block; vertical-align:middle; width:<Math.ceil(liveEl.getBoundingClientRect().width)>px; max-width:100%; min-width:<liveEl minWidth>px` — **화면에서 늘어난 폭 그대로** → 같은 자리에서 같은 방식으로 줄바꿈되고 뒤 문장("분명히 정한다." 등)이 이어짐. `rect.width`가 0이면 폴백 220px.
- 그 외(표 td 안 / `blank--autogrow` 아닌 큰 답란): 기존대로 `display:block; width:100%; margin-top:4px`.
- 공통: `min-height:38px; height:auto`(**고정 height 금지**) + `white-space:pre-wrap; overflow-wrap:break-word; word-break:break-word` → 세로로 얼마든 늘어나고 한 글자도 안 잘림. 빈 값이면 작은 빈 상자.
- 치환 뒤 **복제본에서만**(화면 원본 불변) 세로 클리핑 해제: `clone.querySelectorAll('.flow-fill, .fill-line')` → `overflow:visible; height:auto; maxHeight:none`, `clone.querySelectorAll('table.sheet-table--fit td')` → `height:auto`(`height:1px` 트릭 무력화).

> 새로 만드는 빈칸이 `textarea.blank`(+필요시 `blank--autogrow`) 패턴을 그대로 쓰면 위 PDF 처리가 자동 적용됩니다. 완전히 새로운 입력 클래스를 만들면 `buildPrintableClone()`에 그 클래스의 치환/스타일을 추가해야 합니다(2장 4번).

### 1-2. 객관식 카드 퀴즈 (자동 채점, 단일 정답)
```html
<div class="mc-quiz-item">
  <p>질문 문장</p>
  <div class="choice-card-row">
    <button type="button" class="choice-card" data-item="고유값-1" data-group="문제그룹명">① 보기1</button>
    <button type="button" class="choice-card" data-item="고유값-2" data-group="문제그룹명" data-correct="true">② 보기2</button>
    <button type="button" class="choice-card" data-item="고유값-3" data-group="문제그룹명">③ 보기3</button>
  </div>
  <p class="mc-feedback"></p>
</div>
```
- `.mc-quiz-item`으로 감싸야 클릭 즉시 자동 채점(정답/오답 표시, `.mc-feedback` 문구)이 동작합니다.
- 같은 `data-group` 값을 가진 카드끼리는 하나만 선택되도록 자동 처리됩니다(라디오 버튼처럼 동작).
- 정답 카드에만 `data-correct="true"`를 붙입니다. 보기가 여러 개여도 정답은 하나만 표시하세요 (현재 코드는 단일 정답 기준으로 채점).
- `data-item` 값은 페이지 전체에서 유일해야 합니다 (자동저장의 선택 상태 키).

### 1-3. OX 퀴즈 (여러 문항 묶음 채점)
```html
<div class="ox-quiz-item" data-ox-answer="O">
  <p>문항 문장</p>
  <div class="choice-card-row">
    <button type="button" class="choice-card choice-card--ox" data-group="퀴즈그룹-1" data-item="퀴즈그룹-1-O" data-value="O">O</button>
    <button type="button" class="choice-card choice-card--ox" data-group="퀴즈그룹-1" data-item="퀴즈그룹-1-X" data-value="X">X</button>
  </div>
</div>
...
<button type="button" class="ox-check-btn">✅ 정답 확인</button>
<button type="button" class="ox-reset-btn">❎ 다시 풀기</button>
<span id="oxResultXXX"></span>
```
- `data-ox-answer`는 "O" 또는 "X". `ox-check-btn`을 누르면 그 순간 선택된 답과 비교해 문항 상자 전체를 초록(정답)/빨강(오답)으로 칠하고 `✅`/`❌` 표시를 붙입니다.
- `ox-check-btn`/`ox-reset-btn`은 `data-result-id`로 결과 요약을 표시할 `<span id="...">`를 가리킵니다. 채점은 "누르는 순간"에만 일어나는 일괄 채점이며, 실시간 채점이 아닙니다.
- 주의: 현재 코드의 `ox-check-btn`/`ox-reset-btn` 핸들러는 페이지에 있는 **모든** `.ox-quiz-item`을 한꺼번에 채점/초기화합니다(그룹별 분리 기능 없음). 한 페이지에 서로 다른 OX 퀴즈 묶음을 두 개 이상 넣고 싶다면, 채점 함수에 그룹 필터링을 추가하는 수정이 필요합니다.

### 1-4. 드래그 짝짓기 (이미 완전히 구현되어 있음 — 이 파일 v3에는 아직 실제로 쓰이지 않았지만 CSS/JS 전부 준비되어 있어 마크업만 추가하면 바로 동작합니다)
```html
<div class="dnd-tray" id="dndTray1">
  <span class="dnd-chip" data-value="칩A" data-answer-key="키A">이름표1</span>
  <span class="dnd-chip" data-value="칩B" data-answer-key="키B">이름표2</span>
</div>

<div class="dnd-row">
  <p>설명 문장 1</p>
  <div class="dnd-slot" data-slot="slot1" data-check-group="dndTray1" data-answer="키A"></div>
</div>
<div class="dnd-row">
  <p>설명 문장 2</p>
  <div class="dnd-slot" data-slot="slot2" data-check-group="dndTray1" data-answer="키B"></div>
</div>

<button type="button" class="dnd-check-btn" data-target-tray="dndTray1" data-result-id="dndResult1">✅ 정답 확인</button>
<button type="button" class="dnd-reset-btn" data-target-tray="dndTray1" data-result-id="dndResult1">🔄 다시 섞기</button>
<span id="dndResult1"></span>
```
- 마우스로는 드래그 앤 드롭, 터치/키보드 기기에서는 "칩 클릭(선택) → 칸 클릭(놓기)" 대체 방식이 이미 둘 다 구현되어 있습니다.
- `.dnd-tray`는 `id`가 필요합니다(칩이 "제자리"를 기억하는 기준). 한 페이지에 짝짓기 활동이 여러 개면 트레이 id를 서로 다르게 주면 각각 독립적으로 동작합니다.
- `.dnd-chip`의 `data-value`는 트레이 전체에서 유일해야 합니다. `data-answer-key`는 채점 시 정답 판정에 쓰는 값이고, 생략하면 `data-value`가 그대로 정답 키로 쓰입니다.
- `.dnd-slot`의 `data-slot`은 유일 식별자(자동저장용), `data-check-group`은 채점 버튼의 `data-target-tray`와 같은 값을 써서 "이 칸들을 함께 채점"하도록 묶습니다, `data-answer`는 이 칸에 들어와야 할 정답 키입니다.
- 이름표가 2개 이상인 줄을 가운데 정렬하고 싶으면 `.dnd-row`에 `.dnd-row--center`를 추가로 붙입니다. 줄이 많아 세로로 길어지면 `.dnd-grid-2col`로 감싸 2열 배치할 수 있습니다.
- 진행률 계산(`.dnd-slot`이 채워졌는지), 자동저장(`data.dnd`), PDF 인쇄(`buildPrintableClone`의 흑백 대비 스타일)까지 전부 이미 연결되어 있습니다. **즉, "드래그 짝짓기" 활동을 새로 넣을 때 JS를 새로 짤 필요가 없고, 위 마크업 패턴만 그대로 복사해서 문항 내용만 바꾸면 됩니다.**

### 1-5. 흐름도 (순서가 있는 단계 시각화, 읽기 전용)
```html
<div class="flow-diagram">
  <div class="flow-step"><span class="flow-num">1</span><p>단계 설명</p></div>
  <!-- 화살표는 CSS로 자동 처리 -->
</div>
```
- 클릭/입력 상호작용은 없고 순서를 보여주기만 하는 정적 컴포넌트입니다. `.flow-num`은 프로그램 실행 단계 이미지(예: "프로그램 들어가는 방법", "파일 저장하는 방법" 섹션)에서 번호 배지로도 재사용 중입니다.

### 1-6. 콜아웃 박스 (안내/팁/질문 강조)
```html
<div class="callout callout--goal">...</div>  <!-- 주황, 오늘의 목표용 -->
<div class="callout callout--tip">...</div>   <!-- 초록, 팁 -->
<div class="callout callout--gemini">...</div> <!-- 보라, 질문/설명 강조 (특정 AI 도구 전용 의미는 없고 색상 토큰으로만 재사용 중) -->
```

### 1-7. 표
```html
<div class="table-scroll">
  <table class="sheet-table">...</table>
</div>
```
- 가로로 넘칠 수 있는 표는 `.table-scroll`로 감싸 가로 스크롤이 생기게 합니다. `.blank--autogrow` 칸이 표 안에 있을 때 최대 너비 계산이 이 래퍼를 기준으로 하므로, 표 안 빈칸을 쓸 때는 반드시 이 래퍼를 유지하세요.

### 1-8. 표·데이터를 복사 못 하게 막기 (제공 자료 보호)

학생이 답을 유추할 근거가 되는 **제공 자료**(예: "○○ 판매량 TOP 10" 같은 데이터 표)를 드래그로 긁어 복사·붙여넣지 못하게 막는 패턴입니다. 표는 그대로 읽히고, 가로 스크롤도 유지됩니다. (`data4.html` ACTIVITY_5 "일본 만화 판매량 TOP 10" 표에 적용 — `guide/build.md` "만화 판매량 표 복사 방지" 절 참고.)

**CSS** (`<style>`에 한 번만):
```css
.no-copy{ user-select:none; -webkit-user-select:none; -ms-user-select:none; }
```

**마크업** — 보호할 컨테이너에 유일 `id` + `class="no-copy"`. `.table-scroll` 스크롤 래퍼에는 걸지 말고 그 **안쪽** 요소에 겁니다(스크롤·`pointer-events` 유지).
```html
<div class="table-scroll">
  <div id="mangaTable" class="no-copy"> …표… </div>
</div>
```
- `user-select:none`은 자식이 상속하므로 컨테이너 하나에만 걸면 됩니다.

**JS** — `user-select:none`만으로도 드래그 선택이 막히지만, `copy`/`cut`/우클릭 메뉴/드래그까지 확실히 막으려면 **`document`에 위임**하고 `closest('#id')`로 그 표에서 난 이벤트만 막습니다.
```js
['copy','cut','contextmenu','dragstart'].forEach(function (ev) {
  document.addEventListener(ev, function (e) {
    var n = e.target;
    if (n && n.closest && n.closest('#mangaTable')) e.preventDefault();
  }, true);
});
```
- **왜 위임인가**: 요소가 탭 전환 시점에야 렌더되는 구조(예: `data4.html`의 `<sc-if>`)에서는 초기화 때 `getElementById`가 `null`입니다. 이 파일(`data3.html`)은 요소가 항상 DOM에 있어 직접 `getElementById(...).addEventListener`도 되지만, 위임이 마운트 타이밍에 안전하고 표를 여러 개로 늘릴 때도 그대로 확장됩니다.
- `#tab-worksheet input.blank`의 붙여넣기 차단(§2-2)과 **별개**입니다: 그건 "입력칸에 못 붙여넣게", 이건 "제공 자료를 못 복사하게".
- 표 **밖**(다른 입력칸·본문)의 복사는 정상 동작해야 합니다 — `closest` 조건으로 한정하므로 부작용 없음.

**검증**: `getComputedStyle(el).userSelect === 'none'`, 표 셀에서 `copy`/`cut`/`contextmenu`/`dragstart` 이벤트를 dispatch 했을 때 `e.defaultPrevented === true`, 표 밖 요소에서는 `false`. `.table-scroll` 이 좁은 뷰포트에서 여전히 가로 스크롤되는지도 확인.

## 2. 새 활동을 추가할 때 반드시 지켜야 하는 공통 규칙

1. **모든 입력형 요소(input/textarea)에 `aria-label` 유일값 부여.** 자동저장·불러오기·타이핑 속도 감지(부정행위 방지)가 전부 이 속성 기준으로 동작합니다.
2. **붙여넣기 방지·타이핑 속도 감지(안티치트)가 이미 걸려 있음.** `input.blank`/`textarea.blank` 클래스가 붙은 요소는 자동으로 붙여넣기(Ctrl+V, 드래그 텍스트 놓기)가 막히고, 2초 동안 분당 1000자를 넘는 속도로 값이 바뀌면 직전 값으로 되돌아갑니다. **이 페이지를 Playwright 등으로 자동 채우기 테스트할 때는 반드시 `locator.pressSequentially(text, {delay: 65~70})`처럼 사람 타이핑 속도로 입력해야 합니다. `.fill()`이나 짧은 delay(예: 25ms)를 쓰면 안티치트가 입력값을 조용히 되돌려서 값이 깨집니다.**
3. **진행률(`updateProgress()`) 계산 대상은 정확히 3종류뿐입니다**: `#tab-worksheet .section-block` 안의 `input.blank`/`textarea.blank`, `.ox-input`(현재 파일엔 실사용 안 됨, 구형 패턴), `.dnd-slot`. 객관식 카드(`.choice-card`)는 정답 개수가 정해져 있지 않다는 이유로 진행률 계산에서 의도적으로 제외되어 있습니다. 새 활동 유형을 진행률에 포함시키고 싶으면 `updateProgress()` 함수 자체를 수정해야 합니다.
4. **PDF 인쇄(html2canvas 경로, `buildPrintableClone()`)는 컴포넌트별로 흑백 대비용 스타일을 하드코딩**해서 적용합니다(예: `.dnd-slot`, `.mc-quiz-item`, `.callout` 등). 완전히 새로운 클래스로 활동을 만들면 이 함수에도 해당 클래스의 인쇄용 스타일 처리를 추가해야, "PDF로 저장하기" 버튼을 눌렀을 때 새 활동이 깨지지 않고 보기 좋게 나옵니다. 반대로 기존 클래스(1장에 정리한 것들)를 그대로 재사용하면 이 작업이 필요 없습니다.
5. **네이티브 인쇄(`@media print` CSS, Ctrl+P/Playwright `page.pdf()` 경로)에는 `break-inside:avoid` 규칙이 없습니다.** 이 경로로 PDF를 뽑는 스크립트를 짤 때는 `.flow-diagram, .callout, .table-scroll, .mc-quiz-item, .ox-quiz-item, .dnd-row, .choice-card-row` 등에 `break-inside:avoid`를 임시로 주입(`page.addStyleTag()`)해서 요소가 페이지 경계에서 잘리지 않게 하세요. 실제 배포 파일 자체는 건드리지 않는 것이 지금까지의 관례입니다.
6. **미션 색상 테마**: `.section-block.mission-color-1/2/3/...` 클래스로 미션마다 헤더 색이 자동 지정됩니다(`h3` 배경색). 새 미션을 추가하면 `mission-color-N`을 이어서 쓰고, 필요하면 CSS에 해당 번호의 색상 규칙을 추가합니다.
7. **teacher 파일 동기화 잊지 않기.** 학생용 파일 수정 후 `.topbar{position:sticky` → `static`, `.progress-row{position:sticky` → `static` 두 곳만 바꿔 교사용 파일을 재생성합니다. 그 외 내용은 100% 동일해야 합니다.
8. **한 파일 안에서 검증**: 수정 후에는 (a) `<script>...</script>` 블록만 추출해 JS 문법 검사, (b) `<div>`/`</div>` 개수 등 태그 균형 확인(단, 이 파일은 JS 문자열 안에 `<div`가 섞여 있어 순수 카운트만으로는 100% 정확하지 않을 수 있음 — 기존 파일 대비 "델타"로 비교), (c) Playwright로 실제 렌더링 스크린샷을 찍어 육안 확인하는 3단계를 거치는 것이 이 프로젝트의 기존 관례입니다.

## 3. 아직 구현되어 있지 않지만 이 구조 위에 자연스럽게 추가할 수 있는 활동 유형 아이디어

아래는 기존 컴포넌트(위 1장)를 최대한 재사용하면서 만들 수 있는, 아직 없는 활동 유형입니다. 순서는 구현 난이도가 낮은 것부터입니다.

- **순서 배열(시퀀싱) 드래그**: 1-4 짝짓기 컴포넌트를 응용 — 슬롯을 "①/②/③/④" 순서 칸으로 만들고, 칩에 뒤섞인 단계 설명(또는 이미지)을 담아 올바른 순서로 놓게 합니다. 채점 로직(`data-answer`)을 그대로 재사용할 수 있습니다.
- **분류하기(카테고리 나누기)**: 역시 1-4를 응용 — 트레이 하나에 여러 항목 칩을 두고, 슬롯 대신 "구체적인 질문" / "모호한 질문"처럼 카테고리 상자를 2~3개 만들어 각 상자에 여러 칩을 놓을 수 있게 합니다(현재 `placeChipInSlot`은 칸 하나에 칩 하나만 들어가도록 되어 있어, 카테고리당 여러 개를 담으려면 "칸이 여러 칩을 품을 수 있도록" 로직을 살짝 수정해야 합니다 — 완전 재사용은 아니고 부분 수정 필요).
- **이미지 핫스팟 클릭**: 기존 base64 이미지(예: 프로그램 실행 화면) 위에 `position:absolute`인 투명 버튼(`.choice-card`와 유사한 클릭 판정 영역)을 좌표로 겹쳐 놓고, 1-2 객관식 채점 패턴을 그대로 재사용해 "여기를 클릭하세요"형 문제를 만들 수 있습니다.
- **카드 뒤집기(짝맞추기 메모리 게임)**: 새 컴포넌트가 필요합니다. 카드 배열을 `<button class="flip-card" data-pair="A">`처럼 만들고 클릭 시 `.flipped` 토글, 두 장이 열렸을 때 `data-pair` 일치 여부 비교하는 새 JS가 필요합니다. 진행률/PDF 처리에 새로 편입시키려면 2장의 4번·3번 규칙에 따라 손봐야 합니다.
- **슬라이더 평가/추정 활동**: `<input type="range">`를 하나 추가하고, 값에 따라 피드백 문구를 보여주는 정도로 간단히 만들 수 있습니다. 다만 `input.blank`가 아니므로 진행률·자동저장에 넣으려면 `worksheetInputs()`/`updateProgress()`가 range input도 인식하도록 조건을 추가해야 합니다.
- **타이머 챌린지**: 기존 어떤 활동(빈칸/퀴즈/짝짓기) 위에 "제한 시간" 요소만 얹는 방식 — `setInterval`로 카운트다운 표시 후 시간 종료 시 입력을 막는 정도로, 별도 채점 시스템 없이 기존 활동을 감싸는 형태로 구현 가능합니다.

## 4. 새 활동 추가 시 체크리스트

1. 어느 MISSION(`section-block`)에 넣을지, 기존 활동 유형(1장)으로 충분한지 먼저 판단 — 충분하면 마크업만 복사해 문항 내용 교체.
2. 모든 입력/식별 요소에 유일한 `aria-label` 또는 `data-value`/`data-item`/`data-slot` 부여.
3. 정답 판정 값(`data-correct`, `data-ox-answer`, `data-answer`)을 정확히 지정하고, 실제로 문제/자료 내용과 논리적으로 맞는지 검증(추측 금지 — 이 파일의 다른 문항들도 원본 학습 자료의 정의를 근거로 정답을 정했습니다).
4. 자동저장 대상에 포함되었는지, 진행률 계산에 포함할지 여부를 결정하고 필요하면 2장 3번 규칙에 따라 `updateProgress()`를 수정.
5. `buildPrintableClone()`에 새 클래스의 인쇄 스타일이 필요한지 확인(기존 클래스만 재사용했다면 생략 가능).
6. 학생용 파일 수정 → 교사용 파일 재생성(`sticky`→`static` 두 곳) → 두 파일 모두 JS 문법 검사 → Playwright 스크린샷으로 시각 확인 → 필요시 `pressSequentially(delay:65~70)`로 실제 입력·채점 동작까지 검증.
