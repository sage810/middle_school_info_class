# 프로젝트 지도 (폴더·파일 설명서)

이 문서는 이 프로젝트 폴더 안에 뭐가 있는지 몰라도 알아볼 수 있게 쓴 안내서입니다.
새 파일이 생기면 `file-cataloger` 서브에이전트가 이 문서를 자동으로 갱신합니다.

## 먼저, 용어 하나만: gitignore가 뭔가요?

"이 파일은 gitignore 되어 있다" = **"비밀번호·인증키처럼 남에게 보이면 안 되는 정보가 들어있거나,
그때그때 다시 만들 수 있는 임시 파일이라 GitHub에는 안 올리고 내 컴퓨터에만 남겨두는 파일"**
이라는 뜻입니다. 이 프로젝트의 `.gitignore`가 실제로 빼는 것들:
- `scripts/neis.local.ps1`, `output/**/neis.config.js` — NEIS(나이스) API 인증키가 들어있는 파일
- `output/data3.html` — NEIS 인증키가 **파일 안에 직접 박혀있는** 구글사이트 임베드본이라 제외
- `output/**/fonts/`, `output/**/support.js` — `input/design/project/`에 원본이 있는 뷰어용 복사본이라 제외
- 그 외 OS 임시파일(`Thumbs.db` 등), 에디터 설정 폴더

## 폴더 지도

| 폴더 | 무엇을 위한 폴더인가 | 안에 있는 것 예시 |
|---|---|---|
| `guide/` | **설계 문서 모음.** 디자인 규칙, 활동 만드는 규칙, 지금까지 뭘 만들고 고쳤는지 기록. | `design.md`, `build.md` 등 (아래 표 참고) |
| `output/` | **실제로 완성돼서 쓰는 결과물.** 여기 있는 HTML을 Google Sites에 붙여넣습니다. 이제 `output/데이터분석/N차시/` 처럼 **차시별 하위 폴더**로 나뉘어 있습니다. | `데이터분석/4차시/data4_4.html`, `데이터분석/5차시/data5_1.html` |
| `spec/` | 개별 상호작용 활동의 구체적인 설계 명세 (`activity-agent`가 만듦) + 그 외 재현용 프롬프트 문서. | `data4-4steps-sequencing.activity.md`, `유튜브-채널-데이터분석.spec.md`, `data3-전체-제작-프롬프트.md` |
| `brief/` | 활동 spec을 디자인 컴포넌트로 매핑한 지시서 (`design-agent`가 만듦). | `data4-4steps-sequencing.build-brief.md` |
| `scripts/` | NEIS(나이스)에서 시간표·급식 데이터를 자동으로 받아오는 프로그램. | `fetch-neis.ps1`, `build-webapp-data.ps1` |
| `data/` | 위 스크립트가 받아온 시간표·급식·학교 정보 원본 데이터. | `timetable.json`, `meal.json`, `school.json` |
| `input/` | Claude Design 원본 디자인 파일 + 활동지에 넣을 캡처 이미지·원자료(CSV 등). | `input/design/`, `input/데이터분석/7차시/유튜버 top 100 분야포함.csv` |
| `agent/` | 지금은 비어있는 폴더. 나중에 뭔가 생기면 `file-cataloger`가 이 줄을 채웁니다. | (비어있음) |
| `.claude/` | Claude Code가 자동으로 작동하는 방식을 정의한 폴더. `agents/`(뒷단 전문가들), `skills/`(사용자가 부를 수 있는 진입점). | `.claude/agents/`, `.claude/skills/` |

## `output/` 폴더 구조 — 차시별 하위 폴더

`output/데이터분석/` 아래에 `4차시/`, `5차시/`, `7차시/` 처럼 차시 번호별 폴더가 있고, 각 차시 폴더
안에 그 차시의 배포용 HTML·정답키·이미지가 모여 있습니다. `support.js`(런타임 스크립트, gitignore됨)와
`neis.config.example.js`(NEIS 인증키 설정 예시)는 차시별 폴더마다 하나씩 복사돼 있습니다(현재 4차시·5차시 폴더에 있음).

