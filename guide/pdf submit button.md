# data4_1.html — "PDF로 저장하기(제출)" 버튼 동작 문서

> 대상 파일: `data4_1.html`
> 목적: 다른 AI 에이전트가 이 파일을 열람/수정할 때, "PDF로 저장하기" 버튼(사실상 "제출" 기능을 겸함)이
> 어떻게 동작하는지 코드 재분석 없이 바로 파악할 수 있게 정리한다.

## 1. 한눈에 보는 요약

- 화면상 라벨은 **"📄 PDF로 저장하기"** 이지만, 클릭 시 학생이 작성한 수업 활동지를 **PDF 파일로
  다운로드**시키는 동시에 화면 진행률 위젯에 **"✓ 제출" 배지**를 띄우는 **저장 = 제출** 겸용 버튼이다.
  파일 안에 "제출하기"라는 별도 문구/버튼은 없고, 이 PDF 저장 동작이 곧 제출 행위로 취급된다.
- 버튼 id: `pdfBtn` / 클릭 핸들러: `{{ savePdf }}` (data-dc-script 로직의 `savePdf` 함수).
- 정상 경로: `html2canvas`로 활동지 DOM을 캡처 → `jsPDF`로 A4 여러 페이지 PDF 생성 → 브라우저 다운로드.
- 라이브러리 로드 실패/미지원 환경이면: 자동으로 `window.print()` 인쇄창을 여는 방식으로 **폴백**.
- 두 경로 모두 성공하면 컴포넌트 상태 `saved: true`, `savedName: <학생 이름>`을 설정하고,
  이 값이 하단의 "SAVED! 활동지 저장 완료" 배지와 좌측 하단 플로팅 위젯의 "✓ 제출" 배지에 반영된다.

---

## 2. 관련 UI 요소 (템플릿, `<x-dc>` 내부)

### 2.1 버튼 자체
```html
<div id="pdfBtn" onClick="{{ savePdf }}"
     style="cursor:pointer; padding:12px 24px; border:3px solid #4b3b6b; borderRadius:10px;
            background:#9db2f2; color:#26224a; fontFamily:'CookieRun', ...; fontWeight:700; fontSize:18px;
            boxShadow:4px 4px 0 rgba(75,59,107,.3)"
     style-active="... background:#8296e0; boxShadow:1px 1px 0 rgba(75,59,107,.3); transform:translate(3px,3px)">
  📄 PDF로 저장하기
</div>
```
- "수업 활동지" 탭(`isSheet` / `s.tab === 'sheet'`)의 맨 아래에 위치.
- `style-active`는 눌림(active) 상태 스타일(디자인 시스템의 클릭 피드백 패턴).

### 2.2 저장 완료 안내 (버튼 바로 아래)
```html
<sc-if value="{{ saved }}" hint-placeholder-val="{{ false }}">
  <div style="... background:#fffdf7 ...">SAVED! 활동지 저장 완료</div>
</sc-if>
```
- `saved`가 `true`가 되면(=PDF 저장 또는 인쇄 폴백 성공 시) 나타남.

### 2.3 캡처 대상 DOM
```html
<div id="sheetPrintArea" style="display:flex; flexDirection:column; gap:18px">
  ... 활동지 전체 콘텐츠 (학번/이름 입력, 문제, 답안 textarea 등) ...
</div>
```
- `savePdf`가 캡처하는 루트 요소. **원본이 아니라 이 요소를 clone한 복제본**을 화면 밖에 렌더링해서 캡처한다
  (원본 화면은 건드리지 않음, 뒤쪽 §4 참고).

### 2.4 좌측 플로팅 "활동 진행률" 위젯의 제출 배지
```html
<div class="sheet-progress" aria-label="활동 진행률" style="display:{{ sheetWidgetDisplay }}">
  <div class="sp-head">PROGRESS</div>
  <div class="sp-body">
    <div class="sp-title">활동 진행률</div>
    <div class="sp-count">
      <span class="big">{{ sheetPct }}%</span>
      <span class="sub">{{ sheetDone }}/{{ sheetTotal }}</span>
    </div>
    <div class="track" role="progressbar" ...>
      <div class="fill" style="{{ sheetFillStyle }}"></div>
    </div>
    <sc-if value="{{ sheetSaved }}" hint-placeholder-val="{{ false }}">
      <span class="sp-done">✓ 제출</span>
    </sc-if>
  </div>
</div>
```
- `<x-dc>` 직속(줌 래퍼 밖)에 고정 위치(`position: fixed`)로 떠 있는 위젯.
- **"✓ 제출"** 문구가 실제로 "제출"이라는 단어가 등장하는 유일한 위치이며, `sheetSaved`(= `!!s.saved`)가
  true일 때만 표시된다. 즉 PDF 저장 버튼을 눌러 성공해야 이 배지가 뜬다.
