---
name: msinfo
description: >
  신현중 정보 수업 활동지(output/dataN.html 계열, "신현중학교 정보" 레트로 창 UI)를
  처음부터 끝까지 만드는 반복 루틴의 진입점. 수업 목표·개념, 검토용 초안, 사용자가 수정한 PDF,
  또는 이미 만든 활동지 파일 중 무엇이 들어오든 worksheet-routine 오케스트레이터 서브에이전트에
  넘겨 ① 아이디어 제안 → ② 사용자가 고름 → ③ 전체 활동 초안 → ④ 사용자 수정 PDF 접수 →
  ⑤ 컴포넌트(빈칸·객관식·OX·짝짓기 등) 기반 HTML 조립 → ⑥ 화면 보고 말로 수정, 6단계를 진행한다.
  "활동지 만들어줘", "이 수업으로 활동지", "학습지/워크시트 제작", "/msinfo",
  data4/data5 같은 활동지 새로 만들기·이어서 수정 요청에 사용.
---

# msinfo — 수업 활동지 제작 루틴 (진입점)

이 루틴은 **`worksheet-routine` 오케스트레이터 서브에이전트**가 실행한다.
(`.claude/agents/00-worksheet-routine/AGENT.md` — 그 아래로 `idea-agent` / `activity-agent` / `design-agent` / `builder-agent` 등을 부린다.)

## 실행 방법

`Agent` 도구로 `subagent_type: "worksheet-routine"` 를 호출한다. `prompt` 에는 **사용자가 이번에 준 것**을 그대로 담는다:

- 수업 목표·개념만 주어졌으면 그 텍스트 → 오케스트레이터가 1~3단계(아이디어 제안까지) 수행 후 멈춤.
- 사용자가 수정한 활동지 PDF를 줬으면 그 PDF 경로/내용 → 4~5단계(HTML 조립·검증·스크린샷) 후 멈춤.
- 이미 있는 `output/dataN.html` 에 "이 부분 바꿔줘" → 6단계(같은 파일 최소 diff 수정) 후 멈춤.
- 애매하면 오케스트레이터가 되묻도록 그대로 전달한다.

오케스트레이터는 **사람 입력이 필요한 지점**(아이디어 선택 / 초안 피드백·PDF 제공 / 화면 확인)에서
"한 것 / 다음에 필요한 것"을 정리해 반환한다. 그 내용을 사용자에게 전하고, 답을 받으면 다음 호출에 실어 다시 부른다.
사용자 선택·답을 대신 지어내지 않는다.

## 6단계 요약 (상세는 오케스트레이터 문서)

| # | 단계 | 담당 | 멈춤? |
|---|---|---|---|
| 1 | 수업 목표/개념 받기 (가정 명시) | idea-agent | |
| 2 | 아이디어 2~3개 제안 → 사용자 선택 | idea-agent | ✋ 선택 대기 |
| 3 | 전체 활동 초안(`spec/*.md`), 데이터·정답 검산 | idea-agent / activity-agent | ✋ 피드백·PDF 대기 |
| 4 | 사용자 수정 PDF 전 페이지 확인, 필요 이미지 PNG 요청 | worksheet-routine | |
| 5 | 자체완결본 브랜치 → 본문·`Component` 교체, 컴포넌트 매핑, base64 인라인, 인쇄/PDF, **헤드리스 검증** | builder-agent (+design-agent 매핑) | ✋ 화면 확인 대기 |
| 6 | 학생 입장에서 입력·오답 회복·진행률·PDF/인쇄 테스트 | student-test-agent | ✋ 테스트 결과 확인 대기 |
| 7 | 교사용 HTML과 정답 PDF 생성 | teacher-kit-generator | |
| 8 | 최종 디자인·규칙·접근성·인쇄 검수 | worksheet-audit | ✋ 최종 확인 대기 |
| 반복 | "이 부분 바꿔줘" → 같은 파일 `Edit` 반복 | builder-agent → student-test-agent → worksheet-audit | ✋ 매 수정마다 |

## 핵심 규칙 (오케스트레이터가 강제)

- 같은 산출물 파일 하나를 계속 수정. 새 파일은 "새로 만들자/다른 주제"라고 **명시**할 때만.
- `<head>` 인라인 블록(React·jsPDF·woff2 base64·support.js)과 `<x-dc>` 골격은 유지, `#sheetPrintArea` 본문 + `Component` 만 교체.
- 컴포넌트는 `guide/activity guide.md §1` 재사용. 모든 입력에 유일 `aria-label`/`data-*`. 정답은 근거로 확정·추측 금지.
- 외부 리소스 0, 이미지 전부 base64 인라인. 새 JS 는 `document` 위임 IIFE (전역 `querySelector` 금지 — 형제/타깃 기준).
- 브라우저 없이 Edge 헤드리스(`--dump-dom`·`--screenshot`)로 하이드레이션·`{{ }}` 누수·레이아웃 검증 후 사용자에게 전달.
- 완료 시 `guide/activity.md` 기록 + `CLAUDE.md` 규칙대로 커밋·푸시.