### 4차시 (`output/데이터분석/4차시/`) — 뭐가 다른가

| 파일 | 무엇인가 |
|---|---|
| `data4.html` | 데이터 분석 단원의 **원본**(Claude Design `<x-dc>` 템플릿 형식, 그대로는 배포 못 함) |
| `data4_1.html` | `data4.html`을 Google Sites 임베드용으로 자체완결화(외부 리소스 전부 인라인)한 첫 배포판 |
| `data4_act.html` | 수업 활동지 탭만 따로 떼어서 작업하기 편하게 만든 소형 작업용 파일(이용규칙/시간표/급식 탭 없음) |
| `data4_3.html` | `data4_act.html`처럼 활동지 탭만 있고 진행률 위젯이 탭 게이팅 없이 항상 표시되는 초기 작업본으로 보임(이용규칙/시간표/급식 탭 없음, 줄 수도 `data4_act.html`과 비슷) — 정확한 제작 경위는 [확인 필요] |
| `data4_4.html` | 여러 번 수정을 거친 **최신 배포판 중 하나**(이용규칙/시간표/급식/활동지 4탭 전부 포함, 진행률 위젯이 탭 게이팅됨) |
| `data4_5.html` | `data4_4.html`과 줄 수·탭 구성(4탭 전부, 진행률 위젯 탭 게이팅)이 거의 동일한 병행 버전 — 다른 세션에서 작업한 최신 배포판으로 보이나, `data4_4.html`과 정확히 무엇이 다른지는 [확인 필요] |
| `data4_5_teachers.html` | `data4_5.html`의 **교사용 버전으로 추정**(코드 안에 "[teachers 판] 교사용 배포본에서는 옆 고정 '활동 진행률' 위젯을 항상 숨긴다" 처리가 있고, `data4_5.html`보다 약 64줄 적음) |
| `data4.answers.md` | `data4` 계열의 정답키 (학생 화면에는 안 보이는 정답을 여기 텍스트로 모아둠) |
| `neis.config.example.js` | NEIS 인증키 설정 파일의 **예시**(실제 키는 `neis.config.js`, gitignore됨) |
| `support.js` | `<x-dc>` 템플릿을 파싱해서 화면에 그리는 런타임 스크립트 (뷰어용, gitignore됨) |

### 5차시 (`output/데이터분석/5차시/`) — 뭐가 다른가

| 파일 | 무엇인가 |
|---|---|
| `data5.html` | 데이터 시각화 단원(포켓몬 데이터, CODAP) **원본** |
| `data5_1.html` | `data5.html`을 Google Sites 임베드용으로 자체완결화한 배포판 (`data5.html`과 줄 수 동일) |
| `data5_1b.html` | **[임시 보존, 정리 필요]** `data5_1.html`과 이름만 비슷한 **별개 파일**. 서로 다른 두 세션에서 각자 `data5_1`을 다르게 발전시킨 버전이라, 병합할 때 이름을 `data5_1b.html`로 바꿔 둘 다 보존해 둔 상태. 사용자가 아직 두 버전 중 최종본을 고르지 않았으니 정리(둘 중 하나를 최종본으로 확정하거나 통합)가 필요함 |
| `data5_2.html` | 5차시의 CODAP 그래프 활동(구성·비교·분포·관계, `data5_1`과 같은 주제 문구 사용)이지만 줄 수가 더 많은 별도 파일 — `data5_1`의 후속 차시용인지 대체본인지 등 정확한 관계는 [확인 필요] |
| `data5_2_teacher.html` | `data5_2.html`의 **교사용 버전으로 추정**(줄 수가 `data5_2.html`보다 17줄 적음). 다만 `data4_5_teachers.html`에서 보이는 것 같은 명확한 "교사용" 표식 주석은 찾지 못해 정확한 차이는 [확인 필요] |
| `data5.pdf` | `data5` 활동지를 PDF로 뽑아둔 것 |
| `neis.config.example.js` | NEIS 인증키 설정 파일의 예시 (4차시 폴더에 있는 것과 같은 예시 파일) |
| `support.js` | 런타임 스크립트 (뷰어용, gitignore됨) |