- `sheetPct/sheetDone/sheetTotal`(진행률 %)은 **PDF 저장 여부와 무관**하게 별도 체크리스트로 계산되며
  (§3.2 참고), "제출" 배지만 저장 성공 여부에 연동된다 — 즉 진행률 100%가 아니어도 저장/제출은 가능하다.

---

## 3. 관련 상태(state) & 파생 값 (`data-dc-script` 로직)

### 3.1 초기 상태
```js
{
  fGrade: '', fClass: '', fNum: '', fName: '',   // 학년/반/번호/이름 입력값
  saved: false, savedName: '',                    // 저장(제출) 여부, 저장 시점의 이름
  ...
}
```
- `fGrade/fClass/fNum/fName`은 활동지 상단의 학번·이름 입력란(`textarea.blank`)과 바인딩되어 있으며,
  PDF 파일명 생성에 쓰인다(§4 참고).

### 3.2 진행률 위젯 파생 값 (render 시 매번 계산)
```js
const sheetChecklist = [
  !!(s.fName && s.fName.trim()),   // 이름을 적었는가
  !!s.q1Pick,                       // 1번 문제에 답했는가
  !!(s.prog2 && s.prog2.trim())     // 서술형 답안(prog2)을 적었는가
];
const sheetDone = sheetChecklist.filter(Boolean).length;
const sheetTotal = sheetChecklist.length;
const sheetPct = Math.round(sheetDone / sheetTotal * 100);
const sheetFillStyle = 'width:' + sheetPct + '%';
const sheetSaved = !!s.saved;                     // 진행률 집계엔 미포함, "제출" 배지 전용
const sheetAria = sheetTotal + '개 중 ' + sheetDone + '개 완료';
const sheetWidgetDisplay = s.tab === 'sheet' ? 'flex' : 'none';  // '수업 활동지' 탭에서만 위젯 표시
```
- **중요**: `sheetSaved`(제출 배지)는 진행률 체크리스트(`sheetChecklist`)에 포함되지 않는다.
  진행률 100%와 "제출 완료" 배지는 서로 독립적인 신호다.

---

## 4. `savePdf` 함수 상세 동작

버튼 클릭 → `savePdf()` 실행. 아래는 로직을 순서대로 정리한 것이다.

### 4.0 준비: 파일명 생성
```js
const dig = v => 숫자만 추출;
const pad2 = v => 2자리로 zero-padding (예: '3' → '03');
const name = s.fName.trim();
const code = dig(fGrade) + pad2(fClass) + pad2(fNum);   // 예: 2학년 3반 5번 → "2035"
const fname = (code ? code+' ' : '') + (name ? name+' ' : '') + '활동지';  // 예: "2035 홍길동 활동지"
const pdfName = fname + '.pdf' (이미 .pdf로 끝나면 그대로)
```
- **학번(학년+반+번호)이 파일명 앞에 붙고, 없으면 생략**된다. 이름도 없으면 "활동지.pdf"만 남는다.

### 4.1 라이브러리 사용 가능 여부 체크
```js
const H2C = window.html2canvas;
const JSPDF = window.jspdf && window.jspdf.jsPDF;
const src = document.getElementById('sheetPrintArea');
if (typeof H2C !== 'function' || typeof JSPDF !== 'function' || !src) {
  printFallback();  // §4.5 참고 — 여기서 함수 종료
  return;
}
```
- `html2canvas`/`jsPDF`는 data4_1.html의 `<head>`에 **인라인 base64로 이미 로드되어 있음**
  (Google Sites 임베드 시 CSP 때문에 외부 CDN `<script src>` 대신 인라인한 것 — 별도 문서
  `data4_1-self-containment-rules.md` 규칙 1/5 참고).
- 둘 중 하나라도 없거나 캡처 대상이 없으면 즉시 인쇄 폴백으로 넘어간다.

