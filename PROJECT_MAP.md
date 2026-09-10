# 프로젝트 지도 (폴더·파일 설명서)

이 문서는 이 프로젝트 폴더 안에 뭐가 있는지 몰라도 알아볼 수 있게 쓴 안내서입니다.
새 파일이 생기면 `file-cataloger` 서브에이전트가 이 문서를 자동으로 갱신합니다.

## 먼저, 용어 하나만: gitignore가 뭔가요?

"이 파일은 gitignore 되어 있다" = **"비밀번호·인증키처럼 남에게 보이면 안 되는 정보가 들어있거나,
그때그때 다시 만들 수 있는 임시 파일이라 GitHub에는 안 올리고 내 컴퓨터에만 남겨두는 파일"**
이라는 뜻입니다. 이 프로젝트의 `.gitignore`가 실제로 빼는 것들:
- `scripts/neis.local.ps1`, `output/neis.config.js` — NEIS(나이스) API 인증키가 들어있는 파일
- `output/data3.html` — NEIS 인증키가 **파일 안에 직접 박혀있는** 구글사이트 임베드본이라 제외
- `output/fonts/`, `output/support.js` — `input/design/project/`에 원본이 있는 뷰어용 복사본이라 제외
- 그 외 OS 임시파일(`Thumbs.db` 등), 에디터 설정 폴더

## 폴더 지도

| 폴더 | 무엇을 위한 폴더인가 | 안에 있는 것 예시 |
|---|---|---|
| `guide/` | **설계 문서 모음.** 디자인 규칙, 활동 만드는 규칙, 지금까지 뭘 만들고 고쳤는지 기록. | `design.md`, `build.md` 등 (아래 표 참고) |
| `output/` | **실제로 완성돼서 쓰는 결과물.** 여기 있는 HTML을 Google Sites에 붙여넣습니다. | `data4_4.html`, `data5_1.html` |
| `spec/` | 개별 상호작용 활동의 구체적인 설계 명세 (`activity-agent`가 만듦). | `data4-4steps-sequencing.activity.md` |
| `brief/` | 활동 spec을 디자인 컴포넌트로 매핑한 지시서 (`design-agent`가 만듦). | `data4-4steps-sequencing.build-brief.md` |
| `scripts/` | NEIS(나이스)에서 시간표·급식 데이터를 자동으로 받아오는 프로그램. | `fetch-neis.ps1`, `build-webapp-data.ps1` |
| `data/` | 위 스크립트가 받아온 시간표·급식·학교 정보 원본 데이터. | `timetable.json`, `meal.json`, `school.json` |
| `input/` | Claude Design 원본 디자인 파일 + 활동지에 넣을 캡처 이미지들. | `input/design/`, `구성분석1.png` 등 |
| `agent/` | 지금은 비어있는 폴더. 나중에 뭔가 생기면 `file-cataloger`가 이 줄을 채웁니다. | (비어있음) |
| `.claude/` | Claude Code가 자동으로 작동하는 방식을 정의한 폴더. `agents/`(뒷단 전문가들), `skills/`(사용자가 부를 수 있는 진입점). | `.claude/agents/`, `.claude/skills/` |

## `output/` 안 HTML 파일들 — 뭐가 다른가

파일이 여러 개 쌓여 헷갈리기 쉬운데, 대략 이런 관계입니다.

| 파일 | 무엇인가 |
|---|---|
| `data4.html` | 데이터 분석 단원의 **원본**(Claude Design `<x-dc>` 템플릿 형식, 그대로는 배포 못 함) |
| `data4_1.html` | `data4.html`을 Google Sites 임베드용으로 자체완결화(외부 리소스 전부 인라인)한 첫 배포판 |
| `data4_act.html` | 수업 활동지 탭만 따로 떼어서 작업하기 편하게 만든 소형 작업용 파일 |
| `data4_4.html` | 여러 번 수정을 거친 **현재 최신 배포판** (이용규칙/시간표/급식/활동지 4탭 전부 포함) |
| `data4.answers.md` | `data4` 계열의 정답키 (학생 화면에는 안 보이는 정답을 여기 텍스트로 모아둠) |
| `data5.html`, `data5_1.html` | 데이터 시각화 단원(포켓몬 데이터, CODAP) 원본과 배포판 |
| `data5.pdf` | data5 활동지를 PDF로 뽑아둔 것 |
| `support.js` | `<x-dc>` 템플릿을 파싱해서 화면에 그리는 런타임 스크립트 (뷰어용, gitignore됨) |
| `fonts/` | 로컬 폰트 파일 (뷰어용, gitignore됨 — 실제 배포판엔 base64로 인라인되어 있음) |
| `neis.config.example.js` | NEIS 인증키 설정 파일의 **예시**(실제 키는 `neis.config.js`, gitignore됨) |

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

`.claude/agents/file-cataloger.md`가 하는 일입니다. 새 파일이 만들어지거나 크게 바뀌면,
비슷한 기존 파일과 무엇이 다른지 한두 줄로 이 문서에 적습니다.
어떤 스킬·서브에이전트가 있는지는 `.claude/AGENTS_MAP.md`를 보세요.