### 7차시 (`output/데이터분석/7차시/`) — 신규

| 파일 | 무엇인가 |
|---|---|
| `data7.html` | **신규.** "신입 유튜버의 국내 TOP 100 채널 분석" 활동지 — 신입 유튜버가 국내 TOP 100 채널 자료(CSV)를 CODAP에 올려 구성→비교→분포→관계 순으로 분석하고 자신의 채널 전략을 정하는 활동. 원자료는 `input/데이터분석/7차시/유튜버 top 100 분야포함.csv` |
| `data7.answers.md` | `data7`의 교사용 정답키. 결과 숫자는 학생이 CODAP에서 직접 계산하도록 미리 확정하지 않는 방식(정답 판정 기준만 서술) |
| `data7.png` | `data7` 활동 관련 이미지(스크린샷 등) |

## `spec/` 폴더 안 문서들 — 뭐가 다른가

| 파일 | 무엇인가 |
|---|---|
| `data4-4steps-sequencing.activity.md` | data4의 "4단계 순서 배열" 인터랙션 활동에 대한 구체적 설계 명세 |
| `유튜브-채널-데이터분석.spec.md` | data7 활동("신입 유튜버의 국내 TOP 100 채널 분석")의 설계 명세 — 대상/컨셉/원자료/미션 순서(구성→비교→분포→관계) 정의 |
| `data3-전체-제작-프롬프트.md` | **신규.** 다른 문서 둘과 성격이 다름 — 개별 인터랙션 활동 명세가 아니라, "신현중학교 컴퓨터실 페이지 v3"(`data3` 계열) 자체를 다른 학교에서도 재현할 수 있도록 통째로 정리한 제작 프롬프트 문서. 원래 저장소 루트의 `middle school info class/` 폴더에 있던 것을 `spec/`으로 옮겨온 것 |

## `guide/` 폴더 안 문서들 — 뭐가 다른가

| 파일 | 무엇을 적어놓은 문서인가 |
|---|---|
| `design.md` | 색상·폰트·여백 같은 디자인 규칙표. 새 화면 만들 때 기준. |
| `activity guide.md` | **실제 구현 가능한 인터랙션 컴포넌트 카탈로그** (§1 이미 만들어진 것, §2 공통 규칙, §3 아이디어). |
| `activity.md` | 활동 하나하나를 왜 그렇게 설계했는지 기록한 일지. |
| `build.md` | `output/` 파일 전체 단위 기능(진행률 위젯, PDF 버튼 등)의 구현 일지. |
| `google embed rules.md` | 원본 → Google Sites 배포판 자체완결화 변환 규칙. |
| `rule.md` / `timetable.md` / `lunch.md` | 여러 단원 파일이 공통으로 쓰는 학교 포털 탭(이용규칙/시간표/급식)의 재현 명세. |
| `pdf download.md` / `pdf submit button.md` | "PDF로 저장하기" 버튼 동작 문서. 적용된 파일이 서로 달라 두 개로 나뉨. |

## 새 파일이 생기면 이 문서가 자동으로 어떻게 갱신되나

`.claude/agents/90-file-cataloger/AGENT.md`가 하는 일입니다. 새 파일이 만들어지거나 크게 바뀌면,
비슷한 기존 파일과 무엇이 다른지 한두 줄로 이 문서에 적습니다.
어떤 스킬·서브에이전트가 있는지는 `.claude/AGENTS_MAP.md`를 보세요.