### 4.2 버튼 잠금 + 로딩 표시
```js
btn.textContent = '⏳ PDF 만드는 중...';
btn.style.pointerEvents = 'none';
btn.style.opacity = '0.6';
```
- 중복 클릭 방지.

### 4.3 캡처용 복제본(clone) 준비 — 화면에 보이는 원본은 절대 건드리지 않음
1. `#sheetPrintArea`를 `cloneNode(true)`로 복제.
2. 복제본을 화면 밖(`position:fixed; left:-10000px`)의 흰 배경(`background:#ffffff`) 컨테이너
   (`width:820px; padding:24px`)에 넣어 `document.body`에 임시로 append.
3. 복제본 안에서 다음을 정리:
   - **"PDF로 저장하기" 버튼(#pdfBtn) 자체는 결과물에서 숨김** (부모 요소 `display:none`).
   - `.seq-tray`, `.ca-tray`(아직 배치하지 않은 드래그 칩 트레이)는 인쇄 불필요하므로 숨김.
   - **`textarea.blank`(학생이 입력한 모든 답안 칸)를 `<div>`로 치환**:
     - `html2canvas`는 `<textarea>` 내부 텍스트를 그리지 못하므로, 실제 입력값(`live.value`,
       원본 DOM에서 읽음)을 텍스트로 넣은 `<div>`로 바꿔치기.
     - inline형 답안 칸(`blank--inline`)과 블록형 답안 칸에 대해 서로 다른 스타일을 재현.
   - 복제본과 그 하위 요소들의 `id` 속성을 전부 제거(중복 id로 인해 원본 드래그&드롭
     엔진이 복제본을 잘못 조작하는 것을 방지).

### 4.4 캡처 → PDF 생성 → 다운로드
```js
await (document.fonts?.ready ?? Promise.resolve())  // 최대 1.5초까지만 기다림
await 80ms 대기                                       // 복제본 레이아웃 안정화
const canvas = await H2C(clone, { scale: 2, backgroundColor: '#ffffff', useCORS: true, logging: false });

const pdf = new JSPDF('p', 'pt', 'a4');
// canvas를 A4 페이지 높이 단위로 잘라 페이지마다 JPEG(품질 0.9)로 addImage, 필요시 addPage 반복
pdf.save(pdfName);                     // 브라우저 표준 다운로드 트리거 (보통 "다운로드" 폴더)
this.setState({ saved: true, savedName: name });
```
- 세로로 긴 활동지도 여러 페이지 A4 PDF로 자동 분할된다.
- PNG 대신 **JPEG(품질 0.9)**를 쓰는 이유가 주석으로 명시되어 있음: "흰 배경·검정 글씨라 열화가
  거의 안 보이고, PNG로 하면 페이지당 십수 MB가 되기 때문".
- 성공 시 `saved: true`, `savedName: <이름>` 상태 갱신 → §2.2/§2.4 UI가 반응.

### 4.5 에러 처리 및 정리
```js
.catch(err => { console.error('[savePdf]', err); alert('PDF를 만드는 중 문제가 생겼어요. 잠시 후 다시 눌러 주세요.'); })
.then(done, done);  // 성공/실패 모두 실행되는 정리 단계

function done() {
  임시 clone 컨테이너를 DOM에서 제거;
  버튼 텍스트/pointerEvents/opacity를 원래대로 복원;
}
```

### 4.6 `printFallback()` — 라이브러리가 없을 때의 대체 경로 (§4.1에서 분기)
```js
const prevTitle = document.title;
function cleanup() {
  document.body.classList.remove('print-sheet-only');
  document.title = prevTitle;
}
window.addEventListener('afterprint', cleanup);
document.title = fname;                          // 인쇄 대화상자의 기본 파일명으로 활용됨
document.body.classList.add('print-sheet-only');  // 아래 §5 CSS가 적용됨
this.setState({ saved: true, savedName: name });
setTimeout(() => { window.print(); setTimeout(cleanup, 1000); }, 60);
```
- 이 경로는 실제 PDF 파일을 만들지 않고 **브라우저 표준 인쇄창**을 연다(사용자가 "PDF로 저장"을
  직접 선택해야 함). 그래도 `saved: true`는 동일하게 설정되어 "제출" 배지는 뜬다.
- 참고: `data4.html`(자체완결화 이전 원본)의 `savePdf`는 **이 폴백 로직 하나만** 갖고 있었다.
  data4_1.html에서는 이게 "실패 시 대비책"으로 격하되고, §4.3~§4.4의 실제 PDF 생성 경로가
  기본 동작이 되었다.

---

## 5. 엣지 케이스: 이름 미입력 / 진행률 낮음 상태에서 버튼을 눌렀을 때

**결론부터: 코드 전체(`savePdf`, `printFallback`)에 이름·진행률을 검사해서 저장을 막는
로직(validation/guard)이 전혀 없다.** 두 경우 모두 **버튼은 정상적으로 동작하며 PDF 저장(또는
인쇄)과 "제출" 처리가 그대로 진행된다.** 막지 않는 대신, 아래처럼 결과물/표시에 소소한 차이만 생긴다.

### 5.1 이름(`fName`)을 적지 않고 버튼을 눌렀을 때

- **막히지 않는다.** `savePdf` 어디에도 `if (!name) return`류의 체크가 없으므로 즉시 PDF 생성(또는
  인쇄 폴백)이 진행되고 `saved: true`가 설정된다.
- **파일명에서 이름 부분만 빠진다** (§4.0 로직 그대로 적용):
  ```js
  const name = String(s.fName == null ? '' : s.fName).trim();   // '' (빈 문자열)
  const fname = (code ? code+' ' : '') + (name ? name+' ' : '') + '활동지';
  ```
  - 학번(학년/반/번호)까지 비어 있으면 파일명은 그냥 `활동지.pdf`가 된다.
  - 학번만 채워져 있으면 예: `2035 활동지.pdf` (이름 세그먼트만 생략).
- **PDF 본문 내용도 그대로 캡처된다** — 이름 입력칸(`textarea.blank`)이 비어 있으면 그 칸은
  §4.3에서 값이 `''`인 빈 `<div>`로 치환되어, **PDF 안에 이름 칸이 빈 채로 그대로 남는다**
  (즉 시스템이 대신 채워주지 않고, "이름 없이 제출된 흔적"이 PDF에 고스란히 보인다).
- `sc-if value="{{ saved }}"` 조건으로 뜨는 **"SAVED! 활동지 저장 완료"** 문구와, 진행률 위젯의
  **"✓ 제출"** 배지도 이름 여부와 무관하게 동일하게 표시된다.
- 참고: 상태값 `savedName`은 `s.savedName || '이름 없는 친구'`로 계산되어 render()가 반환하는
  props에는 포함되지만(§3.1), **`<x-dc>` 템플릿 어디에도 `{{ savedName }}`을 실제로 출력하는 곳이
  없다** (현재 UI에 노출되지 않는 값). 따라서 화면에서 "이름 없는 친구" 같은 문구가 보이지는 않는다.
- 다만 이름은 **진행률 체크리스트 3항목 중 하나**(`!!(s.fName && s.fName.trim())`, §3.2)이므로,
  이름을 비워두면 §5.2에서 설명하는 "진행률 100% 미만" 상태가 함께 발생하는 것이 일반적이다
  (진행률과 저장 가능 여부는 별개지만, 이름 누락은 진행률 계산에는 영향을 준다).

### 5.2 진행률(%)이 낮은 상태(체크리스트 미완료)에서 버튼을 눌렀을 때

- **역시 막히지 않는다.** `savePdf` 함수는 `sheetPct`/`sheetDone`/`sheetTotal`/`sheetChecklist`
  값을 참조하지 않으며, 이 값들과 무관하게 항상 실행된다. 즉 **경고창(confirm)이나 "진행률
  N% 이상이어야 저장 가능" 같은 임계치 로직은 존재하지 않는다.**
  - 진행률 체크리스트는 §3.2의 3항목(이름 작성 / 1번 문제 답 선택(`q1Pick`) / 서술형 답안
    `prog2` 작성)뿐이며, 활동지의 다른 문제(4단계 순서 배열, O/X 문제, 3지선다 등)는 진행률
    계산에 아예 포함되지 않는다. 따라서 "진행률 0%"라도 다른 문제엔 답을 다 채웠을 수 있다.
- 진행률이 0%(아무것도 안 채운 상태)여도:
  - PDF 생성(또는 인쇄 폴백)이 정상적으로 실행된다.
  - 캡처되는 PDF에는 **미완성 상태 그대로**(빈 답안칸, 미선택 문제 등)가 담긴다 — 시스템이
    별도로 "미완료" 워터마크나 경고를 추가하지 않는다.
  - `saved: true`가 설정되어 "SAVED!" 문구와 "✓ 제출" 배지가 정상적으로 나타난다.
- **결과적으로**: 진행률 위젯(§2.4)은 어디까지나 학생에게 "얼마나 작성했는지" 보여주는
  **정보성 표시일 뿐, 저장/제출을 제한하는 게이트가 아니다.** 진행률 0%든 100%든 버튼을 누르면
  동일하게 저장·제출 처리가 완료된다.

> **요약**: 이 컴포넌트는 "필수 항목 완료 후 제출 가능"과 같은 서버/폼 검증 개념이 없는,
> **클라이언트 전용(로컬 다운로드) 활동지**다. 이름 미입력·낮은 진행률 모두 버튼 동작을
> 막지 않으며, 유일한 차이는 (a) PDF 파일명에서 이름이 빠지는 것과 (b) PDF/인쇄물 안에
> 빈 칸이 그대로 남는 것뿐이다.

---

## 6. `printFallback` 경로가 의존하는 인쇄 전용 CSS

```css
/* [design.md §6] 전역 인쇄 규칙 */
@media print {
  ...
  /* "PDF로 저장하기" — 수업 활동지 탭 내용만 인쇄 (savePdf 가 body.print-sheet-only 토글) */
  body.print-sheet-only #appTitlebar,
  body.print-sheet-only #appFooter,
  body.print-sheet-only #pdfBtn { display: none !important; }
  body.print-sheet-only #appPage {
    zoom: 1 !important; min-height: 0 !important; padding: 0 !important;
    background: #fff !important; background-image: none !important;
  }
}
```
- `body.print-sheet-only` 클래스가 있을 때만 적용되며, 상단 타이틀바/하단 푸터/PDF 버튼을 인쇄에서
  제외하고 배경을 흰색으로, 확대(zoom) 배율을 1로 리셋해 활동지 본문만 깔끔하게 인쇄되도록 한다.
- `.seq-tray`, `.ca-tray`(미배치 드래그 칩), 정답/오답 표시의 색 의존을 텍스트(`✓ 정답`/`✗ 다시`)로
  보완하는 등, 인쇄(흑백 프린터 포함) 환경을 고려한 규칙도 같은 `@media print` 블록에 포함되어 있다.

---

## 7. 다른 에이전트가 알아야 할 요점 정리

| 항목 | 내용 |
|---|---|
| 버튼 라벨 | "📄 PDF로 저장하기" (별도의 "제출" 버튼은 없음) |
| 클릭 핸들러 | `savePdf` (data-dc-script 내부 함수) |
| 정상 경로 | `html2canvas` + `jsPDF`로 실제 PDF 파일 생성·다운로드 |
| 폴백 경로 | 라이브러리 부재/캡처 대상 없음 → `window.print()` |
| "제출" 표시 위치 | 좌측 플로팅 진행률 위젯의 `✓ 제출` 배지 (`sheetSaved` = `!!s.saved`) |
| 제출 조건 | 두 경로 중 하나라도 성공하면 `saved: true` — 진행률 체크리스트 완료 여부와 무관 |
| 파일명 규칙 | `"{학년}{반 2자리}{번호 2자리} {이름} 활동지.pdf"` (값이 없으면 해당 부분 생략) |
| 캡처 대상 | `#sheetPrintArea` (원본이 아닌 화면 밖 복제본을 캡처, 원본 DOM은 무변경) |
| textarea 처리 | 캡처 전, 답안 `textarea.blank`를 실제 입력값을 담은 `<div>`로 치환 (html2canvas 제약 회피) |
| 이미지 포맷 | JPEG 품질 0.9 (파일 용량 절감 목적, 주석 명시) |
| 진행률과의 관계 | 진행률(%)과 "제출" 배지는 서로 다른 상태값이며 100% 미만이어도 제출 가능 |
| **이름 미입력 시** | **막히지 않음.** PDF/인쇄는 정상 진행, 파일명에서 이름 세그먼트만 생략, PDF 안 이름 칸은 빈 채로 캡처됨 |
| **진행률 낮을 때(0% 포함)** | **막히지 않음.** 임계치/경고 로직 없음. 미완성 상태 그대로 PDF 생성·제출 처리(`saved:true`) |
| 검증(validation) 존재 여부 | 없음 — 이 컴포넌트는 클라이언트 전용 로컬 다운로드이며 필수 항목 강제 로직이 없음 |
